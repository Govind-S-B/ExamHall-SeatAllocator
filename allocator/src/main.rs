mod db_manager;
mod hall;
mod student;
use std::{collections::HashMap, hash::Hash, io::stdin};

use db_manager::DatabaseManager;
use hall::Hall;
use student::Student;

fn main() {
    let db = DatabaseManager::new();
    let mut students = db.read_students_table();
    let mut halls = db.read_halls_table();

    for hall in &mut halls {
        if students.is_empty() {
            break;
        };

        while !hall.is_full() && !students.is_empty() {
            let next_sub = match get_next_sub(&students, &hall) {
                Some(sub) => sub,
                None => {
                    hall.push_empty().expect("tried to push empty on full hall");
                    continue;
                }
            };

            let students_in_sub = students
                .get_mut(&next_sub)
                .expect("trying to take a student from subject that doesn't exist");

            let next_student = students_in_sub
                .pop()
                .expect("trying to take student from empty subject list");

            if students_in_sub.is_empty() {
                students.remove(&next_sub);
            }

            hall.push(next_student)
                .expect("tried to push student into full hall");
        }
    }

    db.write_report_table(&halls)
}

fn get_next_sub(students: &HashMap<String, Vec<Student>>, hall: &Hall) -> Option<String> {
    let filtered: Vec<(&String, usize)> = students
        .iter()
        .map(|(sub, vec)| (sub, vec.len()))
        .filter(|(sub, size)| Some(*sub) != hall.prev_sub() && *size > 0)
        .collect();

    let further_filtered: Vec<(&String, usize)> = filtered
        .clone()
        .into_iter()
        .filter(|(sub, vec)| hall.subjects().contains(sub.to_owned()))
        .collect();

    let students = if further_filtered.is_empty() {
        filtered
    } else {
        further_filtered
    };

    Some(
        students
            .into_iter()
            .max_by_key(|(sub, size)| *size)?
            .0
            .clone(),
    )
}
