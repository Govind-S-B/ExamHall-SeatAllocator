mod db_manager;
mod hall;
mod student;
use std::{collections::HashMap, hash::Hash};

use db_manager::DatabaseManager;
use student::Student;

fn main() {
    let db = DatabaseManager::new();
    let mut students = db.read_students_table();
    let mut halls = db.read_halls_table();

    for hall in &mut halls {
        let previously_placed_sub: Option<&str> = None;

        while !hall.is_full() {
            let next_sub = get_next_sub(&students, previously_placed_sub);
            let students_in_sub = students
                .get_mut(next_sub)
                .expect("trying to take a student from subject that doesn't exist");

            let next_student = students_in_sub
                .pop()
                .expect("trying to take student from empty subject list");

            if students_in_sub.is_empty() {
                students.remove(next_sub);
            }

            hall.push(next_student)
                .expect("tried to push student into full hall")
        }
    }

    db.write_report_table(&halls)
}

fn get_next_sub<'a>(
    students: &'a HashMap<String, Vec<Student>>,
    prev_sub: Option<&str>,
) -> &'a str {
    println!("{:#?}", students);
    let filtered = students
        .iter()
        .filter(|(sub, vec)| Some(sub.as_ref()) == prev_sub)
        .collect::<HashMap<_, _>>();
    println!("{:#?}", students);
    todo!()
}
