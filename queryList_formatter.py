# Assumption 1 , query list

Q_list = [["S3C1","SJ108",1],
          ["S3C1","SJ108",2],
          ["S3C1","SJ420",17],
          ["S3R1","SJ108",14],
          ["S3R1","SJ108",15]]

#  Target List
"""
PDF_List = [["Class","Hall","Roll No"],
            ["S3C1","SJ108","1,2"], # str(roll_no_list) -> "1,2,3,4" (without square brackets [ ]) , a[1:-1]
            ["S3C1","420","17"],
            ["S3R1","108","14,15"],
"""

PDF_list = []
roll_list = []
class_name = Q_list[0][0]
hall_name = Q_list[0][1]

for i in Q_list:
    if class_name == i[0]:
        
        if hall_name == i[1]:
            roll_list.append(i[2])
        else:
            PDF_list.append([class_name,hall_name,str(roll_list)[1:-1]]) #maybe class name also needs to be rest
            hall_name = i[1]
            roll_list = []
            roll_list.append(i[2])

    else:
        PDF_list.append([class_name,hall_name,str(roll_list)[1:-1]])
        class_name = i[0]
        hall_name = i[1]
        roll_list = []
        roll_list.append(i[2])

    if Q_list[-1] == i:
        PDF_list.append([class_name,hall_name,str(roll_list)[1:-1]])

print(PDF_list)