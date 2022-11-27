from fpdf import FPDF, HTMLMixin
import sqlite3 as sq
import json

# Functions
def divide_chunks(l, n):            # l-list , n-how much elements to divide
    for i in range(0, len(l), n):
        yield l[i:i + n]

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

# fpdf Class and Object Creation
class PDF(FPDF, HTMLMixin):
    def footer(self):
        # Set position of the footer
        self.set_y(-15)
        
        text_w=pdf3.get_string_width("Created by ProtoRes")+6
        self.set_x(((pdf3.w - text_w) / 2)+9)

        self.set_font(font, '', 8)
        self.cell(pdf3.get_string_width("Created by "), 10, "Created by ")

        self.set_font(font, 'B', 8)
        self.cell(pdf3.get_string_width("ProtoRes"), 10, "ProtoRes")

        # Page number
        self.set_font('helvetica', '', 8)
        self.cell(0, 10, f'{self.page_no()}/{{nb}}', align='R')

pdf3 = PDF('P', 'mm', 'A4')
pdf3.set_auto_page_break(auto = True, margin = 15) # Set auto page break

# adding fonts
try:
    pdf3.add_font('Poppins', '', 'Fonts/Poppins-Regular.ttf')
    pdf3.add_font('Poppins', 'B', 'Fonts/Poppins-Bold.ttf')
    font="Poppins"
except:
    print("Poppins font not found. Using Times now.")
    font="Times"


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
        if i[1] not in hall_distinct_list:
            hall_distinct_list[-1].append(i[1])
    else:
        if i[1] not in hall_distinct_list[-1]:
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
    last_seat_no=seat_List[-1][0]
    # print("Last seat no: ",last_seat_no)
    for k in range(1, last_seat_no+1):
        if seat_List[k][0]!=k:
            seat_List.insert(k, [k, "-"])
    classes_list = i[1:]
    
    seat_List.pop(0)
    seat_List=divide_chunks(seat_List, ((int(len(seat_List)/4))+1))
    x=list(seat_List)

    # PDF Creation +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # Headings
    pdf3.add_page()
    pdf3.set_font(font, '', 27)
    text="Marian Engineering College"
    text_w=pdf3.get_string_width(text)+6
    pdf3.w=pdf3.w
    pdf3.set_x((pdf3.w - text_w) / 2)
    pdf3.cell(text_w, 23, text,  new_x="LMARGIN", new_y="NEXT", align='C')
    pdf3.set_font(font, '', 20)
    text="Seating Arrangement for Internal Examination"
    text_w=pdf3.get_string_width(text)+6
    pdf3.set_x((pdf3.w - text_w) / 2)
    pdf3.cell(text_w, 10, text,  new_x="LMARGIN", new_y="NEXT", align='C')
    pdf3.set_y(45)
    pdf3.set_font(font, '', 18)
    pdf3.set_x(30)
    pdf3.write_html(f"<align=\"center\">Hall No: <b>{hall}</b>      Date: <b>{Date}</b>      Session: <b>{Session}<b/>")
    pdf3.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

    # Class List Table
    # print(classes_list)
    col1_width=((pdf3.w-20)/(len(classes_list)+1))+15
    col_rest_width=(pdf3.w-20-col1_width)/len(classes_list)
    pdf3.set_font(font, '', 14)
    pdf3.cell(col1_width, 11, "Classes:", border=True, align="C")
    pdf3.set_font(font, 'B', 14)
    # for k in classes_list:
    #     print(k, end='\t')
    for k in classes_list:
        pdf3.cell(col_rest_width, 11, k, border=True, align="C")
    pdf3.set_y(76)


    # Seating Table
    # Header
    seat_w=((pdf3.w-20-15)/4)*0.4
    id_w=((pdf3.w-20-15)/4)*0.6

    # Body
    pdf3.set_font(font, '', 12)
    roll_rows=len(x[0])
    counter=x[-1][-1][0]
    for k in range(roll_rows):
        if k%19==0:
            if k!=0:
                pdf3.add_page()
            pdf3.set_font(font, 'B', 12)
            for n in range(4):
                pdf3.cell(seat_w, 10, "Seat", border=True, align="C")
                if n!=3:
                    pdf3.cell(id_w, 10, "Roll No.", border=True, align="C")
                    pdf3.cell(5, 10, "", border=False, align="C")
                else:
                    pdf3.cell(id_w, 10, "Roll No.", border=True, align="C", new_x="LMARGIN", new_y="NEXT")
        pdf3.set_font(font, '', 12)
        for l in range(4):
            try:
                pdf3.cell(seat_w, 10, str(x[l][k][0]), border=True, align="C")
                if l!=3:
                    pdf3.cell(id_w, 10, str(x[l][k][1]), border=True, align="C")
                    pdf3.cell(5, 10, "", border=False, align="C")
                else:
                    pdf3.cell(id_w, 10, str(x[l][k][1]), border=True, align="C", new_x="LMARGIN", new_y="NEXT")
            except:
                counter+=1
                pdf3.cell(seat_w, 10, str(counter), border=True, align="C")
                pdf3.cell(id_w, 10, "-", border=True, align="C", new_x="LMARGIN", new_y="NEXT")
                # print("Counter: ",counter)
                # print("Error: ",k," ",l)
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
file_name="Seating Arrangement "+Date+" "+Session+".pdf"
pdf3.output(file_name)