import json
import sqlite3 as sq
import sys
  
  


# importing json data files (inputs)
with open('Halls.json', 'r') as JSON:
    Halls = json.load(JSON)

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
    #print(i)
    Halls_list.append([Halls[i][0],i,Halls[i][1]]) # Hall Capacity , Hall name , Hall col size

Halls_list = sorted(Halls_list, key = lambda x: x[0],reverse=True) # Sorting by capacity 
#print(Halls_list)

Subjects_list = [] # List of subjects
Students_total=0

for i in Subjects:
    Subjects_list.append([len(Subjects[i]),i] + Subjects[i]) # No of students , Sub Name , roll nos ...
    Students_total+=len(Subjects[i])
# print(Subjects_list)
print("Total students: ",Students_total)


Subjects_list = sorted(Subjects_list, key = lambda x: x[0],reverse=True) # Sorting by number of students
# print(Subjects_list)


even_row_subject_list = []
odd_row_subject_list = []

for i in range(len(Subjects_list)):
    if i%2==0: #even
        even_row_subject_list.append(Subjects_list[i])
    else: #odd
        odd_row_subject_list.append(Subjects_list[i])

allocation_done = False

Halls_sorted_list = []

# print(Halls_list)
# print()
# print(Subjects_list)
# print()
Student_allocated_count=0

for i in Halls_list:
    if allocation_done == True:
            break
    else:
        Hall_name = i[1]
        Hall_capacity = i[0]
        Hall_cols = i[2]

        a = int(Hall_capacity/Hall_cols)
        b = int(Hall_capacity%Hall_cols)

        Hall_structure = [ [] for x in range(Hall_cols)]
        # print(Hall_structure)
        
        for i in Hall_structure:
            if b>0:
                k=1
            else:
                k=0

            i.extend([  [] for x in range(a+k) ])
            b-=1
        # print(Hall_structure)

        counter = 1
        for i in Hall_structure:
            for j in i:
                j.append(counter)
                counter+=1

        for i in range(len(Hall_structure)):
            if allocation_done == True:
                break
            else:
                for j in range(len(Hall_structure[i])):
                    if allocation_done == True:
                        break
                    else:
                        if i%2 == 0: #even row
                            if len(even_row_subject_list) == 0:
                                pass
                            else:
                                Hall_structure[i][j].extend([even_row_subject_list[0].pop(2),even_row_subject_list[0][1]])
                                temp_expression = Hall_structure[i][j][1].split("-")
                                conn.execute(f"INSERT INTO REPORT VALUES('{Hall_structure[i][j][1]}','{temp_expression[0]}','{temp_expression[1]}','{Hall_name}','{Hall_structure[i][j][0]}','{Hall_structure[i][j][2]}')")
                                conn.commit()
                                Student_allocated_count+=1
                                even_row_subject_list[0][0]-=1
                                if even_row_subject_list[0][0]==0:
                                    even_row_subject_list.pop(0)

                        else: #odd row
                            if len(odd_row_subject_list) == 0:
                                pass
                            else:
                                Hall_structure[i][j].extend([odd_row_subject_list[0].pop(2),odd_row_subject_list[0][1]])
                                temp_expression = Hall_structure[i][j][1].split("-")
                                conn.execute(f"INSERT INTO REPORT VALUES('{Hall_structure[i][j][1]}','{temp_expression[0]}','{temp_expression[1]}','{Hall_name}','{Hall_structure[i][j][0]}','{Hall_structure[i][j][2]}')")
                                conn.commit()
                                Student_allocated_count+=1
                                odd_row_subject_list[0][0]-=1
                                if odd_row_subject_list[0][0]==0:
                                    odd_row_subject_list.pop(0)

                        if (len(even_row_subject_list)==0) and (len(odd_row_subject_list)==0):
                            allocation_done = True
    

    Halls_sorted_list.append(Hall_structure)

if allocation_done == False:
    print()
    print("Hall capacity insufficient.")
    print("Number of students allocated: ",Student_allocated_count)
    print("Number of students left to allocate: ",Students_total-Student_allocated_count)



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