const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();

// --- 1. ROBUST MIDDLEWARE ---
// Explicitly configured to prevent CORS blocks on Flutter Web (Chrome)
app.use(cors({
    origin: '*', 
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    credentials: true
}));

app.use(express.json());

// Request Logger: Critical for debugging button clicks and network errors
app.use((req, res, next) => {
    console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.path}`);
    if (req.method !== 'GET') {
        console.log('    Body:', JSON.stringify(req.body, null, 2));
    }
    next();
});

// Memory storage for Recitation Weights (Resets when server restarts)
let studentWeights = {};

app.get('/', (req, res) => res.send("Smart Classroom Backend is Running! 🚀"));

// --- 2. RECITATION ROUTES ---

// GET SESSION STATS
app.get('/api/recitation/session-stats/:subjectCode', (req, res) => {
    const code = req.params.subjectCode;
    const sql = `
        SELECT s.name, 
               COALESCE(SUM(l.points), 0) as total_points,
               COALESCE(MAX(l.stars), 0) as last_stars
        FROM students s
        LEFT JOIN recitation_logs l ON s.name = l.student_name AND s.subject_code = l.subject_code
        WHERE s.subject_code = ? AND s.is_present = 1
        GROUP BY s.name
        ORDER BY total_points DESC`;

    db.all(sql, [code], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// RANDOMIZER (Adaptive Weighted Selection)
app.post('/api/recitation/randomize', (req, res) => {
    const { students, subjectCode } = req.body; 
    if (!students || students.length === 0) return res.status(400).json({ error: "No students present" });

    if (!studentWeights[subjectCode]) studentWeights[subjectCode] = {};
    students.forEach(name => {
        if (!studentWeights[subjectCode][name]) studentWeights[subjectCode][name] = 100;
    });

    const activeWeights = students.map(name => ({ name, weight: studentWeights[subjectCode][name] }));
    const totalWeight = activeWeights.reduce((sum, s) => sum + s.weight, 0);
    
    let randomNum = Math.random() * totalWeight;
    let selected = students[0]; // Fallback

    for (let i = 0; i < activeWeights.length; i++) {
        if (randomNum < activeWeights[i].weight) {
            selected = activeWeights[i].name;
            break;
        }
        randomNum -= activeWeights[i].weight;
    }

    // Penalize selected (10) and boost others (+15)
    students.forEach(name => {
        studentWeights[subjectCode][name] = (name === selected) ? 10 : (studentWeights[subjectCode][name] + 15);
    });

    console.log(`🎯 Randomizer Picked: ${selected}`);
    res.json({ selected });
});

// SUBMIT GRADE
app.post('/api/recitation/submit', (req, res) => {
    const { name, subjectCode, stars } = req.body;
    const sql = `INSERT INTO recitation_logs (student_name, subject_code, stars, points) VALUES (?, ?, ?, ?)`;
    db.run(sql, [name, subjectCode, stars, stars * 10], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ status: "success" });
    });
});

// RESET RECITATION SESSION
app.post('/api/recitation/reset', (req, res) => {
    const { subjectCode } = req.body;
    if (!subjectCode) return res.status(400).json({ error: "Subject code required" });

    // 1. Clear memory weights
    if (studentWeights[subjectCode]) delete studentWeights[subjectCode];

    // 2. Clear Database logs for this specific session
    const sql = `DELETE FROM recitation_logs WHERE subject_code = ?`;
    db.run(sql, [subjectCode], function(err) {
        if (err) return res.status(500).json({ error: "DB Reset failed" });
        console.log(`🧹 Session Reset: ${subjectCode} (${this.changes} rows deleted)`);
        res.json({ status: "success", deleted: this.changes });
    });
});

// --- 3. ASSESSMENT / QUIZ ROUTES ---

// CREATE ASSESSMENT
app.post('/api/quiz/create', (req, res) => {
    const { subjectCode, title, description, questions } = req.body;
    if (!subjectCode || !title || !questions) return res.status(400).json({ error: "Invalid quiz data" });

    db.serialize(() => {
        db.run("BEGIN TRANSACTION");
        const quizSql = `INSERT INTO quizzes (subject_code, title, description, is_active) VALUES (?, ?, ?, 1)`;
        
        db.run(quizSql, [subjectCode, title, description], function(err) {
            if (err) {
                db.run("ROLLBACK");
                return res.status(500).json({ error: "Header save failed" });
            }
            const quizId = this.lastID;
            const questionSql = `INSERT INTO quiz_questions (quiz_id, type, question_text, correct_answer, hint, metadata) VALUES (?, ?, ?, ?, ?, ?)`;
            const stmt = db.prepare(questionSql);
            try {
                questions.forEach((q) => {
                    const metadataString = q.metadata ? JSON.stringify(q.metadata) : null;
                    stmt.run([quizId, q.type, q.question_text, q.correct_answer, q.hint || "", metadataString]);
                });
                stmt.finalize();
                db.run("COMMIT");
                console.log(`✨ Quiz Created: ${title} (ID: ${quizId})`);
                res.json({ status: "success", quizId: quizId });
            } catch (e) {
                db.run("ROLLBACK");
                res.status(500).json({ error: "Question save failed" });
            }
        });
    });
});

// GET QUIZ LIST
app.get('/api/quiz/list/:subjectCode', (req, res) => {
    const { subjectCode } = req.params;
    const sql = `SELECT * FROM quizzes WHERE subject_code = ? ORDER BY id DESC`;
    db.all(sql, [subjectCode], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// UPDATE ASSESSMENT STATUS (Archive=0, Active=1, Completed=2)
app.patch('/api/quiz/status/:quizId', (req, res) => {
    const { quizId } = req.params;
    const { status } = req.body;
    const sql = `UPDATE quizzes SET is_active = ? WHERE id = ?`;
    db.run(sql, [status, quizId], function(err) {
        if (err) return res.status(500).json({ error: err.message });
        console.log(`🔄 Status Updated: Quiz ${quizId} -> ${status}`);
        res.json({ status: "success", updated: this.changes });
    });
});

// PERMANENT DELETE ASSESSMENT
app.delete('/api/quiz/delete/:quizId', (req, res) => {
    const { quizId } = req.params;
    db.serialize(() => {
        db.run("BEGIN TRANSACTION");
        db.run(`DELETE FROM quiz_questions WHERE quiz_id = ?`, [quizId]);
        db.run(`DELETE FROM quizzes WHERE id = ?`, [quizId], function(err) {
            if (err) {
                db.run("ROLLBACK");
                return res.status(500).json({ error: err.message });
            }
            db.run("COMMIT");
            console.log(`🗑️ Deleted Quiz ID: ${quizId}`);
            res.json({ status: "success" });
        });
    });
});

// GET FULL QUIZ DETAILS
app.get('/api/quiz/details/:quizId', (req, res) => {
    const { quizId } = req.params;
    db.all(`SELECT * FROM quiz_questions WHERE quiz_id = ?`, [quizId], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// --- 4. START SERVER ---
const PORT = 5000;
// Binding to 0.0.0.0 is essential for accessibility across your local Wi-Fi/Chrome
app.listen(PORT, '0.0.0.0', () => {
    console.log(`-----------------------------------------------`);
    console.log(`🚀 BACKEND ACTIVE ON PORT ${PORT}`);
    console.log(`🚀 SYSTEM READY FOR CRUD & RECITATION`);
    console.log(`-----------------------------------------------`);
});