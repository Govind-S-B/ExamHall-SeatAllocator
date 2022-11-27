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

#Functions
def ranges(i):
    for a, b in itertools.groupby(enumerate(i), lambda pair: pair[1] - pair[0]):
        b = list(b)
        yield b[0][1], b[-1][1]
def divide_chunks(l, n):
    for i in range(0, len(l), n):
        yield l[i:i + n]

# NOTICE BOARD ----------------------------------------------------------------------------------------
#Code
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
            PDF_list.append([class_name, hall_name, roll_list])
            # print(roll_list)
            hall_name = i[1]
            roll_list = []
            roll_list.append(i[2])

    else:
        temp = "("+str(len(roll_list))+")"
        roll_list.append(temp)
        PDF_list.append([class_name, hall_name, roll_list])
        # print(roll_list)
        class_name = i[0]
        hall_name = i[1]
        roll_list = []
        roll_list.append(i[2])

    if Q_list[-1] == i:
        temp = "("+str(len(roll_list))+")"
        roll_list.append(temp)
        PDF_list.append([class_name, hall_name, roll_list])

# fpdf Class and Object Creation
class PDF(FPDF):
    # Page footer
    def footer(self):
        self.set_y(-15)
        text_w=pdf1.get_string_width("Created by ProtoRes")+6
        self.set_x(((self.w - text_w) / 2)+7)
        self.set_font(font, '', 8)
        self.cell(pdf1.get_string_width("Created by "), 10, "Created by ")
        self.set_font(font, 'B', 8)
        self.cell(pdf1.get_string_width("ProtoRes"), 10, "ProtoRes")
        self.set_font('helvetica', '', 8)
        # Page number
        self.cell(0, 10, f'{self.page_no()}/{{nb}}', align='R')


pdf1 = PDF('P', 'mm', 'A4')

# adding fonts
try:
    pdf1.add_font('Poppins', '', 'Fonts/Poppins-Regular.ttf')
    pdf1.add_font('Poppins', 'B', 'Fonts/Poppins-Bold.ttf')
    font="Poppins"
except:
    print("Poppins font not found. Using Times now.")
    font="Times"

pdf1.set_auto_page_break(auto = True, margin = 15) # Auto page break
pdf1.add_page()

pdf1.set_font(font, '', 27)
text="Marian Engineering College"
text_w=pdf1.get_string_width(text)+6
doc_w=pdf1.w
pdf1.set_x((doc_w - text_w) / 2)
pdf1.cell(text_w, 23, text,  new_x="LMARGIN", new_y="NEXT", align='C')

pdf1.set_font(font, '', 21)
text="Halls for Internal Examination"
text_w=pdf1.get_string_width(text)+6
pdf1.set_x((doc_w - text_w) / 2)
pdf1.cell(text_w, 7, text,  new_x="LMARGIN", new_y="NEXT", align='C')

text_w=pdf1.get_string_width("Date: 12-04-2022         Session: FN")
pdf1.set_x(((doc_w - text_w) / 2)+10.5)

pdf1.set_font(font, '', 17)
pdf1.cell(pdf1.get_string_width("Date:"), 14, 'Date:', align='C')
pdf1.set_font(font, 'B', 17)
pdf1.cell(pdf1.get_string_width(Date), 14, Date)
pdf1.set_font(font, '', 17)
pdf1.cell(pdf1.get_string_width("         Session: "), 14, '         Session: ')
pdf1.set_font(font, 'B', 17)
pdf1.cell(pdf1.get_string_width(Session), 14, Session,  new_x="LMARGIN", new_y="NEXT")

#Create Table Header
pdf1.set_font(font, 'B', 12)
pdf1.cell(22.1, 10, "Class", align='C', border=True)
pdf1.cell(18.5, 10, "Hall", align='C', border=True)
pdf1.cell(0, 10, "Roll No.s", align='C', border=True, new_x="LMARGIN", new_y="NEXT")

# Create Table Body
prev_class=""
PDF_list.pop(0)
for i in PDF_list:
    temp="   "
    rows=1
    temp_count=1
    
    roll_list=[]
    roll_list.append(i[2])
    for j in roll_list[0]:
        if temp_count==20:  #to split rows
            temp+="\n   "
            rows+=1
            temp_count=1
        if j==roll_list[0][-1]:
            temp+=str(j)
        elif j==roll_list[0][-2]:
            temp+=(str(j)+"  ")
        else:
            temp+=(str(j)+", ")
        temp_count+=1

    curr_class=i[0]
    height=rows*12

    pdf1.set_font(font, 'B', 11)
    if prev_class==curr_class:
        pdf1.cell(22.1, height, '"', align='C', border=True)
    else:
        pdf1.cell(22.1, height, curr_class, align='C', border=True)
    prev_class=curr_class
    pdf1.set_font(font, '', 11)
    pdf1.cell(18.5, height, i[1], align='C', border=True, new_x="RIGHT")

    pdf1.multi_cell(0, height/rows, temp, new_x="LMARGIN", new_y="NEXT", border=True, align="L")

file_name="Notice Board "+Date+" "+Session+".pdf"
pdf1.output(file_name)
#-----------------------------------------------------------------------------------------------------