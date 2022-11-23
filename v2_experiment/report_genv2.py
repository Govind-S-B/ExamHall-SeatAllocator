import json
import sqlite3 as sq


# importing json data files (inputs)
with open('Halls.json', 'r') as JSON:
    Halls = json.load(JSON)

D_Halls = Halls["D"] # drawing halls
B_Halls = Halls["B"] # bench halls

with open('Subjects.json', 'r') as JSON:
    Subjects = json.load(JSON)

MetaInfo = Subjects.pop("meta") # Meta info global for each generation
print(MetaInfo["Session_Name"])

# setting up sqlite DB for processed or sorted data storage ( allocated seats )
conn = sq.connect("report.db")
conn.execute("DROP TABLE IF EXISTS REPORT;")
conn.execute('''CREATE TABLE REPORT
         (ID         CHAR(15)         PRIMARY KEY     NOT NULL,
         CLASS       CHAR(10)                         NOT NULL,
         ROLL        INT                              NOT NULL,
         HALL        TEXT                             NOT NULL,
         SEAT_NO     INT                              NOT NULL,
         SUBJECT     CHAR(50)                         NOT NULL);''')


Halls_list = [] # List of halls

for i in Halls:
    Halls_list.append([Halls[i][0],i]) # Hall Capacity , Hall name

Halls_list = sorted(Halls_list, key = lambda x: x[0],reverse=True) # Sorting by capacity 

Subjects_list = [] # List of subjects
Students_total=0

for i in Subjects:
    Subjects_list.append([len(Subjects[i]),i] + Subjects[i]) # No of students , Sub Name , roll nos ...
    Students_total+=len(Subjects[i])
print("Total students: ",Students_total)

Subjects_list = sorted(Subjects_list, key = lambda x: x[0],reverse=True) # Sorting by number of students

even_row_subject_list = []
odd_row_subject_list = []

for i in range(len(Subjects_list)):
    if i%2==0: #even
        even_row_subject_list.append(Subjects_list[i])
    else: #odd
        odd_row_subject_list.append(Subjects_list[i])

allocation_done = False
Halls_sorted_list = []
Student_allocated_count=0

for i in Halls_list:
    if allocation_done == True:
            break
    else:
        Hall_name = i[1]
        Hall_capacity = i[0]*2

        for seat in range(1,Hall_capacity+1):
            if allocation_done == True:
                break
            else:

                if (len(even_row_subject_list)==0) and (len(odd_row_subject_list)>1):
                    Subjects_list = sorted(odd_row_subject_list, key = lambda x: x[0],reverse=True) # Sorting by number of students

                    even_row_subject_list = []
                    odd_row_subject_list = []

                    for i in range(len(Subjects_list)):
                        if i%2==0: #even
                            even_row_subject_list.append(Subjects_list[i])
                        else: #odd
                            odd_row_subject_list.append(Subjects_list[i])

                if (len(odd_row_subject_list)==0) and (len(even_row_subject_list)>1):
                    Subjects_list = sorted(even_row_subject_list, key = lambda x: x[0],reverse=True) # Sorting by number of students

                    even_row_subject_list = []
                    odd_row_subject_list = []

                    for i in range(len(Subjects_list)):
                        if i%2==0: #even
                            even_row_subject_list.append(Subjects_list[i])
                        else: #odd
                            odd_row_subject_list.append(Subjects_list[i])

                if (len(even_row_subject_list)==0) and (len(odd_row_subject_list)==0):
                    allocation_done = True

                if seat%2==0: #even
                    if len(even_row_subject_list) == 0:
                        pass
                    else:
                        x = even_row_subject_list[0].pop(2) #roll
                        temp_expression = x.split("-")
                        conn.execute(f"INSERT INTO REPORT VALUES('{x}','{temp_expression[0]}','{temp_expression[1]}','{Hall_name}','{seat}','{even_row_subject_list[0][1]}')")
                        conn.commit()
                        Student_allocated_count+=1
                        even_row_subject_list[0][0]-=1
                        if even_row_subject_list[0][0]==0:
                             even_row_subject_list.pop(0)
                else: #odd
                    if len(odd_row_subject_list) == 0:
                        pass
                    else:
                        x = odd_row_subject_list[0].pop(2) #roll
                        temp_expression = x.split("-")
                        conn.execute(f"INSERT INTO REPORT VALUES('{x}','{temp_expression[0]}','{temp_expression[1]}','{Hall_name}','{seat}','{odd_row_subject_list[0][1]}')")
                        conn.commit()
                        Student_allocated_count+=1
                        odd_row_subject_list[0][0]-=1
                        if odd_row_subject_list[0][0]==0:
                             odd_row_subject_list.pop(0)

if allocation_done == False:
    print()
    print("Hall capacity insufficient.")
    print("Number of students allocated: ",Student_allocated_count)
    print("Number of students left to allocate: ",Students_total-Student_allocated_count)
    input("\n Enter any key to exit ")



# print(Halls_sorted_list)
#print("Students allocated: ",Student_allocated_count)

""" DEBUG
for i in range(len(Halls_sorted_list)):
    for j in range(len(Halls_sorted_list[i])): # hall
        print(Halls_sorted_list[i][j])
    print()
"""

# Report Generation

# use meta data
# use query
# print report 1

# use meta data
# use query
# print report 2

# use meta data
# use query
# print report 3