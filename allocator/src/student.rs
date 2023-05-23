struct Student {
    id: String,
    class: String,
    roll_no: i32,
    subject: String,
}

impl Student {
    fn new(id: String, subject: String) -> Self {
        let id_clone = id.clone();
        let (class, roll_no) = id_clone.split_once('-').expect("invalid id format");
        let roll_no: i32 = roll_no.parse().expect("invalid roll number");
        let class = class.to_owned();
        Self {
            id,
            class,
            roll_no,
            subject,
        }
    }
}
