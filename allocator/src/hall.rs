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
    pub previously_placed_key: Option<String>,
}

impl Hall {
    /// Creates a new [`Hall`].
    pub fn new(name: &str, capacity: usize) -> Self {
        Self {
            name: name.to_owned(),
            capacity,
            students: Vec::with_capacity(capacity),
            previously_placed_key: None,
        }
    }

    /// adds a student to the hall
    ///
    /// # Errors
    ///
    /// This function will return an error if the hall is full
    pub fn push(&mut self, student: Student) -> Result<(), Student> {
        match self.is_full() {
            false => {
                self.students.push(Some(student));
                Ok(())
            }
            true => Err(student),
        }
    }
    pub fn push_empty(&mut self) -> Result<(), ()> {
        if !self.is_full() {
            self.students.push(None);
            self.previously_placed_key = None;
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

    pub fn is_full(&self) -> bool {
        self.students.len() >= self.capacity
    }

    pub fn seats_left(&self) -> usize {
        self.capacity - self.students.len()
    }
}
