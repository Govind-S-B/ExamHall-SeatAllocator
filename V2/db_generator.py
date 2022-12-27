import json
import math
import sqlite3 as sq
# don't know how many colums
# know how many benches
# benches have 2 seats per person
# try to not have too many subjects in 1 class
# 

class Student():
    ALL = []
    def __init__(self, id, subject):
        self.id = id
        self.college_class, self.roll_no = self.id.split("-") 
        self.subject = subject
        self.hall = None
        self.seat = None

        Student.ALL.append(self)

    def to_dict(self):
        return {
            'id'     : self.id,
            'class'  : self.college_class,
            'roll_no': self.roll_no,
            'subject': self.subject,
            'hall'   : self.hall,
            'seat'   : self.seat
        }


def generate_db():
    with open('Halls.json', 'r') as halls_file, open('Subjects.json') as subjects_file:
        halls_dict = json.load(halls_file)
        hall_capacity = {key:halls_dict["B"][key][0] * 2 for key in halls_dict["B"]} | ( \
                {key:halls_dict["D"][key][0] for key in halls_dict["D"]}
        )
        # hall_capacity is a dict mapping hall name to hall size
        # hall_capacity is a dict mapping hall name to hall size

        subjects_json = json.load(subjects_file)
        subjects_json.pop("meta")
    
    for subject, roll_list in subjects_json.items():
        for id in roll_list:
            _ = Student(id, subject)

    total_capacity = sum(hall_capacity.values())
    if total_capacity < len(Student.ALL):
        raise OverflowError("too many students({students_to_be_seated}), not enough halls(capacity: {total_capacity})")

    seating = distribute_students(hall_capacity)


    for hall,capacity in hall_capacity.items():
        seating[hall] = interleave(seating[hall])

        for seat_no, student in enumerate(seating[hall]):
            student.seat = seat_no + 1

    # generate_seating_json(seating)

    db = sq.connect('report.db')
    cursor = db.cursor()

    cursor.execute( " \
            DROP TABLE IF EXISTS report\
        ")

    cursor.execute('CREATE TABLE report \
                ("ID" CHAR(15) PRIMARY KEY NOT NULL, \
                "CLASS" CHAR(10) NOT NULL, \
                "ROLL" INT NOT NULL, \
                "HALL" TEXT NOT NULL, \
                "SEAT_NO" INT NOT NULL, \
                "SUBJECT" CHAR(50) NOT NULL);')


    for s in Student.ALL:  # s is a student
        input = f'INSERT INTO report (ID,CLASS,ROLL,HALL,SEAT_NO,SUBJECT) \
                VALUES ("{s.id}","{s.college_class}",{s.roll_no},"{s.hall}",{s.seat},"{s.subject}")' 
        try:
            # print(input)
            cursor.execute(input)
        except sq.OperationalError as err:
            # print(repr(err))
            # print(input)
            ...

    db.commit()
    generate_seating_json(seating)
    test_seating()
    return db


def fill_hall_by_subject(hall_name, capacity, seating, students_to_be_seated):

    subjects_in_consideration = set([student.subject for student in students_to_be_seated]) 
    # print(subjects_in_consideration)
    biggest_subject = get_biggest_subject(students_to_be_seated, subjects_in_consideration)
    subject_removed_flag = False

    for seat_no in range(capacity):
        if seat_no == capacity // 2 and subject_removed_flag is not True:
            subjects_in_consideration.remove(biggest_subject)
            biggest_subject = get_biggest_subject(students_to_be_seated, subjects_in_consideration)

        if not any(student for student in students_to_be_seated if student.subject == biggest_subject):
            subjects_in_consideration.remove(biggest_subject)
            if len(subjects_in_consideration) == 0:
                break

            biggest_subject = get_biggest_subject(students_to_be_seated, subjects_in_consideration)
            subject_removed_flag = True

        student = get_student_from_subject(students_to_be_seated, biggest_subject)
        student.hall = hall_name
        seating[hall_name].append(student)


        if not students_to_be_seated:  # if students to be seated is an empty list
            break


def distribute_students(hall_capacity):
    students_to_be_seated = Student.ALL.copy()

    seating = {}
    for hall in hall_capacity:
        seating[hall] = []

    for hall,capacity in hall_capacity.items():
        fill_hall_by_subject(hall, capacity, seating, students_to_be_seated)
        seating[hall] = sorted(seating[hall], key=lambda x: (x.subject))
        if not students_to_be_seated:
            break

    return seating



def get_student_from_subject(students_to_be_seated, subject):
    student_index = next(iter([i for i in range(len(students_to_be_seated)) if students_to_be_seated[i].subject == subject]))
    student = students_to_be_seated.pop(student_index)
    return student

def get_biggest_subject(students_to_be_seated, subjects_to_consider):
    return max(subjects_to_consider, key=lambda sub: len([student for student in students_to_be_seated if student.subject == sub]))

def interleave(array):
    midpoint_index = math.ceil(len(array)/2)
    first = array[:midpoint_index]
    second = array[midpoint_index:]


    separated_array = []
    for _ in range(len(second)):
        separated_array.append(first.pop())
        separated_array.append(second.pop())
    if first:
        separated_array.append(first.pop())

    return separated_array

def generate_seating_json(seating):
    seating = seating.copy()
    for hall,student_list in seating.items():
        seating[hall] = [student.to_dict() for student in student_list]


    with open(f'Seating.json', 'w') as fp:

        json.dump(seating, fp, indent=4)

def test_seating():
    with open('Seating.json', 'r') as seating_file:
        seating_dict = json.load(seating_file)
        for hall, student_list in seating_dict.items():
            sub1 = None
            sub2 = None
            for student in student_list:
                sub2 = sub1
                sub1 = student["subject"]
                if sub1 == sub2:
                    print(student)
                    pass
