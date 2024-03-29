use crate::student::Student;
#[derive(Debug)]

/// `Hall` is a struct that represents a hall with a certain capacity and a list of students.
///
/// # Fields
///
/// - `name` - Represents the name of the hall.
/// - `capacity` - Represents the maximum number of students the hall can accommodate.
/// - `students` - Represents a list of students currently in the hall. This list can include empty seats (represented as `None`).

pub struct Hall {
    name: String,
    capacity: usize,
    students: Vec<Option<Student>>,
}

impl Hall {
    /// Creates a new [`Hall`].
    pub fn new(name: &str, capacity: usize) -> Self {
        Self {
            name: name.to_owned(),
            capacity,
            students: Vec::with_capacity(capacity),
        }
    }

    /// adds a student to the hall
    ///
    /// # Errors
    ///
    /// This function will return an error if the hall is full
    pub fn push(&mut self, student: Student) -> Result<(), Student> {
        if self.is_full() {
            Err(student)
        } else {
            self.students.push(Some(student));
            Ok(())
        }
    }
    pub fn push_empty(&mut self) -> Result<(), ()> {
        if self.is_full() {
            Err(())
        } else {
            self.students.push(None);
            Ok(())
        }
    }

    pub fn name(&self) -> &str {
        self.name.as_ref()
    }

    pub fn students(&self) -> &[Option<Student>] {
        self.students.as_ref()
    }

    pub fn is_full(&self) -> bool {
        self.students.len() >= self.capacity
    }

    pub fn seats_left(&self) -> usize {
        self.capacity - self.students.len()
    }

    pub fn capacity(&self) -> usize {
        self.capacity
    }
}
