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


def distribute_students(subjects_json, hall_capacity):
        students_to_be_seated = 0
    for subject,student_list in subjects_json.items():
        students_to_be_seated += len(student_list)
    seating = {}
    for hall in hall_capacity:
        seating[hall] = []
    for hall,capacity in hall_capacity.items():

        subjects_in_consideration = [subject for subject in subjects_json.keys() if subjects_json[subject]] 
        biggest_subject = get_biggest_subject(subjects_json, subjects_in_consideration)
        subject_removed_flag = False

        for seat_no in range(capacity):
            if seat_no == capacity // 2 and subject_removed_flag is not True:
                subjects_in_consideration.remove(biggest_subject)
                biggest_subject = get_biggest_subject(subjects_json, subjects_in_consideration)

            if len(subjects_json[biggest_subject]) == 0:
                subjects_in_consideration.remove(biggest_subject)
                biggest_subject = get_biggest_subject(subjects_json, subjects_in_consideration)
                subject_removed_flag = True

            student = get_student_from_subject(subjects_json, biggest_subject)
            student.hall = hall
            seating[hall].append(student)

            students_to_be_seated -= 1
            if students_to_be_seated == 0:
                break


        seating[hall] = sorted(seating[hall], key=lambda x: x.subject)

    return seating


def generate_db():
    with open('Halls.json', 'r') as halls_file, open('Subjects.json') as subjects_file:
        halls_dict = json.load(halls_file)
        hall_capacity = {key:halls_dict["B"][key][0] * 2 for key in halls_dict["B"]} | ( \
                {key:halls_dict["D"][key][0] for key in halls_dict["D"]}
        )
        # hall_capacity is a dict mapping hall name to hall size

        subjects_json = json.load(subjects_file)
        subjects_json.pop("meta")
    

    total_capacity = sum(hall_capacity.values())
    if total_capacity < students_to_be_seated:
        raise OverflowError("too many students({students_to_be_seated}), not enough halls(capacity: {total_capacity})")

    seating = distribute_students(subjects_json, hall_capacity)


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
        try:
            input = f'INSERT INTO report (ID,CLASS,ROLL,HALL,SEAT_NO,SUBJECT) \
                    VALUES ("{s.id}","{s.college_class}",{s.roll_no},"{s.hall}",{s.seat},"{s.subject}")' 
            # print(input)
            cursor.execute(input)
        except sq.OperationalError as err:
            print(repr(err))

    db.commit()
    return db


def get_student_from_subject(roll_list, subject):
    student  = Student(roll_list[subject].pop(), subject)
    return student

def get_biggest_subject(roll_list, subjects_to_consider):
    return max(subjects_to_consider, key=lambda x: len(roll_list[x]))

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
