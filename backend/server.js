const express = require('express');
const cors = require('cors');
const db = require('./database');

const app = express();

// --- 1. ENHANCED MIDDLEWARE ---
// Open CORS wide for development to ensure Flutter Web isn't blocked
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
}));

app.use(express.json());

// Log every single request to help you debug
app.use((req, res, next) => {
    console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.path}`);
    if (req.method === 'POST') console.log('   Body:', req.body);
    next();
});

let studentWeights = {};

// --- 2. ROUTES ---

app.get('/', (req, res) => {
    res.send("Recitation Backend is Running! 🚀");
});

// GET STATS
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

// RANDOMIZER
app.post('/api/recitation/randomize', (req, res) => {
    const { students, subjectCode } = req.body; 
    if (!students || !subjectCode) return res.status(400).json({ error: "Missing data" });

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

// RESET SESSION (The specific fix)
app.post('/api/recitation/reset', (req, res) => {
    const { subjectCode } = req.body;
    console.log(`🧹 Attempting reset for: ${subjectCode}`);

    if (!subjectCode) {
        return res.status(400).json({ error: "Subject code required" });
    }

    // 1. Clear memory weights
    if (studentWeights[subjectCode]) delete studentWeights[subjectCode];

    // 2. Clear Database logs
    const sql = `DELETE FROM recitation_logs WHERE subject_code = ?`;
    db.run(sql, [subjectCode], function(err) {
        if (err) {
            console.error("❌ SQL Reset Error:", err.message);
            return res.status(500).json({ error: "DB Reset failed" });
        }
        console.log(`✅ Database cleared. Rows deleted: ${this.changes}`);
        res.json({ status: "success", deleted: this.changes });
    });
});

// --- 3. START SERVER ---
const PORT = 5000;
app.listen(PORT, () => {
    console.log(`-----------------------------------------------`);
    console.log(`🚀 BACKEND ACTIVE ON PORT ${PORT}`);
    console.log(`-----------------------------------------------`);
});