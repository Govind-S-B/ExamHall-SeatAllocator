mod db_manager;
mod hall;
mod student;
use std::collections::{HashMap, HashSet};

use db_manager::DatabaseManager;
use hall::Hall;
use student::Student;

// TODO: exit codes
enum AllocationMode {
    SeperateSubject,
    SeperateClass,
    Any,
}
fn main() {
    let db = DatabaseManager::new();
    let mut students: HashMap<String, Vec<Student>> = db.read_students_table();
    let mut halls: Vec<Hall> = db.read_halls_table();

    let total_seats: usize = halls.iter().map(|h| h.seats_left()).sum();
    let total_students: usize = students.values().map(|s| s.len()).sum();
    let mut extra_seats = match total_seats > total_students {
        true => total_seats - total_students,
        false => panic!("ERROR: more students than seats"),
    };
    let mut allocation_mode = AllocationMode::SeperateSubject;
    let mut placed_subjects = HashSet::new();
    for hall in &mut halls {
        if students.is_empty() {
            break;
        };

        while !hall.is_full() && !students.is_empty() {
            // TODO: write get_next_student() -> Option<Student>
            /*
            if extra_seats == 0 {
                todo!();
            }
            hall.push_empty().expect("tried to push empty on full hall");
            extra_seats -= 1;
            continue;
                         */

            let Some(next_student) = get_next_student(&mut students, hall, &placed_subjects, &allocation_mode)
            else {
                use AllocationMode::*;
                if extra_seats == 0 {
                    allocation_mode = match allocation_mode {
                        SeperateSubject => SeperateClass,
                        SeperateClass => Any,
                        Any => panic!("ERROR:tried to push empty in 'Any' mode"),
                    };
                continue;
                };
                hall.push_empty().expect("tried to push empty on full hall (error should never happer)");
                extra_seats -= 1;
                continue;
            };

            placed_subjects.insert(next_student.subject().to_owned());
            hall.push(next_student)
                .expect("tried to push student into full hall");
        }
    }

    db.write_report_table(&halls)
}

fn get_next_student(
    students: &mut HashMap<String, Vec<Student>>,
    hall: &mut Hall,
    placed_subjects: &HashSet<String>,
    allocation_mode: &AllocationMode,
) -> Option<Student> {
    let next_sub = match get_next_sub(students, hall, placed_subjects) {
        Some(sub) => sub,
        None => todo!(),
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

    Some(next_student)
}

fn get_next_sub(
    students: &HashMap<String, Vec<Student>>,
    hall: &Hall,
    placed_subjects: &HashSet<String>,
) -> Option<String> {
    let filtered = students
        .iter()
        .map(|(sub, vec)| (sub, vec.len()))
        .filter(|(sub, size)| Some(*sub) != hall.prev_sub() && *size > 0);

    let further_filtered: Vec<(&String, usize)> = filtered
        .clone()
        .filter(|(sub, _)| placed_subjects.contains(sub.to_owned()))
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
/*




*/
