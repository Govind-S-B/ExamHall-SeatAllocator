use crate::{
    hall::Hall,
    student::Student,
};
use sqlite as sq;
use std::{collections::hash_map::HashMap, vec};

/// [`DatabaseManager`] is a struct that represents a connection to a SQLite database.
///
/// [[`DatabaseManager`]] provides methods for interacting with the "report" and "input" SQLite database.
/// These methods include reading data from the "students" and "halls" tables (`read_students_table`, `read_halls_table`),
/// and writing data to the "report" table (`write_report_table`).
///
/// # Fields
///
///- `connection` - Represents the connection to the SQLite database.

pub struct DatabaseManager {
    read_connection: sq::Connection,
    write_connection: sq::Connection,
}

impl DatabaseManager {
    /// Creates a new instance of [`DatabaseManager`] with a connection to the "report.db" and "input" SQLite database.
    ///
    /// # Panics
    ///
    /// This function will panic if it cannot open a connection to "report.db" and "input". Ensure that "report.db" and "input" exists in the
    /// same directory as your binary.
    ///
    /// # Returns
    ///
    /// Returns a [`DatabaseManager`] instance with an open connection to "report.db" and "input".
    ///
    pub fn new() -> Self {
        Self {
            read_connection: sqlite::open("input.db").expect("Error connecting to input.db"),
            write_connection: sqlite::open("report.db").expect("Error connecting to report.db"),
        }
    }
/// `read_students_table` is a method that reads data from a database table named "students".
///
/// This method queries all rows from the "students" table. 
/// It then iterates through each returned row, creating a new [`Student`] struct from the data 
/// and adding it to a HashMap keyed by the "subject".
///
/// # Arguments
///
//// - [`&self`] - A reference to the instance of the struct that this method is being called on. 
///
/// # Returns
///
/// A [`HashMap<String, Vec<Student>>`] - A HashMap where each key is a "subject" and the value is a 
/// vector of [`Student`] structs that belong to that subject.
///
/// # Schema
///
/// The "students" table is assumed to have at least the following schema:
///
//// - `id` - A TEXT field.
//// - `subject` - A TEXT field.
///
/// The order of columns in the table must be ("id", "subject").
///
/// # Panics
///
/// This method will panic under the following conditions:
///
/// - If there is an error iterating over the rows returned by the query.
/// - If the database does not match the expected schema, specifically if a row does not have an "id" or "subject" field.
    pub fn read_students_table(&self) -> HashMap<String, Vec<Student>> {
        let query = "SELECT * FROM students";
        let mut students: HashMap<String, Vec<Student>> = HashMap::new();
        self.read_connection
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


        for (sub, students_vec) in students.iter_mut() {
            students_vec.sort_by_key(|s| (s.class().to_owned(), -s.roll_no()))
        }
        students
    }

/// ``read_halls_table`` is a method that reads data from a database table named "halls".
///
/// This method queries all rows from the "halls" table, ordered by the "capacity" field in descending order.
/// It then iterates through each returned row, creating a new [`Hall`] struct from the data and adding it to a vector.
///
/// # Returns
///
/// A `Vec<Hall>` - A vector of `Hall` structs, where each `Hall` corresponds to a row in the "halls" table.
///
/// # Schema
///
/// The "halls" table is assumed to have at least the following schema:
///
/// - [`hall_name`] - A TEXT field.
/// - `capacity` - An INT field.
///
/// The order of columns in the table must be ("hall_name", "capacity").
///
/// # Panics
///
/// This method will panic under the following conditions:
///
/// - If there is an error iterating over the rows returned by the query.
/// - If the database does not match the expected schema, specifically if a row does not have a "hall_name" or "capacity" field.
/// - If the "capacity" field cannot be parsed into an integer.
///
    pub fn read_halls_table(&self) -> Vec<Hall> {
        let query = "SELECT * FROM halls ORDER BY capacity DESC";
        let mut halls: Vec<Hall> = vec![];
        self.read_connection
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

/// `write_report_table` is a method that handles the creation and population of a database table called "report".
///
/// This method drops the existing "report" table if it exists, then creates a new one with the specified schema.
/// The table is then populated with student data from a provided list of [`Hall`] structs.
/// Each student's data is inserted as a new row in the table.
///
/// # Arguments
///
/// - `halls` - A reference to a vector of `Hall` structs, each containing student data to be inserted into the table.
///
/// # Schema
///
/// The "report" table has the following schema:
///
/// - `id` - A CHAR(15) that serves as the primary key. It cannot be NULL.
/// - `class` - A CHAR(10) that cannot be NULL.
/// - `roll_no` - An INT that cannot be NULL.
/// - `hall` - A TEXT field that cannot be NULL.
/// - `seat_no` - An INT that cannot be NULL.
/// - `subject` - A CHAR(50) that cannot be NULL.
///
/// # Panics
///
/// This method will panic under the following conditions:
///
/// - If there is an error dropping the existing "report" table.
/// - If there is an error creating the new "report" table.
/// - If there is an error inserting rows into the "report" table.
    pub fn write_report_table(&self, halls: &Vec<Hall>) {
        let query = "DROP TABLE IF EXISTS report";
        self.write_connection
            .execute(query)
            .expect("error dropping report table");
        let command = "
                CREATE TABLE report 
                (id CHAR(15) PRIMARY KEY NOT NULL, 
                class CHAR(10) NOT NULL, 
                roll_no INT NOT NULL, 
                hall TEXT NOT NULL, 
                seat_no INT NOT NULL, 
                subject CHAR(50) NOT NULL)";

        self.write_connection
            .execute(command)
            .expect("error creating report table");

        let mut command =
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
                command += &format!( 
                    "(\"{id}\", \"{class}\", {roll_no},\"{subject}\", \"{hall_name}\", {seat_no}),"
                );
            }
        }
        command.pop();
        command += ";";
        self.write_connection
            .execute(command)
            .expect("error inserting row into report table");
    }
}
