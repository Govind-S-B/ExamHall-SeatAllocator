use crate::student::Student;
//hi
struct Hall {
    name: String,
    students: Vec<Option<Student>>,
}

impl Hall {
    pub fn new(name: String) -> Self {
        Self {
            name,
            students: vec![],
        }
    }

    pub fn add_student(&mut self, student: Student) {
        self.students.push(Some(student))
    }
    pub fn add_empty_seat(&mut self) {
        self.students.push(None)
    }
}
