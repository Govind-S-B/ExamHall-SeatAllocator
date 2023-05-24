use crate::{
    hall::Hall,
    student::{self, Student},
};
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

    pub fn read_halls_table(&self) -> Vec<Hall> {
        let query = "SELECT * FROM halls ORDER BY capacity DESC";
        let mut halls: Vec<Hall> = vec![];
        self.connection
            .iterate(query, |pair| {
                //pair is an array slice of the columns and the values in the colums
                //first element of pair is ("id", <the id>)
                // second element is ("subject", <the subject>)
                let mut iter = pair.iter();
                let &(_, Some(hall_name)) = iter.next().unwrap()
                else {
                    panic!("DATABASE NOT VALID")
                };
                let &(_, Some(capacity)) = iter.next().unwrap()
                else {
                    panic!("DATABASE NOT VALID")
                };

                halls.push(Hall::new(hall_name, capacity.parse().unwrap()));

                true
            })
            .unwrap();
        halls
    }

    pub fn write_report_table(&self, halls: &Vec<Hall>) {
        let query = "DROP TABLE IF EXISTS report";
        self.connection
            .execute(query)
            .expect("error dropping report table");
        let query = "
                CREATE TABLE report 
                (id CHAR(15) PRIMARY KEY NOT NULL, 
                class CHAR(10) NOT NULL, 
                roll_no INT NOT NULL, 
                hall TEXT NOT NULL, 
                seat_no INT NOT NULL, 
                subject CHAR(50) NOT NULL)";

        self.connection
            .execute(query)
            .expect("error creating report table");

        let mut query =
            "INSERT INTO report (id,class,roll_no,subject,hall,seat_no) VALUES".to_owned();
        for hall in halls {
            for (index, student) in hall.students().iter().enumerate() {
                let Some(student) = student
                else {
                    continue;
                };

                let (id, class, roll_no, subject, hall_name, seat_no) = (
                    student.id(),
                    student.class(),
                    student.roll_no(),
                    student.subject(),
                    hall.name(),
                    index + 1,
                );
                query += &format!( 
                    "(\"{id}\", \"{class}\", {roll_no},\"{subject}\", \"{hall_name}\", {seat_no}),"
                );
            }
        }
        query.pop();
        query += ";";
        self.connection
            .execute(query)
            .expect("error inserting row into report table");
    }
}
