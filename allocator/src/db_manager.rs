use crate::student::{self, Student};
use sqlite as sq;
use std::{collections::hash_map::HashMap, vec};

pub struct DatabaseManager {
    connection: sq::Connection,
}

impl DatabaseManager {
    /// Creates a new [`DatabaseManager`].
    ///
    /// the connection is made with `report.db`
    /// # Panics
    ///
    /// Panics if `report.db` does not exist
    pub fn new() -> Self {
        Self {
            connection: sqlite::open("report.db").unwrap(),
        }
    }
    /// Returns a Hashmap whose keys are subjects and values are a
    /// vector of students that have that subject
    ///
    /// # Panics
    ///
    /// Panics if the database is not in the right format
    ///
    /// the first column should be id and the second column should be subject
    ///
    pub fn read_students_table(&self) -> HashMap<String, Vec<Student>> {
        let query = "SELECT * FROM students";
        let mut students: HashMap<String, Vec<Student>> = HashMap::new();
        self.connection
            .iterate(query, |pair| {
                //pair is an array slice of the columns and the values in the colums
                //first element of pair is ("id", <the id>)
                // second element is ("subject", <the subject>)
                let mut iter = pair.iter();
                let &(_, Some(id)) = iter.next().unwrap()
                else {
                    panic!("DATABASE NOT VALID")
                };
                let &(_, Some(subject)) = iter.next().unwrap()
                else {
                    panic!("DATABASE NOT VALID")
                };

                let student = Student::new(id.to_owned(), subject.to_owned());

                match students.get_mut(subject) {
                    Some(vec) => vec.push(student),
                    None => {
                        students.insert(subject.to_owned(), vec![student]);
                    }
                }
                true
            })
            .unwrap();
        students
    }
}
