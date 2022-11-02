import sqlite3 as sq
from reportlab.platypus import SimpleDocTemplate
from reportlab.lib.pagesizes import letter
from reportlab.platypus import TableStyle
from reportlab.lib import colors
from reportlab.platypus import Table
from reportlab.pdfgen import canvas
import itertools

# PDF Gen Functions ( add it later from Test.py )

def ranges(i):
    for a, b in itertools.groupby(enumerate(i), lambda pair: pair[1] - pair[0]):
        b = list(b)
        yield b[0][1], b[-1][1]

sessioninfo = "12-04-2023 FN"

conn = sq.connect("report.db")

# NOTICE BOARD ----------------------------------------------------------

cmd = """SELECT CLASS,HALL,ROLL
         FROM REPORT
         ORDER BY CLASS,HALL"""
cursor = conn.execute(cmd)
Q_list = cursor.fetchall()
PDF_list = [["Class", "Hall", "RollNo"]]
roll_list = []
class_name = Q_list[0][0]
hall_name = Q_list[0][1]

for i in Q_list:
    if class_name == i[0]:

        if hall_name == i[1]:
            roll_list.append(i[2])
        else:
            PDF_list.append([class_name, hall_name, str(roll_list)[1:-1]])
            hall_name = i[1]
            roll_list = []
            roll_list.append(i[2])

    else:
        PDF_list.append([class_name, hall_name, str(roll_list)[1:-1]])
        class_name = i[0]
        hall_name = i[1]
        roll_list = []
        roll_list.append(i[2])

    if Q_list[-1] == i:
        PDF_list.append([class_name, hall_name, str(roll_list)[1:-1]])




# PACKAGING --------------------------------------------------------------
# for each hall

conn = sq.connect("report.db")
cmd = """SELECT HALL,CLASS,SUBJECT,ROLL
         FROM REPORT
         ORDER BY HALL,CLASS, SUBJECT"""
cursor = conn.execute(cmd)
Q_list = cursor.fetchall()
PDF_list = [["Class", "Subject", "RollNo"]]
roll_list = []
hall_name = Q_list[0][0]
class_name = Q_list[0][1]
subject_name = Q_list[0][2]

for i in Q_list:
    if hall_name == i[0]:
        # update list

        if class_name == i[1]:

            if subject_name == i[2]:
                roll_list.append(i[3])

            else:
                roll_ = ranges(roll_list)
                PDF_list.append(
                    [class_name, subject_name, str(list(roll_))[1:-1]])
                subject_name = i[2]
                roll_list = []
                roll_list.append(i[3])

        else:
            # maybe class name also needs to be rest
            roll_ = ranges(roll_list)
            PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1]])
            class_name = i[1]
            subject_name = i[2]
            roll_list = []
            roll_list.append(i[3])

    else:
        # append , PDF Generate and empty pdf list
        roll_ = ranges(roll_list)
        PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1]])
        #createpdf1(PDF_list, sessioninfo,  hall_name)
        PDF_list = []
        hall_name = i[0]
        class_name = i[1]
        roll_list = []
        roll_list.append(i[3])

    if Q_list[-1] == i:
        # PDF Generate

        roll_ = ranges(roll_list)
        PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1]])
        #createpdf1(PDF_list, sessioninfo,  hall_name)
        PDF_list = []


# SEATING LIST --------------------------------------------------------------
# for each hall

cmd = """SELECT DISTINCT HALL , CLASS
         FROM REPORT
         ORDER BY HALL"""
cursor = conn.execute(cmd)
x = cursor.fetchall()
distinct_class = []
for i in x:
    distinct_class.append(list(i))

cmd = """SELECT HALL,SEAT_NO,ID
         FROM REPORT
         ORDER BY HALL,SEAT_NO"""
cursor = conn.execute(cmd)
x = cursor.fetchall()
query_list = []
for i in x:
    query_list.append(list(i))

hall_distinct_list = [[distinct_class[0][0]]]
hall = query_list[0][0]
# print(query_list)
seat_List = [["Seat", "RollNo"]]

hall_check_for_distinct = distinct_class[0][0]
for i in distinct_class:
    if hall_check_for_distinct == i[0]:
        hall_distinct_list[-1].append(i[1])
    else:
        hall_distinct_list[-1].append(i[1])
        hall_check_for_distinct = i[0]
        hall_distinct_list.append(i)

# print distinct
for i in hall_distinct_list:
    print(i)


for i in query_list:
    if hall == i[0]:
        seat_List.append([i[1], i[2]])

    else:
        hall_distinct_list.append(i[1])
        # createpdf2(hall_distinct_list, seat_List, hall)
        hall = i[0]
        hall_distinct_list = []
        seat_List = [["Seat", "RollNo"]]
