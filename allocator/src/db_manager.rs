use crate::student::Student;
use sqlite as sq;
use std::collections::hash_map::HashMap;

pub struct DatabaseManager {
    connection: sq::Connection,
}

impl DatabaseManager {
    pub fn new() -> Self {
        Self {
            connection: sqlite::open("report.db").unwrap(),
        }
    }
    // pub fn read_students_table() -> HashMap<String, Student> {}
}
