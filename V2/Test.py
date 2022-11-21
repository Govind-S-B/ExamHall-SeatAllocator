import sqlite3 as sq
import itertools

sessioninfo = "12-04-2023 FN"
sessioninfo = sessioninfo.split()
Date = sessioninfo[0]
Session = sessioninfo[1]

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
            temp = "("+str(len(roll_list))+")"
            roll_list.append(temp)
            PDF_list.append([class_name, hall_name, str(roll_list)[1:-1]])
            hall_name = i[1]
            roll_list = []
            roll_list.append(i[2])

    else:
        temp = "("+str(len(roll_list))+")"
        roll_list.append(temp)
        PDF_list.append([class_name, hall_name, str(roll_list)[1:-1]])
        class_name = i[0]
        hall_name = i[1]
        roll_list = []
        roll_list.append(i[2])

    if Q_list[-1] == i:
        temp = "("+str(len(roll_list))+")"
        roll_list.append(temp)
        PDF_list.append([class_name, hall_name, str(roll_list)[1:-1]])

# print Notice Board PDF on terminal----
# print()
# print()
# print("Marian Engineering College")
# print()
# print("Halls for Internal Examination")
# print("Date: ",Date,"   Session: ",Session)
# print()
# for i in PDF_list:
#     print(i)
# print()
# print()
# -----------------------------------


def ranges(i):
    for a, b in itertools.groupby(enumerate(i), lambda pair: pair[1] - pair[0]):
        b = list(b)
        yield b[0][1], b[-1][1]


# PACKAGING --------------------------------------------------------------
# for each hall

conn = sq.connect("report.db")
cmd = """SELECT HALL,CLASS,SUBJECT,ROLL
         FROM REPORT
         ORDER BY HALL,CLASS, SUBJECT"""
cursor = conn.execute(cmd)
Q_list = cursor.fetchall()

cmd = """SELECT HALL,COUNT(ROLL)
         FROM REPORT
         GROUP BY HALL"""
cursor = conn.execute(cmd)
R_list = cursor.fetchall()

PDF_list = [["Class", "Subject", "RollNo", "No. of candidates"]]
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
                no_of_candidates = roll_list[-1]-roll_list[0]+1
                PDF_list.append([class_name, subject_name, str(
                    list(roll_))[1:-1], no_of_candidates])
                subject_name = i[2]
                roll_list = []
                roll_list.append(i[3])

        else:
            # maybe class name also needs to be rest
            roll_ = ranges(roll_list)
            no_of_candidates = roll_list[-1]-roll_list[0]+1
            PDF_list.append([class_name, subject_name, str(
                list(roll_))[1:-1], no_of_candidates])
            class_name = i[1]
            subject_name = i[2]
            roll_list = []
            roll_list.append(i[3])

    else:
        # append , PDF Generate and empty pdf list
        roll_ = ranges(roll_list)
        no_of_candidates = roll_list[-1]-roll_list[0]+1
        PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1], no_of_candidates])

        # print Packaging PDF on terminal---------------------
        print()
        print()
        print("Packing List for Internal Examination")
        print("Hall No: ",hall_name,"   Date: ",Date,"   Session: ",Session)
        print()
        for j in PDF_list:
            print(j)
        for j in R_list:
            if j[0]==hall_name:
                print("Total: ",j[1])
        print("-------------------------------------------------------------------------")
        # ----------------------------------------------------
        

        PDF_list = [["Class", "Subject", "RollNo", "No. of candidates"]]

        hall_name = i[0]
        class_name = i[1]
        roll_list = []
        roll_list.append(i[3])

    if Q_list[-1] == i:
        # PDF Generate
        roll_ = ranges(roll_list)
        no_of_candidates = roll_list[-1]-roll_list[0]+1
        PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1], no_of_candidates])

        # print Packaging PDF on terminal---------------------
        print()
        print()
        print("Packing List for Internal Examination")
        print("Hall No: ",hall_name,"   Date: ",Date,"   Session: ",Session)
        print()
        for j in PDF_list:
            print(j)
        for j in R_list:
            if j[0]==hall_name:
                print("Total: ",j[1])
        print("-------------------------------------------------------------------------")
        # ----------------------------------------------------

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
    seat_List = [["Seat", "RollNo"]]
    hall = i[0]
    for j in query_list:
        if hall == j[0]:
            seat_List.append([j[1], j[2]])
    classes_list = i[1:-1]

    # # print Seating Arrangement on terminal---------------------
    # print()
    # print()
    # print("Seating Arrangement for Internal Examination")
    # print("Hall No: ", hall, "   Date: ", Date, "   Session: ", Session)
    # print()
    # print("Classes: ", end='\t')
    # for k in classes_list:
    #     print(k, end='\t')
    # print('\n')
    # for l in seat_List:
    #     print(str(l[0]) + '\t' + l[1])
    # print("-------------------------------------------------------------------------")
    # # ----------------------------------------------------
