use db_manager::DatabaseManager;
use student::Student;

mod db_manager;
mod hall;
mod student;
fn main() {
    let db = DatabaseManager::new();
    let students = db.read_students_table();
    let mut halls = db.read_halls_table();
    let mut students: Vec<Student> = students
        .into_iter()
        .map(|(sub, vec)| vec)
        .flatten()
        .collect();

    'outer: for hall in &mut halls {
        while let Ok(()) = hall.add_student(students.pop().unwrap()) {
            if students.len() == 0 {
                break 'outer;
            }
        }
    }

    println!("done");
    db.write_report_table(&halls)
}
