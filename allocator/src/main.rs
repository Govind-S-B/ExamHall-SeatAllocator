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
}
fn main() {
    let db = DatabaseManager::new();
    let mut students: HashMap<String, Vec<Student>> = db.read_students_table();

    let mut halls: Vec<Hall> = db.read_halls_table();

    let total_seats: usize = halls.iter().map(|h| h.seats_left()).sum();
    let total_students: usize = students.values().map(|s| s.len()).sum();
    let mut extra_seats = match total_seats >= total_students {
        true => total_seats - total_students,
        false => panic!("ERROR: more students than seats"),
    };
    let mut allocation_mode = AllocationMode::SeperateSubject;
    let mut placed_keys = HashSet::new();
    let seated_students: Vec<&Student> = Vec::with_capacity(total_students);
    'main: for hall in &mut halls {
        if students.is_empty() {
            break;
        };

        while !hall.is_full() && !students.is_empty() {
            let Some(next_student) = get_next_student(&mut students, hall, &mut placed_keys)
            else {
                use AllocationMode::*;
                if extra_seats == 0 {
                    allocation_mode = match allocation_mode {
                        SeperateSubject => {
                            placed_keys = seated_students
                                .iter()
                                .map(|s| s.class().to_owned())
                                .collect();
                            students = students
                                .into_values()
                                .flatten()
                                .fold(HashMap::new(), |mut map, student| {
                                    map.entry(student.class().to_owned()).or_default().push(student);
                                    map
                                });
                            SeperateClass
                        },
                        SeperateClass => break 'main,
                    };
                } else {
                    hall.push_empty().expect("tried to push empty on full hall (error should never happer)");
                    extra_seats -= 1;
                }
                continue;
            };

            hall.push(next_student)
                .expect("tried to push student into full hall");
        }
    }

    // ANY mode
    if !students.is_empty() {
        let mut students = students.into_values().flatten().collect::<Vec<Student>>();

        for hall in &mut halls {
            while !hall.is_full() && !students.is_empty() {
                hall.push(students.pop().unwrap())
                    .expect("tried to push student into full hall");
            }
        }
    }
    db.write_report_table(&halls)
}

fn get_next_student(
    students: &mut HashMap<String, Vec<Student>>,
    hall: &mut Hall,
    placed_keys: &mut HashSet<String>,
) -> Option<Student> {
    let next_key = get_next_key(students, hall, placed_keys)?;

    let students_in_key = students
        .get_mut(&next_key)
        .expect("trying to take a student from subject that doesn't exist");

    let next_student = students_in_key
        .pop()
        .expect("trying to take student from empty subject list");

    if students_in_key.is_empty() {
        students.remove(&next_key);
    }
    hall.previously_placed_key = Some(next_key.clone());
    placed_keys.insert(next_key);

    Some(next_student)
}

fn get_next_key(
    students: &HashMap<String, Vec<Student>>,
    hall: &Hall,
    placed_keys: &HashSet<String>,
) -> Option<String> {
    let filtered = students
        .iter()
        .map(|(key, vec)| (key, vec.len()))
        .filter(|(key, size)| Some(*key) != hall.previously_placed_key.as_ref() && *size > 0);

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
/*




*/
