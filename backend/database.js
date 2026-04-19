const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Connect to (or create) the SQLite database file
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

        // 2. RECITATION LOGS TABLE
        db.run(`CREATE TABLE IF NOT EXISTS recitation_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_name TEXT NOT NULL,
            subject_code TEXT NOT NULL,
            stars INTEGER,
            points INTEGER,
            comment TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )`, (err) => {
            if (!err) {
                seedInitialData();
            }
        });
    });
}

// --- SEED DATA ---
function seedInitialData() {
    // We check for 'CPE 401' specifically to see if we need to fix the data
    db.get("SELECT COUNT(*) as count FROM students WHERE subject_code = 'CPE 401'", (err, row) => {
        if (row && row.count === 0) {
            console.log("🌱 Cleaning and Seeding fresh student data...");
            
            // Clear old data to prevent duplicates or mismatched codes
            db.run("DELETE FROM students");

            const stmt = db.prepare("INSERT INTO students (name, subject_code, is_present) VALUES (?, ?, ?)");
            
            // FIXED: Added spaces to match your Flutter UI "CPE 401"
            const demoStudents = [
                ['Jet Hinks', 'CPE 401', 1],
                ['Maria Garcia', 'CPE 401', 1],
                ['Tony Hugh', 'CPE 401', 1],
                ['Alex Johnson', 'CPE 401', 1],
                ['Samuel Pru', 'CPE 401', 1],
                ['Claire Rey', 'IT 102', 1] 
            ];

            demoStudents.forEach(student => stmt.run(student));
            stmt.finalize();
            console.log("🚀 Database ready with correctly formatted subject codes.");
        }
    });
}

module.exports = db;