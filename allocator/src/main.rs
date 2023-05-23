use db_manager::DatabaseManager;

mod db_manager;
mod hall;
mod student;
fn main() {
    let db = DatabaseManager::new();
}
