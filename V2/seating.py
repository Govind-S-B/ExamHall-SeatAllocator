from fpdf import FPDF
import sqlite3 as sq
import itertools
import json

# # importing subject json for session info
# with open('Subjects.json', 'r') as JSON:
#     Subjects = json.load(JSON)
# MetaInfo = Subjects.pop("meta") # Meta info global for each generation

# # print("Enter session info in format 'DD-MM-YYYY<space>Session'    eg: '12-04-2023 FN'")
# sessioninfo = MetaInfo["Session_Name"]
sessioninfo = "12-04-2023 FN"
sessioninfo = sessioninfo.split()
Date = sessioninfo[0]
Session = sessioninfo[1]
conn = sq.connect("report.db")


# SEATING LIST ------------------------------------------------------------------------------------------------------
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
print(hall_distinct_list)
for i in hall_distinct_list:
    seat_List = [["Seat", "RollNo"]]
    hall = i[0]
    for j in query_list:
        if hall == j[0]:
            seat_List.append([j[1], j[2]])
    classes_list = i[1:-1]
    print(classes_list)

    # print Seating Arrangement on terminal---------------------
    print()
    print()
    print("Seating Arrangement for Internal Examination")
    print("Hall No: ", hall, "   Date: ", Date, "   Session: ", Session)
    print()
    print("Classes: ", end='\t')
    for k in classes_list:
        print(k, end='\t')
    print('\n')
    for l in seat_List:
        print(str(l[0]) + '\t' + l[1])
    print("-------------------------------------------------------------------------")

# PDF Creation +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++