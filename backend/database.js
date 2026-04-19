const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.resolve(__dirname, 'recitation.db');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error("❌ Database connection error:", err.message);
    } else {
        console.log("✅ Connected to the recitation database.");
        initializeTables();
    }
});

function initializeTables() {
    db.serialize(() => {
        // 1. STUDENTS TABLE
        db.run(`CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            subject_code TEXT NOT NULL,
            is_present INTEGER DEFAULT 0
        )`);

        // 2. RECITATION LOGS
        db.run(`CREATE TABLE IF NOT EXISTS recitation_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_name TEXT NOT NULL,
            subject_code TEXT NOT NULL,
            stars INTEGER,
            points INTEGER,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )`);

        // 3. QUIZZES TABLE
        db.run(`CREATE TABLE IF NOT EXISTS quizzes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject_code TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            is_active INTEGER DEFAULT 0
        )`);

        // 4. QUIZ QUESTIONS
        // Added 'MULTIPLE_CHOICE' to the possible types in your logic
        db.run(`CREATE TABLE IF NOT EXISTS quiz_questions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quiz_id INTEGER,
            type TEXT NOT NULL, -- 'TF', 'IDENTIFICATION', 'CROSSWORD', 'MULTIPLE_CHOICE'
            question_text TEXT NOT NULL,
            correct_answer TEXT NOT NULL,
            hint TEXT,
            metadata TEXT, -- JSON string for Crossword coords OR Multiple Choice options
            FOREIGN KEY(quiz_id) REFERENCES quizzes(id)
        )`, (err) => {
            if (!err) {
                seedInitialData();
            }
        });
    });
}

function seedInitialData() {
    db.get("SELECT COUNT(*) as count FROM students WHERE subject_code = 'CPE 401'", (err, row) => {
        if (row && row.count === 0) {
            console.log("🌱 Seeding fresh student and assessment data (including Multiple Choice)...");
            
            const studentStmt = db.prepare("INSERT INTO students (name, subject_code, is_present) VALUES (?, ?, ?)");
            const demoStudents = [
                ['Jet Hinks', 'CPE 401', 1],
                ['Maria Garcia', 'CPE 401', 1],
                ['Tony Hugh', 'CPE 401', 1],
                ['Alex Johnson', 'CPE 401', 1],
                ['Samuel Pru', 'CPE 401', 1]
            ];
            demoStudents.forEach(s => studentStmt.run(s));
            studentStmt.finalize();

            db.run("INSERT INTO quizzes (subject_code, title, description, is_active) VALUES ('CPE 401', 'Midterm Assessment', 'Comprehensive Quiz', 1)", function(err) {
                if (err) return;
                const quizId = this.lastID;

                const quizStmt = db.prepare("INSERT INTO quiz_questions (quiz_id, type, question_text, correct_answer, hint, metadata) VALUES (?, ?, ?, ?, ?, ?)");
                
                // 1. True or False
                quizStmt.run([quizId, 'TF', 'Flutter is developed by Microsoft.', 'False', 'Think about Search Engines', null]);

                // 2. Identification
                quizStmt.run([quizId, 'IDENTIFICATION', 'What is the programming language used by Flutter?', 'Dart', 'Developed by Google', null]);

                // 3. Crossword
                quizStmt.run([
                    quizId, 
                    'CROSSWORD', 
                    'Lightweight database.', 
                    'SQLITE', 
                    'Starts with S', 
                    JSON.stringify({ "row": 2, "col": 1, "direction": "across" })
                ]);

                // 4. NEW: Multiple Choice
                quizStmt.run([
                    quizId,
                    'MULTIPLE_CHOICE',
                    'Which widget is used for repeating lists in Flutter?',
                    'ListView',
                    'Efficient for many items',
                    JSON.stringify(["Column", "Row", "ListView", "Stack"]) // The options
                ]);

                quizStmt.finalize();
                console.log("🚀 Database ready with all 4 assessment types.");
            });
        }
    });
}

module.exports = db;