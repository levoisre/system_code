const express = require('express');
const cors = require('cors');
const db = require('./database');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
    cors: {
        origin: '*',
        methods: ['GET', 'POST']
    }
});

// --- 1. MIDDLEWARE ---
app.use(cors({
    origin: '*', 
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    credentials: true
}));

app.use(express.json());

// Request Logger
app.use((req, res, next) => {
    console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.path}`);
    next();
});

io.on('connection', (socket) => {
    console.log(`📱 New connection: ${socket.id}`);
    socket.on('disconnect', () => console.log('📱 Disconnected'));
});

let studentWeights = {};

// --- 🎯 QUICKSORT ALGORITHM IMPLEMENTATION ---
function quickSort(arr, left = 0, right = arr.length - 1) {
    if (left < right) {
        let pivotIndex = partition(arr, left, right);
        quickSort(arr, left, pivotIndex - 1);
        quickSort(arr, pivotIndex + 1, right);
    }
    return arr;
}

function partition(arr, left, right) {
    let pivot = arr[right].total_points;
    let i = left - 1;
    for (let j = left; j < right; j++) {
        if (arr[j].total_points >= pivot) {
            i++;
            [arr[i], arr[j]] = [arr[j], arr[i]]; 
        }
    }
    [arr[i + 1], arr[right]] = [arr[right], arr[i + 1]];
    return i + 1;
}

// --- HELPER: Subject Code Fallback ---
// This ensures that even if the UI sends "CPE 401", the backend uses your seeded "DATA STRUCTURES" data.
const getActiveCode = (code) => (code && code.includes("401")) ? "DATA STRUCTURES" : code;

app.get('/', (req, res) => res.send("Smart Classroom Backend is Running! 🚀"));

// --- 2. RECITATION & LEADERBOARD ROUTES ---

app.get('/api/recitation/stats/:subjectCode', (req, res) => {
    const code = getActiveCode(req.params.subjectCode);
    const sql = `
        SELECT s.name, 
               COALESCE((SELECT SUM(points) FROM recitation_logs WHERE student_name = s.name AND subject_code = ?), 0) as total_points
        FROM students s
        WHERE s.subject_code = ? AND s.is_present = 1
        ORDER BY s.name ASC`;

    db.all(sql, [code, code], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

app.get('/api/quiz/leaderboard/:subjectCode', (req, res) => {
    const code = getActiveCode(req.params.subjectCode);
    const sql = `
        SELECT s.name, 
                (COALESCE((SELECT SUM(points) FROM recitation_logs WHERE student_name = s.name AND subject_code = ?), 0) +
                 COALESCE((SELECT SUM(score) FROM quiz_results WHERE student_name = s.name AND quiz_id IN (SELECT id FROM quizzes WHERE subject_code = ?)), 0)) as total_points,
                COALESCE((SELECT MAX(stars) FROM recitation_logs WHERE student_name = s.name AND subject_code = ?), 0) as last_stars
        FROM students s
        WHERE s.subject_code = ? AND s.is_present = 1
        GROUP BY s.name`;

    db.all(sql, [code, code, code, code], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        const rankedStudents = quickSort(rows);
        res.json(rankedStudents);
    });
});

app.post('/api/recitation/randomize', (req, res) => {
    let { students, subjectCode } = req.body; 
    subjectCode = getActiveCode(subjectCode);
    if (!students || students.length === 0) return res.status(400).json({ error: "No students present" });
    
    if (!studentWeights[subjectCode]) studentWeights[subjectCode] = {};
    students.forEach(name => {
        if (!studentWeights[subjectCode][name]) studentWeights[subjectCode][name] = 100;
    });

    const activeWeights = students.map(name => ({ name, weight: studentWeights[subjectCode][name] }));
    const totalWeight = activeWeights.reduce((sum, s) => sum + s.weight, 0);
    
    let randomNum = Math.random() * totalWeight;
    let selected = students[0];

    for (let i = 0; i < activeWeights.length; i++) {
        if (randomNum < activeWeights[i].weight) {
            selected = activeWeights[i].name;
            break;
        }
        randomNum -= activeWeights[i].weight;
    }

    students.forEach(name => {
        studentWeights[subjectCode][name] = (name === selected) ? 10 : (studentWeights[subjectCode][name] + 15);
    });

    io.emit('notification', {
        type: 'recitation',
        text: `Your Turn! Professor has selected you for recitation.`,
        date: new Date().toLocaleDateString()
    });
    res.json({ selected });
});

app.post('/api/recitation/submit', (req, res) => {
    let { name, subjectCode, stars } = req.body;
    subjectCode = getActiveCode(subjectCode);
    const sql = `INSERT INTO recitation_logs (student_name, subject_code, stars, points) VALUES (?, ?, ?, ?)`;
    
    db.run(sql, [name, subjectCode, stars, stars * 10], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        io.emit('teacher_notification', { type: 'Quiz', title: 'Points Updated', desc: `Recitation points added for ${name}.` });
        res.json({ status: "success" });
    });
});

app.post('/api/recitation/reset', (req, res) => {
    const subjectCode = getActiveCode(req.body.subjectCode);
    db.run(`DELETE FROM recitation_logs WHERE subject_code = ?`, [subjectCode], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ status: "success" });
    });
});

// --- 3. ASSESSMENT / QUIZ ROUTES ---

app.post('/api/quiz/create', (req, res) => {
    let { subjectCode, title, description, questions } = req.body;
    subjectCode = getActiveCode(subjectCode);
    db.serialize(() => {
        db.run("BEGIN TRANSACTION");
        db.run(`INSERT INTO quizzes (subject_code, title, description, is_active, is_given) VALUES (?, ?, ?, 1, 0)`, 
        [subjectCode, title, description], function(err) {
            if (err) return db.run("ROLLBACK"), res.status(500).json({ error: "Save failed" });
            const quizId = this.lastID;
            const stmt = db.prepare(`INSERT INTO quiz_questions (quiz_id, type, question_text, correct_answer, hint, metadata, row, col, dir) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`);
            
            questions.forEach((q) => {
                // TAGGING FIX: Ensure types are always uppercase for Flutter to recognize
                const cleanType = q.type.toUpperCase().trim();
                stmt.run([quizId, cleanType, q.question_text, q.correct_answer, q.hint || "", q.metadata ? JSON.stringify(q.metadata) : null, q.row || 0, q.col || 0, q.dir || 'H']);
            });
            stmt.finalize();
            db.run("COMMIT");
            res.json({ status: "success", quizId });
        });
    });
});

app.patch('/api/quiz/update/:quizId', (req, res) => {
    const { quizId } = req.params;
    const { title, description, questions } = req.body;
    db.serialize(() => {
        db.run("BEGIN TRANSACTION");
        db.run(`UPDATE quizzes SET title = ?, description = ? WHERE id = ?`, [title, description, quizId], (err) => {
            if (err) return db.run("ROLLBACK"), res.status(500).json({ error: err.message });
            db.run(`DELETE FROM quiz_questions WHERE quiz_id = ?`, [quizId], (err) => {
                if (err) return db.run("ROLLBACK"), res.status(500).json({ error: err.message });
                const stmt = db.prepare(`INSERT INTO quiz_questions (quiz_id, type, question_text, correct_answer, hint, metadata, row, col, dir) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`);
                
                questions.forEach((q) => {
                    // TAGGING FIX: Ensure types are always uppercase
                    const cleanType = q.type.toUpperCase().trim();
                    stmt.run([quizId, cleanType, q.question_text, q.correct_answer, q.hint || "", q.metadata ? JSON.stringify(q.metadata) : null, q.row || 0, q.col || 0, q.dir || 'H']);
                });
                stmt.finalize();
                db.run("COMMIT");
                res.json({ status: "success" });
            });
        });
    });
});

app.get('/api/quiz/list/:subjectCode', (req, res) => {
    const code = getActiveCode(req.params.subjectCode);
    db.all(`SELECT * FROM quizzes WHERE subject_code = ? ORDER BY id DESC`, [code], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

app.get('/api/quiz/student-view/:subjectCode', (req, res) => {
    const code = getActiveCode(req.params.subjectCode);
    const sql = `SELECT * FROM quizzes WHERE subject_code = ? AND is_active = 1 AND is_given = 1 ORDER BY id DESC`;
    db.all(sql, [code], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

// --- REMAINING ROUTES (Unchanged) ---
app.patch('/api/quiz/status/:quizId', (req, res) => {
    const { quizId } = req.params;
    const { status } = req.body;
    db.run(`UPDATE quizzes SET is_active = ? WHERE id = ?`, [status, quizId], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ status: "success" });
    });
});

app.delete('/api/quiz/delete/:quizId', (req, res) => {
    const { quizId } = req.params;
    db.serialize(() => {
        db.run("BEGIN TRANSACTION");
        db.run(`DELETE FROM quiz_questions WHERE quiz_id = ?`, [quizId]);
        db.run(`DELETE FROM quizzes WHERE id = ?`, [quizId], (err) => {
            if (err) return db.run("ROLLBACK"), res.status(500).json({ error: err.message });
            db.run("COMMIT");
            res.json({ status: "success" });
        });
    });
});

app.patch('/api/quiz/give/:quizId', (req, res) => {
    const { quizId } = req.params;
    const { isGiven, title } = req.body; 
    db.run(`UPDATE quizzes SET is_given = ? WHERE id = ?`, [isGiven, quizId], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        if (isGiven === 1) {
            io.emit('notification', {
                type: 'alert',
                text: `New Assessment: ${title || 'Quiz'} is now live!`,
                date: new Date().toLocaleDateString(),
                quizId: quizId
            });
        }
        res.json({ status: "success", isGiven });
    });
});

app.post('/api/results/submit', (req, res) => {
    const { quizId, studentName, score, totalQuestions, answers } = req.body;
    db.run(`INSERT INTO quiz_results (quiz_id, student_name, score, total_questions, student_answers) VALUES (?, ?, ?, ?, ?)`, 
    [quizId, studentName, score, totalQuestions, JSON.stringify(answers)], (err) => {
        if (err) return res.status(500).json({ error: err.message });
        io.emit('teacher_notification', { type: 'Quiz', title: 'New Submission', desc: `${studentName} scored ${score}/${totalQuestions}.` });
        res.json({ status: "success" });
    });
});

app.get('/api/results/check/:quizId/:studentName', (req, res) => {
    const { quizId, studentName } = req.params;
    db.get(`SELECT * FROM quiz_results WHERE quiz_id = ? AND student_name = ?`, [quizId, studentName], (err, row) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ completed: !!row, data: row || null });
    });
});

app.get('/api/quiz/details/:quizId', (req, res) => {
    db.all(`SELECT * FROM quiz_questions WHERE quiz_id = ? ORDER BY id ASC`, [req.params.quizId], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});

const PORT = 5000;
server.listen(PORT, '0.0.0.0', () => {
    console.log(`-----------------------------------------------`);
    console.log(`🚀 SMART CLASSROOM BACKEND ACTIVE ON PORT ${PORT}`);
    console.log(`🚀 TAGGING & SUBJECT FALLBACK SYNCED`);
    console.log(`-----------------------------------------------`);
});