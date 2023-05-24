use db_manager::DatabaseManager;
use student::Student;

mod db_manager;
mod hall;
mod student;
fn main() {
    let db = DatabaseManager::new();
    let students = db.read_students_table();
    let mut halls = db.read_halls_table();

    // TODO: allocate students

    db.write_report_table(&halls)
}
