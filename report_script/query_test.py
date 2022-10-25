import sqlite3 as sq

conn = sq.connect("report.db")
cmd = """SELECT *
         FROM REPORT"""
cursor = conn.execute(cmd)
x = cursor.fetchall()
for i in x:
    print(i)