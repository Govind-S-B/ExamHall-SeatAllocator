import sqlite3 as sq
import itertools

# PDF_list = []
# roll_list = []
# class_name = Q_list[0][0]
# hall_name = Q_list[0][1]

# for i in Q_list:
#     if class_name == i[0]:

#         if hall_name == i[1]:
#             roll_list.append(i[2])
#         else:
#             # maybe class name also needs to be rest
#             PDF_list.append([class_name, hall_name, str(roll_list)[1:-1]])
#             hall_name = i[1]
#             roll_list = []
#             roll_list.append(i[2])

#     else:
#         PDF_list.append([class_name, hall_name, str(roll_list)[1:-1]])
#         class_name = i[0]
#         hall_name = i[1]
#         roll_list = []
#         roll_list.append(i[2])

#     if Q_list[-1] == i:
#         PDF_list.append([class_name, hall_name, str(roll_list)[1:-1]])


# packaging PDF

def ranges(i):
    for a, b in itertools.groupby(enumerate(i), lambda pair: pair[1] - pair[0]):
        b = list(b)
        yield b[0][1], b[-1][1]


conn = sq.connect("report.db")

cmd = """SELECT HALL,CLASS,SUBJECT,ROLL
         FROM REPORT
         ORDER BY HALL,CLASS, SUBJECT"""
cursor = conn.execute(cmd)
Q_list = cursor.fetchall()
packaging_list = [["Class", "Hall", "RollNo"]]

PDF_list = []
roll_list = []
hall_name = Q_list[0][0]
class_name = Q_list[0][1]
subject_name = Q_list[0][2]

for i in Q_list:
    if hall_name == i[0]:

        if class_name == i[1]:

            if subject_name == i[2]:
                roll_list.append(i[3])

            else:
                roll_ = ranges(roll_list)
                PDF_list.append(
                    [hall_name, class_name, subject_name, list(roll_)])
                subject_name = i[2]
                roll_list = []
                roll_list.append(i[3])

        else:
            # maybe class name also needs to be rest
            roll_ = ranges(roll_list)
            PDF_list.append([hall_name, class_name, subject_name, list(roll_)])
            class_name = i[1]
            subject_name = i[2]
            roll_list = []
            roll_list.append(i[3])

    else:
        roll_ = ranges(roll_list)
        PDF_list.append([hall_name, class_name, subject_name, list(roll_)])
        hall_name = i[0]
        class_name = i[1]
        roll_list = []
        roll_list.append(i[3])

    if Q_list[-1] == i:
        roll_ = ranges(roll_list)
        PDF_list.append([hall_name, class_name, subject_name, list(roll_)])

# Seating PDF

cmd = """SELECT HALL,SEAT_NO,ID
         FROM REPORT
         ORDER BY HALL,SEAT_NO"""
cursor = conn.execute(cmd)
x = cursor.fetchall()
seat_list = []
for i in x:
    seat_list.append(list(i))

hall = seat_list[0][0]
seat_List = []
for i in seat_list:
    if hall == i[0]:
        seat_List.append([i[1], i[2]])

print(seat_List)

cmd = """SELECT DISTINCT HALL , CLASS
         FROM REPORT
         ORDER BY HALL"""
cursor = conn.execute(cmd)
x = cursor.fetchall()
distinct_class = []
for i in x:
    distinct_class.append(list(i))
print(distinct_class)
