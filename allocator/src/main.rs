use db_manager::DatabaseManager;

mod db_manager;
mod hall;
mod student;
fn main() {
    let db = DatabaseManager::new();
    let students = db.read_students_table();
    for (subject, student_list) in &students {
        println!("{}", subject.to_uppercase());
        for student in student_list {
            println!("\t{:?}", student)
        }
    }
}
