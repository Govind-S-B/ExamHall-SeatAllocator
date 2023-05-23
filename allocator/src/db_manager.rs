use crate::student::{self, Student};
use sqlite as sq;
use std::{collections::hash_map::HashMap, vec};

pub struct DatabaseManager {
    connection: sq::Connection,
}

impl DatabaseManager {
    pub fn new() -> Self {
        Self {
            connection: sqlite::open("report.db").unwrap(),
        }
    }
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
