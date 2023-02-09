import json
import math
import sqlite3 as sq


class Student():
    ALL = []

    @classmethod
    def empty(cls, hall_name):
        return Student("EMPTY-0", "N/A", hall_name, 0)

    def __init__(self, id, subject, hall_name=None, seat_no=None):
        self.id = id
        college_class, roll_no = self.id.split("-") 
        self.college_class, self.roll_no = college_class, int(roll_no)
        self.subject = subject
        self.hall = hall_name
        self.seat = seat_no

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


def sort_dictionary(dict, reverse):
    keys = list(dict.keys())
    keys.sort(key=lambda key:dict[key], reverse=reverse)
    return {key:dict[key] for key in keys}


def generate_db():
    with open('Halls.json', 'r') as halls_file, open('Subjects.json') as subjects_file:
        hall_capacity = json.load(halls_file)
        # hall_capacity is a dict mapping hall name to hall size

        subjects_json = json.load(subjects_file)
        subjects_json.pop("meta")

        hall_capacity = sort_dictionary(hall_capacity, reverse=True)
    
    for subject, roll_list in subjects_json.items():
        for id in roll_list:
            _ = Student(id, subject)

    total_capacity = sum(hall_capacity.values())
    if total_capacity < len(Student.ALL):
        raise OverflowError(f"too many students({len(Student.ALL)}), not enough halls(capacity: {total_capacity})")

    seating = distribute_students(hall_capacity)


    for hall, capacity in hall_capacity.items():
        while len(seating[hall]) < capacity:
            seating[hall].append(None)

        seating[hall] = interleave(seating[hall])


        for seat_no, student in enumerate(seating[hall]):
            if student:
                student.hall = hall
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
        cursor.execute(input)



    db.commit()
    return db


def distribute_students(hall_capacity):

    students_to_be_seated = sorted(Student.ALL, key=lambda s: (s.college_class, s.roll_no))

    seating = {}
    for hall in hall_capacity:
        seating[hall] = []

    fill_all_halls_by_subject(hall_capacity, seating, students_to_be_seated)

    if len(students_to_be_seated) != 0:
        distribute_students_by_class(hall_capacity, students_to_be_seated, seating)

    if len(students_to_be_seated) != 0:
        students_to_be_seated.sort(key=lambda s: (s.college_class, s.roll_no), reverse=True)

        for hall, seat_list in seating.items():
            for seat_no, student in enumerate(seat_list):
                if student is None:
                    seat_list[seat_no] = students_to_be_seated.pop() 
                    


    return seating


def fill_all_halls_by_subject(hall_capacity, seating, students_to_be_seated):
    for hall,capacity in hall_capacity.items():
        fill_one_hall_by_subject(hall, capacity, seating, students_to_be_seated)
        seating[hall] = sorted(seating[hall], key=lambda x: (x.subject if x else "N/A"))
        if not students_to_be_seated:
            break


def fill_one_hall_by_subject(hall_name, capacity, seating, students_to_be_seated):

    subjects_in_consideration = set([student.subject for student in students_to_be_seated]) 
    biggest_subject = get_biggest_subject(students_to_be_seated, subjects_in_consideration)
    subject_removed_flag = False

    for seat_no in range(capacity):
        if seat_no == capacity // 2 and subject_removed_flag is not True:
            subjects_in_consideration.remove(biggest_subject)
            if len(subjects_in_consideration) == 0: 
                seating[hall_name] += [None for _ in range(capacity - seat_no)]
                break

            biggest_subject = get_biggest_subject(students_to_be_seated, subjects_in_consideration)

        if not any(student for student in students_to_be_seated if student.subject == biggest_subject):
            subjects_in_consideration.remove(biggest_subject)
            if len(subjects_in_consideration) == 0:  #this should only be true here if all students have been seated
                break

            biggest_subject = get_biggest_subject(students_to_be_seated, subjects_in_consideration)
            subject_removed_flag = True

        student = get_student_from_subject(students_to_be_seated, biggest_subject)
        # student.hall = hall_name
        seating[hall_name].append(student)


        if not students_to_be_seated:  # if students to be seated is an empty list
            break


def distribute_students_by_class(hall_capacity, students_to_be_seated, seating):
    for hall,capacity in hall_capacity.items():
        if None not in seating[hall]:
            continue
        for student in seating[hall]:
            if student:
                students_to_be_seated.append(student)
        seating[hall] = []
    
    students_to_be_seated.sort(key=lambda s: (s.college_class, s.roll_no))
    #as all students should have the same subject left now
    subject = students_to_be_seated[0].subject

    students_with_same_subject_as_class_name = []
    for student in students_to_be_seated:
        student.subject = student.college_class
        students_with_same_subject_as_class_name.append(student)

    # we don't have to consider halls that are already filled
    # and calling the function with nonempty halls will cause problems
    reduced_hall_capacity = {hall:capacity for hall,capacity in hall_capacity.items() if len(seating[hall]) == 0}
    fill_all_halls_by_subject(reduced_hall_capacity, seating, students_to_be_seated)

    for student in students_with_same_subject_as_class_name:
        student.subject = subject


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
        seating[hall] = [student.to_dict() for student in student_list if student]


    with open(f'Seating.json', 'w') as fp:

        json.dump(seating, fp, indent=4)

def test_seating():  # note results in false negative when empty seats exist 
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
