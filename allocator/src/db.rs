use crate::{hall::Hall, student::Student};
use sq::Connection;
use sqlite as sq;
use std::collections::hash_map::HashMap;

pub fn read_halls_table(conn: &Connection) -> Vec<Hall> {
    let query = "SELECT * FROM halls ORDER BY capacity DESC";
    let mut halls: Vec<Hall> = vec![];
    conn.iterate(query, |pair| {
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
pub fn read_students_table(conn: &Connection) -> HashMap<String, Vec<Student>> {
    let query = "SELECT * FROM students";
    let mut students: HashMap<String, Vec<Student>> = HashMap::new();
    conn.iterate(query, |pair| {
        //pair is an array slice of the columns and the values in the colums
        //first element of pair is the tuple ("id", <the id>)
        // second element is the tuple ("subject", <the subject>)
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

    for students_vec in students.values_mut() {
        students_vec.sort_by_key(|s| (s.class().to_owned(), -s.roll_no()))
    }
    students
}
pub fn write_report_table(conn: &Connection, halls: &Vec<Hall>) {
    let query = "DROP TABLE IF EXISTS report";
    conn.execute(query).expect("error dropping report table");
    let command = "
                CREATE TABLE report 
                (id CHAR(15) PRIMARY KEY NOT NULL, 
                class CHAR(10) NOT NULL, 
                roll_no INT NOT NULL, 
                hall TEXT NOT NULL, 
                seat_no INT NOT NULL, 
                subject CHAR(50) NOT NULL)";

    conn.execute(command).expect("error creating report table");

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
    conn.execute(command)
        .expect("error inserting row into report table");
}
