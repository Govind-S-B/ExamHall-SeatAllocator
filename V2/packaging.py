from fpdf import FPDF, HTMLMixin
import sqlite3 as sq
import itertools

# print("Enter session info in format 'DD-MM-YYYY<space>Session'")
sessioninfo = "12-04-2023 FN" #input from user
sessioninfo = sessioninfo.split()
Date = sessioninfo[0]
Session = sessioninfo[1]

#Functions
def ranges(i):
    for a, b in itertools.groupby(enumerate(i), lambda pair: pair[1] - pair[0]):
        b = list(b)
        yield b[0][1],b[-1][1]

class PDF(FPDF, HTMLMixin):
    def footer(self):
        # Set position of the footer
        self.set_y(-15)
        
        text_w=pdf.get_string_width("Created by ProtoRes")+6
        self.set_x(((pdf.w - text_w) / 2)+14)

        self.set_font(font, '', 8)
        self.cell(pdf.get_string_width("Created by "), 10, "Created by ")

        self.set_font(font, 'B', 8)
        self.cell(pdf.get_string_width("ProtoRes"), 10, "ProtoRes")

        # Page number
        self.set_font('helvetica', '', 8)
        self.cell(0, 10, f'{self.page_no()}/{{nb}}', align='R')


pdf = PDF('P', 'mm', 'A4')
pdf.set_auto_page_break(auto = True, margin = 15) # Set auto page break
doc_w=pdf.w

# adding fonts
try:
    pdf.add_font('Poppins', '', 'Fonts/Poppins-Regular.ttf')
    pdf.add_font('Poppins', 'B', 'Fonts/Poppins-Bold.ttf')
    font="Poppins"
except:
    print("Poppins font not found. Using Times now.")
    font="Times"



# PACKAGING --------------------------------------------------------------
# for each hall

# code
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
        if class_name == i[1]:

            if subject_name == i[2]:
                roll_list.append(i[3])

            else:
                roll_ = ranges(roll_list)
                no_of_candidates = len(roll_list)
                PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1], no_of_candidates])
                subject_name = i[2]
                roll_list = []
                roll_list.append(i[3])

        else:
            roll_ = ranges(roll_list)
            no_of_candidates = len(roll_list)
            PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1], no_of_candidates])
            class_name = i[1]
            subject_name = i[2]
            roll_list = []
            roll_list.append(i[3])

    else:
        # append , PDF Generate and empty pdf list
        roll_ = ranges(roll_list)
        no_of_candidates = len(roll_list)
        PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1], no_of_candidates])

        # print Packaging PDF on terminal---------------------
        # print()
        # print()
        # print("Packing List for Internal Examination")
        # print("Hall No: ",hall_name,"   Date: ",Date,"   Session: ",Session)
        # print(hall_name)
        # for j in PDF_list:
        #     print(j)
        # for j in R_list:
        #     if j[0]==hall_name:
        #         print("Total: ",j[1])
        # print("-------------------------------------------------------------------------")
        # ----------------------------------------------------


        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        pdf.add_page()
        pdf.set_font(font, '', 27)
        text="Marian Engineering College"
        text_w=pdf.get_string_width(text)+6
        doc_w=pdf.w
        pdf.set_x((doc_w - text_w) / 2)
        pdf.cell(text_w, 23, text,  new_x="LMARGIN", new_y="NEXT", align='C')

        pdf.set_font(font, '', 20)
        text="Packing List for Internal Examination"
        text_w=pdf.get_string_width(text)+6
        pdf.set_x((doc_w - text_w) / 2)
        pdf.cell(text_w, 10, text,  new_x="LMARGIN", new_y="NEXT", align='C')

        pdf.set_y(45)
        pdf.set_font(font, '', 18)
        pdf.set_x(30)
        pdf.write_html(f"<align=\"center\">Hall No: <b>{hall_name}</b>      Date: <b>{Date}</b>      Session: <b>{Session}<b/>")
        pdf.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

        #Create Table Header
        pdf.set_font(font, 'B', 10)
        pdf.set_y(60)
        class_w=pdf.get_string_width("Class")+8
        pdf.cell(class_w, 20, "Class", align='C', border=True)
        pdf.cell(65, 20, "Subject", align='C', border=True)
        pdf.cell(30, 20, "", align='C', border=True)
        pdf.set_y(66.1)
        pdf.set_x(class_w+65+14)
        pdf.write_html("<b>Roll No.s of</b>")
        pdf.set_y(71.1)
        pdf.set_x(class_w+65+13.1)
        pdf.write_html("<b>Candidates</b>")

        pdf.set_y(60)
        pdf.set_x(class_w+65+30+10)
        pdf.cell(30, 20, "", align='C', border=True)
        pdf.set_y(66.1)
        pdf.set_x(class_w+65+14+35)
        pdf.write_html("<b>No. of</b>")
        pdf.set_y(71.1)
        pdf.set_x(class_w+65+13.1+30)
        pdf.write_html("<b>Candidates</b>")
        
        pdf.set_y(60)
        pdf.set_x(class_w+65+30+10+30)
        pdf.cell(0, 20, "", align='C', border=True, new_x="LMARGIN", new_y="NEXT")
        pdf.set_y(66.1)
        pdf.set_x(class_w+65+14+35+34)
        pdf.write_html("<b>Roll No.s of</b>")
        pdf.set_y(71.1)
        pdf.set_x(class_w+65+13.1+30+40)
        pdf.write_html("<b>Absentees</b>")



        #Create Table Body
        y_pos=80
        pdf.set_y(80)
        pdf.set_x(10)
        prev_class=""
        PDF_list.pop(0)
        for k in PDF_list:
            # rows=1
            sub_rows=1
            sub_flag=0
            if len(k[1])>30:
                sub_rows=2
                sub_flag=1

            roll_range_raw=k[2]
            temp1=""
            a=[]
            for m in roll_range_raw:
                if m.isdigit():
                    temp1+=m
                elif m==',':
                    temp1+=','
                elif m=='(':
                    temp1=""
                elif m==')':
                    a.append(temp1)
            roll_rows=len(a)
            roll_flag=0
            if roll_rows>1:
                roll_flag=1
            
            temp1=""
            for m in a:
                x=m.split(',')
                if x[0]==x[1]:
                    temp1+=x[0]+"\n"
                else:
                    temp1+=x[0]+"-"+x[1]+"\n"
            temp1=temp1[:-1]
            rows=max(sub_rows,roll_rows)
            height=10*rows
            pdf.set_font(font, '', 10)

            curr_class=k[0]
            if prev_class==curr_class:
                pdf.cell(class_w, height, '"', align='C', border=True) # Class
            else:
                pdf.cell(class_w, height, curr_class, align='C', border=True) # Class
            prev_class=curr_class
            if sub_flag==0:
                pdf.multi_cell(65, height, k[1], align='C', border=True) # Subject when subject is one line only
            elif sub_flag==1 and roll_flag==0:
                pdf.multi_cell(65, 10, k[1], align='C', border=True) # Subject when subject is two line but roll no range is only one line
            elif sub_flag==1 and roll_flag==1:
                pdf.multi_cell(65, (10*rows)/2, k[1], align='C', border=True) # Subject subject is 2 line and roll range is also multi line
            else:
                pdf.multi_cell(65, 10, k[1], align='C', border=True) # Subject in other cases

            pdf.set_y(y_pos)
            pdf.set_x(pdf.w-(pdf.w-(18.061+65))+10)

            # temp1="41\n42\n43"
            if sub_flag==1 and roll_flag==0:
                pdf.multi_cell(30, height, temp1, align='C', border=True) # Roll no range when sub is 2 line and roll range is one line
            else:
                pdf.multi_cell(30, 10, temp1, align='C', border=True) # Roll no range
            pdf.set_y(y_pos)
            pdf.set_x(class_w+65+30+10)

            pdf.cell(30, height, str(k[3]), align='C', border=True) # No of candidates
            pdf.cell(0, height, "", border=True, new_x="LMARGIN", new_y="NEXT") # Absentees blank column
            y_pos+=height
        
        pdf.set_font(font, 'B', 10)
        pdf.cell(class_w+65+30, 10, "Total:", border=True, align="C") # Total
        for l in R_list:
            if l[0]==hall_name:
                pdf.cell(30, 10, str(l[1]), border=True, align="C") # Total count
        pdf.cell(0, 10, "", border=True, new_x="LMARGIN", new_y="NEXT") # Final blank cell

        y_pos+=25
        pdf.set_y(y_pos)
        pdf.set_font(font, '', 15)
        pdf.write_html("<U>Invigilators must</U>:")
        pdf.write_html("<br><br>     1.  Ensure that all candidates have ID-Cards & are in proper uniform.")
        pdf.write_html("<br><br>     2. Announce that mobile phones, smartwatches & other electronic")
        y_pos+=23
        pdf.set_y(y_pos)
        pdf.write_html("<br>         gadgets, pouches, bags, calculator-cover etc. are <B>NOT</B> allowed")
        y_pos+=8
        pdf.set_y(y_pos)
        pdf.write_html("<br>         inside.")
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        
        PDF_list = [["Class", "Subject", "RollNo", "No. of candidates"]]

        hall_name = i[0]
        class_name = i[1]
        roll_list = []
        roll_list.append(i[3])

    if Q_list[-1] == i:
        # PDF Generate
        # print(hall_name)
        # roll_ = ranges(roll_list)
        # no_of_candidates = len(roll_list)
        # PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1], no_of_candidates])

        # print Packaging PDF on terminal---------------------
        # print()
        # print()
        # print("Packing List for Internal Examination")
        # print("Hall No: ",hall_name,"   Date: ",Date,"   Session: ",Session)
        # print()
        # for j in PDF_list:
        #     print(j)
        # for j in R_list:
        #     if j[0]==hall_name:
        #         print("Total: ",j[1])
        # print("-------------------------------------------------------------------------")
        # ----------------------------------------------------

        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        pdf.add_page()
        pdf.set_font(font, '', 27)
        text="Marian Engineering College"
        text_w=pdf.get_string_width(text)+6
        doc_w=pdf.w
        pdf.set_x((doc_w - text_w) / 2)
        pdf.cell(text_w, 23, text,  new_x="LMARGIN", new_y="NEXT", align='C')

        pdf.set_font(font, '', 20)
        text="Packing List for Internal Examination"
        text_w=pdf.get_string_width(text)+6
        pdf.set_x((doc_w - text_w) / 2)
        pdf.cell(text_w, 10, text,  new_x="LMARGIN", new_y="NEXT", align='C')

        pdf.set_y(45)
        pdf.set_font(font, '', 18)
        pdf.set_x(30)
        pdf.write_html(f"<align=\"center\">Hall No: <b>{hall_name}</b>      Date: <b>{Date}</b>      Session: <b>{Session}<b/>")
        pdf.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

        #Create Table Header
        pdf.set_font(font, 'B', 10)
        pdf.set_y(60)
        class_w=pdf.get_string_width("Class")+8
        pdf.cell(class_w, 20, "Class", align='C', border=True)
        pdf.cell(65, 20, "Subject", align='C', border=True)
        pdf.cell(30, 20, "", align='C', border=True)
        pdf.set_y(66.1)
        pdf.set_x(class_w+65+14)
        pdf.write_html("<b>Roll No.s of</b>")
        pdf.set_y(71.1)
        pdf.set_x(class_w+65+13.1)
        pdf.write_html("<b>Candidates</b>")

        pdf.set_y(60)
        pdf.set_x(class_w+65+30+10)
        pdf.cell(30, 20, "", align='C', border=True)
        pdf.set_y(66.1)
        pdf.set_x(class_w+65+14+35)
        pdf.write_html("<b>No. of</b>")
        pdf.set_y(71.1)
        pdf.set_x(class_w+65+13.1+30)
        pdf.write_html("<b>Candidates</b>")
        
        pdf.set_y(60)
        pdf.set_x(class_w+65+30+10+30)
        pdf.cell(0, 20, "", align='C', border=True, new_x="LMARGIN", new_y="NEXT")
        pdf.set_y(66.1)
        pdf.set_x(class_w+65+14+35+34)
        pdf.write_html("<b>Roll No.s of</b>")
        pdf.set_y(71.1)
        pdf.set_x(class_w+65+13.1+30+40)
        pdf.write_html("<b>Absentees</b>")



        #Create Table Body
        y_pos=80
        pdf.set_y(80)
        pdf.set_x(10)
        prev_class=""
        PDF_list.pop(0)
        for k in PDF_list:
            # rows=1
            sub_rows=1
            sub_flag=0
            if len(k[1])>30:
                sub_rows=2
                sub_flag=1

            roll_range_raw=k[2]
            temp1=""
            a=[]
            for m in roll_range_raw:
                if m.isdigit():
                    temp1+=m
                elif m==',':
                    temp1+=','
                elif m=='(':
                    temp1=""
                elif m==')':
                    a.append(temp1)
            roll_rows=len(a)
            roll_flag=0
            if roll_rows>1:
                roll_flag=1
            
            temp1=""
            for m in a:
                x=m.split(',')
                if x[0]==x[1]:
                    temp1+=x[0]+"\n"
                else:
                    temp1+=x[0]+"-"+x[1]+"\n"
            temp1=temp1[:-1]
            rows=max(sub_rows,roll_rows)
            height=10*rows
            pdf.set_font(font, '', 10)

            curr_class=k[0]
            if prev_class==curr_class:
                pdf.cell(class_w, height, '"', align='C', border=True) # Class
            else:
                pdf.cell(class_w, height, curr_class, align='C', border=True) # Class
            prev_class=curr_class
            if sub_flag==0:
                pdf.multi_cell(65, height, k[1], align='C', border=True) # Subject when subject is one line only
            elif sub_flag==1 and roll_flag==0:
                pdf.multi_cell(65, 10, k[1], align='C', border=True) # Subject when subject is two line but roll no range is only one line
            elif sub_flag==1 and roll_flag==1:
                pdf.multi_cell(65, (10*rows)/2, k[1], align='C', border=True) # Subject subject is 2 line and roll range is also multi line
            else:
                pdf.multi_cell(65, 10, k[1], align='C', border=True) # Subject in other cases

            pdf.set_y(y_pos)
            pdf.set_x(pdf.w-(pdf.w-(18.061+65))+10)

            # temp1="41\n42\n43"
            if sub_flag==1 and roll_flag==0:
                pdf.multi_cell(30, height, temp1, align='C', border=True) # Roll no range when sub is 2 line and roll range is one line
            else:
                pdf.multi_cell(30, 10, temp1, align='C', border=True) # Roll no range
            pdf.set_y(y_pos)
            pdf.set_x(class_w+65+30+10)

            pdf.cell(30, height, str(k[3]), align='C', border=True) # No of candidates
            pdf.cell(0, height, "", border=True, new_x="LMARGIN", new_y="NEXT") # Absentees blank column
            y_pos+=height
        
        pdf.set_font(font, 'B', 10)
        pdf.cell(class_w+65+30, 10, "Total:", border=True, align="C") # Total
        for l in R_list:
            if l[0]==hall_name:
                pdf.cell(30, 10, str(l[1]), border=True, align="C") # Total count
        pdf.cell(0, 10, "", border=True, new_x="LMARGIN", new_y="NEXT") # Final blank cell

        y_pos+=25
        pdf.set_y(y_pos)
        pdf.set_font(font, '', 15)
        pdf.write_html("<U>Invigilators must</U>:")
        pdf.write_html("<br><br>     1.  Ensure that all candidates have ID-Cards & are in proper uniform.")
        pdf.write_html("<br><br>     2. Announce that mobile phones, smartwatches & other electronic")
        y_pos+=23
        pdf.set_y(y_pos)
        pdf.write_html("<br>         gadgets, pouches, bags, calculator-cover etc. are <B>NOT</B> allowed")
        y_pos+=8
        pdf.set_y(y_pos)
        pdf.write_html("<br>         inside.")
        # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        PDF_list = []
pdf.output('Packaging List.pdf')
##################################################################################################################