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
            is_active INTEGER DEFAULT 1,
            is_given INTEGER DEFAULT 0
        )`);

        // 4. QUIZ QUESTIONS
        db.run(`CREATE TABLE IF NOT EXISTS quiz_questions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quiz_id INTEGER,
            type TEXT NOT NULL, 
            question_text TEXT NOT NULL,
            correct_answer TEXT NOT NULL,
            hint TEXT,
            metadata TEXT,
            row INTEGER DEFAULT 0,
            col INTEGER DEFAULT 0,
            dir TEXT DEFAULT 'H',
            FOREIGN KEY(quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
        )`);

        // 5. QUIZ RESULTS
        db.run(`CREATE TABLE IF NOT EXISTS quiz_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quiz_id INTEGER,
            student_name TEXT NOT NULL,
            score INTEGER NOT NULL,
            total_questions INTEGER NOT NULL,
            student_answers TEXT, 
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
        )`, (err) => {
            if (!err) {
                seedInitialData();
            }
        });
    });
}

function seedInitialData() {
    const subject = 'DATA STRUCTURES';
    
    db.get("SELECT COUNT(*) as count FROM quizzes WHERE subject_code = ?", [subject], (err, row) => {
        if (row && row.count === 0) {
            console.log(`🌱 Seeding Demo Data for: ${subject}...`);
            
            // --- Seed Students ---
            const studentStmt = db.prepare("INSERT INTO students (name, subject_code, is_present) VALUES (?, ?, ?)");
            const demoStudents = [
                ['Jet Hinks', subject, 1],
                ['Maria Garcia', subject, 1],
                ['Tony Hugh', subject, 1],
                ['Alex Johnson', subject, 1],
                ['Claire Anne', subject, 1]
            ];
            demoStudents.forEach(s => studentStmt.run(s));
            studentStmt.finalize();

            // --- Seed Quizzes ---
            const quizTypes = [
                { title: 'ARRAY MASTERY', desc: 'Basics of contiguous memory', type: 'MULTIPLE_CHOICE' },
                { title: 'LIFO VS FIFO', desc: 'Understanding Stacks and Queues', type: 'TF' },
                { title: 'BIG O NOTATION', desc: 'Algorithm Analysis', type: 'IDENTIFICATION' },
                { title: 'DSA CROSSWORD', desc: 'General Data Structures Clues', type: 'CROSSWORD' }
            ];

            quizTypes.forEach((qInfo) => {
                db.run(`INSERT INTO quizzes (subject_code, title, description, is_active, is_given) 
                        VALUES (?, ?, ?, 1, 1)`, [subject, qInfo.title, qInfo.desc], function(err) {
                    
                    if (err) return;
                    const quizId = this.lastID;
                    const qStmt = db.prepare(`INSERT INTO quiz_questions 
                        (quiz_id, type, question_text, correct_answer, hint, metadata, row, col, dir) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`);

                    if (qInfo.type === 'MULTIPLE_CHOICE') {
                        qStmt.run([quizId, 'MULTIPLE_CHOICE', 'Time complexity of accessing an element in an array by index?', 'O(1)', 'Constant time', JSON.stringify(['O(1)', 'O(n)', 'O(log n)', 'O(n^2)']), 0, 0, 'H']);
                        qStmt.run([quizId, 'MULTIPLE_CHOICE', 'Which structure uses a "Next" pointer to connect elements?', 'Linked List', 'Nodes', JSON.stringify(['Stack', 'Array', 'Linked List', 'Hash Table']), 0, 0, 'H']);
                    } 
                    else if (qInfo.type === 'TF') {
                        qStmt.run([quizId, 'TF', 'A Queue follows the Last-In-First-Out (LIFO) principle.', 'False', 'Think of a grocery line', null, 0, 0, 'H']);
                        qStmt.run([quizId, 'TF', 'Binary Search requires the data to be sorted.', 'True', 'Divide and Conquer', null, 0, 0, 'H']);
                    } 
                    else if (qInfo.type === 'IDENTIFICATION') {
                        qStmt.run([quizId, 'IDENTIFICATION', 'What is the acronym for Last-In-First-Out?', 'LIFO', 'Stack property', null, 0, 0, 'H']);
                        qStmt.run([quizId, 'IDENTIFICATION', 'Type of list where the last node points back to the first node?', 'Circular Linked List', 'Looping structure', null, 0, 0, 'H']);
                    } 
                    else if (qInfo.type === 'CROSSWORD') {
                        // VERTICAL entry: ARRAY
                        qStmt.run([quizId, 'CROSSWORD', 'Fixed-size linear structure', 'ARRAY', '5 letters', null, 0, 0, 'V']);
                        // HORIZONTAL entry: STACK (crosses at index 0,0)
                        qStmt.run([quizId, 'CROSSWORD', 'LIFO structure', 'STACK', '5 letters', null, 0, 0, 'H']);
                    }

                    qStmt.finalize();
                });
            });
            console.log("🚀 Database fully synced with Data Structures content.");
        }
    });
}

module.exports = db;