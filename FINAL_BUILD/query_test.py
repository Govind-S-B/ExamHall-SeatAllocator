import sqlite3 as sq

conn = sq.connect("report.db")
cmd = """SELECT *
         FROM REPORT"""
cursor = conn.execute(cmd)
x = cursor.fetchall()
for i in x:
    print(i)

# Report 1
# Hall Arrangement
# Class Hall Roll_nos

cmd = """SELECT CLASS,HALL,ROLL
         FROM REPORT
         ORDER BY CLASS,HALL"""
cursor = conn.execute(cmd)
x = cursor.fetchall()
for i in x:
    print(i)

# Report 2
# Hall , Seat no , Roll-no(ID) -- query1
# Hall , Distinc class -- query2

cmd = """SELECT HALL,SEAT_NO,ID
         FROM REPORT
         ORDER BY HALL,SEAT_NO"""
cursor = conn.execute(cmd)
x = cursor.fetchall()
for i in x:
    print(i)

cmd = """SELECT DISTINCT HALL , CLASS
         FROM REPORT
         ORDER BY HALL"""
cursor = conn.execute(cmd)
x = cursor.fetchall()
for i in x:
    print(i)

# Report 3
# Hall , class , subject , roll no range , total no of students
