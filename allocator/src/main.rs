use db_manager::DatabaseManager;

mod db_manager;
mod hall;
mod student;
fn main() {
    let db = DatabaseManager::new();
    let students = db.read_students_table();
    let halls = db.read_halls_table();

    for hall in &halls {
        println!("{:?}", hall)
    }
}
