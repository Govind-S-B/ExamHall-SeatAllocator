mod args;
mod db_manager;
mod hall;
mod student;

use rand::seq::SliceRandom;
use std::collections::{HashMap, HashSet};
use student::Student;

enum AllocationMode {
    SeperateSubject,
    SeperateClass,
}
fn main() {
    let args = args::get();

    let conn = sqlite::open(args.input_db_path).expect("Error connecting to input.db");
    let mut students = db_manager::read_students_table(&conn);
    let mut halls = db_manager::read_halls_table(&conn);
    if args.randomize {
        halls.shuffle(&mut rand::thread_rng())
    }

    let mut allocation_mode = AllocationMode::SeperateSubject;
    // the 'key' of the previously placed student
    // it's None if a seat was left empty previously
    let mut previously_placed_key: Option<String> = None;
    let mut placed_keys = HashSet::new();

    let mut extra_seats = {
        let total_seats: usize = halls.iter().map(|h| h.seats_left()).sum();
        let total_students: usize = students.values().map(|s| s.len()).sum();

        if total_students > total_seats {
            panic!("ERROR: more students than seats")
        }
        total_seats - total_students
    };

    'main: for hall in &mut halls {
        if students.is_empty() {
            break;
        };

        while !hall.is_full() && !students.is_empty() {
            // happy path, student is added to hall
            if let Some(next_key) =
                get_next_key(&students, &placed_keys, previously_placed_key.as_ref())
            {
                let next_student = get_next_student(&mut students, &next_key);

                hall.push(next_student)
                    .expect("tried to push student into full hall");
                placed_keys.insert(next_key.clone());
                previously_placed_key = Some(next_key);
                continue;
            }

            // run out of subjects and now must leave empty seats between students
            if extra_seats > 0 {
                hall.push_empty()
                    .expect("tried to push empty on full hall (error should never happer)");
                previously_placed_key = None;
                extra_seats -= 1;
                continue;
            }

            // if there are no extra seats left and no classes to seperate students by, switch to 'any' mode
            // that is, give up on seperating students
            if let AllocationMode::SeperateClass = allocation_mode {
                break 'main;
            }

            // if the allocation mode is currently on 'seperate subject'
            // switch to seperating by class and adjust the students dict,
            // placed keys and previously placed key to reglect this
            allocation_mode = AllocationMode::SeperateClass;
            placed_keys.clear();
            previously_placed_key = hall
                .students()
                .last()
                .unwrap_or(&None)
                .as_ref()
                .map(|s| s.class().to_owned());
            students = students
                .into_values()
                .flatten()
                .fold(HashMap::new(), |mut map, student| {
                    map.entry(student.class().to_owned())
                        .or_default()
                        .push(student);
                    map
                });
        }
    }

    // ANY mode
    let mut students: Vec<Student> = students.into_values().flatten().collect();
    for hall in &mut halls {
        let Some(student) = students.pop()
        else {
            break
        };
        if let Err(student) = hall.push(student) {
            students.push(student);
            continue;
        }
    }

    let conn = sqlite::open(args.output_db_path).expect("Error connecting to report.db");
    db_manager::write_report_table(&conn, &halls);
}
/// also clears entries as they get empty
fn get_next_student(students: &mut HashMap<String, Vec<Student>>, key: &str) -> Student {
    let students_in_key = students
        .get_mut(key)
        .expect("trying to take a student from subject that doesn't exist");

    let next_student = students_in_key
        .pop()
        .expect("trying to take student from empty subject list");

    if students_in_key.is_empty() {
        students.remove(key);
    }

    next_student
}

fn get_next_key(
    students: &HashMap<String, Vec<Student>>,
    placed_keys: &HashSet<String>,
    previously_placed_key: Option<&String>,
) -> Option<String> {
    let filtered = students
        .iter()
        .map(|(key, vec)| (key, vec.len()))
        .filter(|(key, size)| Some(*key) != previously_placed_key && *size > 0);

    let further_filtered: Vec<(&String, usize)> = filtered
        .clone()
        .filter(|(key, _)| placed_keys.contains(key.to_owned()))
        .collect();

    let students = if further_filtered.is_empty() {
        filtered.collect()
    } else {
        further_filtered
    };

    Some(
        students
            .into_iter()
            .max_by_key(|(_, size)| *size)?
            .0
            .clone(),
    )
}
