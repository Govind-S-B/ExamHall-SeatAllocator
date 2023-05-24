use crate::student::Student;
#[derive(Debug)]
pub struct Hall {
    name: String,
    capacity: usize,
    students: Vec<Option<Student>>,
}

impl Hall {
    pub fn new(name: &str, capacity: usize) -> Self {
        Self {
            name: name.to_owned(),
            capacity,
            students: vec![],
        }
    }

    pub fn add_student(&mut self, student: Student) -> Result<(), Student> {
        if self.students.len() < self.capacity {
            self.students.push(Some(student));
            Ok(())
        } else {
            Err(student)
        }
    }
    pub fn add_empty_seat(&mut self) -> Result<(), ()> {
        if self.students.len() < self.capacity {
            self.students.push(None);
            Ok(())
        } else {
            Err(())
        }
    }

    pub fn name(&self) -> &str {
        self.name.as_ref()
    }

    pub fn students(&self) -> &[Option<Student>] {
        self.students.as_ref()
    }
}
