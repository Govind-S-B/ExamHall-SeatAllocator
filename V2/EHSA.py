import json
from fpdf import FPDF, HTMLMixin
import sqlite3 as sq
import itertools
import math
import random
from JSON_generator import generate_JSON
from db_generator import generate_db

def generate_report():

    conn = generate_db()


    with open('Subjects.json', 'r') as JSON:
        MetaInfo = json.load(JSON).pop("meta")

    sessioninfo = MetaInfo["Session_Name"]
    sessioninfo = sessioninfo.split()
    Date = sessioninfo[0]
    Session = sessioninfo[1]

    #Functions
    def ranges(i):
        for a, b in itertools.groupby(enumerate(i), lambda pair: pair[1] - pair[0]):
            b = list(b)
            yield b[0][1], b[-1][1]
    def divide_chunks(l, n):
        for i in range(0, len(l), n):
            yield l[i:i + n]

    # fpdf Class definition
    class PDF(FPDF, HTMLMixin):
        def footer(self):
            # Set position of the footer
            self.set_y(-15)
            
            text_w=self.get_string_width("Created by protoRes")+6
            self.set_x(((self.w - text_w) / 2)+14)

            self.set_font(font, '', 8)
            self.cell(self.get_string_width("Created by "), 10, "Created by ")

            self.set_font(font, 'B', 8)
            self.cell(self.get_string_width("protoRes"), 10, "protoRes")

            # Page number
            self.set_font('helvetica', '', 8)
            self.cell(0, 10, f'{self.page_no()}/{{nb}}', align='R')

    # Creating pdf object for each pdf
    pdf1 = PDF('P', 'mm', 'A4')
    pdf2 = PDF('P', 'mm', 'A4')
    pdf3 = PDF('P', 'mm', 'A4')

    # adding fonts
    try:
        pdf1.add_font('Poppins', '', 'Fonts/Poppins-Regular.ttf')
        pdf1.add_font('Poppins', 'B', 'Fonts/Poppins-Bold.ttf')
        pdf2.add_font('Poppins', '', 'Fonts/Poppins-Regular.ttf')
        pdf2.add_font('Poppins', 'B', 'Fonts/Poppins-Bold.ttf')
        pdf3.add_font('Poppins', '', 'Fonts/Poppins-Regular.ttf')
        pdf3.add_font('Poppins', 'B', 'Fonts/Poppins-Bold.ttf')
        font="Poppins"
    except:
        print("Poppins font not found. Using Helvetica instead.")
        font="Helvetica"

    # Notice Board PDF------------------------------------------------------------------------------------------------
    # Code
    cmd = """SELECT CLASS,HALL,ROLL
            FROM REPORT
            ORDER BY CLASS,HALL"""
    cursor = conn.execute(cmd)
    Q_list = cursor.fetchall()

    PDF_list = []
    temp_PDF_list = []
    roll_list = []
    class_name = Q_list[0][0]
    hall_name = Q_list[0][1]

    for subject in Q_list:
        if class_name == subject[0]:

            if hall_name == subject[1]:
                roll_list.append(subject[2])
            else:
                temp = "("+str(len(roll_list))+")"
                roll_list.append(temp)
                
                temp_PDF_list.append([class_name, hall_name, roll_list])

                hall_name = subject[1]
                roll_list = []
                roll_list.append(subject[2])

        else:
            temp = "("+str(len(roll_list))+")"
            roll_list.append(temp)

            temp_PDF_list.append([class_name, hall_name, roll_list])
            temp_PDF_list = sorted(temp_PDF_list, key = lambda x:x[2][0])
            for h in temp_PDF_list:
                PDF_list.append(h)

            temp_PDF_list = []
            class_name = subject[0]
            hall_name = subject[1]
            roll_list = []
            roll_list.append(subject[2])

        if Q_list[-1] == subject:
            temp = "("+str(len(roll_list))+")"
            roll_list.append(temp)

            temp_PDF_list.append([class_name, hall_name, roll_list])
            temp_PDF_list = sorted(temp_PDF_list, key = lambda x:x[2][0])
            for h in temp_PDF_list:
                PDF_list.append(h)


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
    pdf1.set_font(font, '', 17)
    pdf1.set_y(45)
    pdf1.set_x(57)
    pdf1.write_html(f"Date: <b>{Date}</b>      Session: <b>{Session}<b/>")
    pdf1.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

    #Create Table Header
    pdf1.set_font(font, 'B', 12)
    pdf1.cell(22.1, 10, "Class", align='C', border=True)
    pdf1.cell(18.5, 10, "Hall", align='C', border=True)
    pdf1.cell(0, 10, "Roll No.s", align='C', border=True, new_x="LMARGIN", new_y="NEXT")

    # Create Table Body
    prev_class=""
    # PDF_list.pop(0)
    for subject in PDF_list:
        temp="   "
        rows=1
        temp_count=1
        
        roll_list=[]
        roll_list.append(subject[2])
        for j in roll_list[0]:
            if temp_count>78:  #to split rows
                temp+="\n   "
                rows+=1
                temp_count=1
            if j==roll_list[0][-1]:
                temp+=str(j)
            elif j==roll_list[0][-2]:
                temp+=(str(j)+"  ")
            else:
                temp+=(str(j)+", ")
            temp_count+=len(str(j))+2

        curr_class=subject[0]
        height=rows*12

        pdf1.set_font(font, 'B', 11)
        if prev_class==curr_class:
            pdf1.cell(22.1, height, '"', align='C', border=True)
        else:
            pdf1.cell(22.1, height, curr_class, align='C', border=True)
        prev_class=curr_class
        pdf1.set_font(font, '', 11)
        pdf1.cell(18.5, height, subject[1], align='C', border=True, new_x="RIGHT")

        pdf1.multi_cell(0, height/rows, temp, new_x="LMARGIN", new_y="NEXT", border=True, align="L")

    file_name="Halls "+Date+" "+Session+".pdf"
    pdf1.output(file_name)


    # Packaging List PDF------------------------------------------------------------------------------------------------
    pdf2.set_auto_page_break(auto = True, margin = 15) # Auto page break
    # code
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

    for subject in Q_list:
        if hall_name == subject[0]:
            if class_name == subject[1]:

                if subject_name == subject[2]:
                    roll_list.append(subject[3])

                else:
                    roll_ = ranges(roll_list)
                    no_of_candidates = len(roll_list)
                    PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1], no_of_candidates])
                    subject_name = subject[2]
                    roll_list = []
                    roll_list.append(subject[3])

            else:
                roll_ = ranges(roll_list)
                no_of_candidates = len(roll_list)
                PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1], no_of_candidates])
                class_name = subject[1]
                subject_name = subject[2]
                roll_list = []
                roll_list.append(subject[3])

        else:
            # append , PDF Generate and empty pdf list
            roll_ = ranges(roll_list)
            no_of_candidates = len(roll_list)
            PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1], no_of_candidates])

            pdf2.add_page()
            pdf2.set_font(font, '', 27)
            text="Marian Engineering College"
            text_w=pdf2.get_string_width(text)+6
            pdf2.w=pdf2.w
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 23, text,  new_x="LMARGIN", new_y="NEXT", align='C')

            pdf2.set_font(font, '', 20)
            text="Packing List for Internal Examination"
            text_w=pdf2.get_string_width(text)+6
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 10, text,  new_x="LMARGIN", new_y="NEXT", align='C')

            pdf2.set_y(45)
            pdf2.set_font(font, '', 18)
            pdf2.set_x(30)
            pdf2.write_html(f"<align=\"center\">Hall No: <b>{hall_name}</b>      Date: <b>{Date}</b>      Session: <b>{Session}<b/>")
            pdf2.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

            #Create Table Header
            pdf2.set_font(font, 'B', 10)
            pdf2.set_y(60)
            class_w=pdf2.get_string_width("Class")+8
            pdf2.cell(class_w, 20, "Class", align='C', border=True)
            pdf2.cell(65, 20, "Subject", align='C', border=True)
            pdf2.cell(30, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+65+14)
            pdf2.write_html("<b>Roll No.s of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+65+13.1)
            pdf2.write_html("<b>Candidates</b>")

            pdf2.set_y(60)
            pdf2.set_x(class_w+65+30+10)
            pdf2.cell(30, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+65+14+35)
            pdf2.write_html("<b>No. of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+65+13.1+30)
            pdf2.write_html("<b>Candidates</b>")
            
            pdf2.set_y(60)
            pdf2.set_x(class_w+65+30+10+30)
            pdf2.cell(0, 20, "", align='C', border=True, new_x="LMARGIN", new_y="NEXT")
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+65+14+35+34)
            pdf2.write_html("<b>Roll No.s of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+65+13.1+30+40)
            pdf2.write_html("<b>Absentees</b>")

            #Create Table Body
            y_pos=80
            pdf2.set_y(80)
            pdf2.set_x(10)
            prev_class=""
            PDF_list.pop(0)
            for k in PDF_list:
                sub_rows=1
                sub_flag=0
                if len(k[1])>33:
                    sub_rows=2
                    sub_flag=1

                roll_range_raw=k[2]
                temp1=""
                a=[]
                # print("Roll rage raw: ",roll_range_raw)
                for m in roll_range_raw:
                    if m.isdigit():
                        temp1+=m
                    elif m==',':
                        temp1+=','
                    elif m=='(':
                        temp1=""
                    elif m==')':
                        a.append(temp1)
                # print("a: ",a)
                # roll_rows=len(a)
                roll_rows=1
                temp1=""
                # char_count=1
                for m in a:
                    x=m.split(',')
                    if x[0]==x[1]:
                        temp1+=x[0]+", "
                        # char_count+=len(x[0])+2
                    else:
                        temp1+=x[0]+"-"+x[1]+", "
                        # char_count+=len(x[0])+len(x[1])+2
                    # if char_count>16:
                    #     # temp1+="\n"
                    #     roll_rows+=1
                    #     char_count=1
                # while temp1[-1].isnumeric()==False:
                #     temp1=temp1[:-1]
                temp1=temp1[:-2]
                roll_rows=int(math.ceil(len(temp1)/17))
                if len(temp1)>50:
                    roll_rows+=1
                # if temp1[-1]=="\n":
                #     temp1=temp1[:-1]
                #     roll_rows-=1
                # temp1=temp1[:-2]
                # temp1+="test"
                # print("Temp: ",temp1)
                # print()
                # print("temp1: ",temp1)
                # roll_rows=int(math.ceil(len(temp1)/17))
                # char_count=0
                # for e in temp1:
                #     char_count+=1
                #     if e==",":
                #         if char_count>16

                roll_flag=0
                # if roll_rows>1:
                #     roll_flag=1
                
                # print(hall_name, " ", curr_class," ",k[1])
                # print("Sub r: ", sub_rows)
                # print("Roll r: ", roll_rows)
                rows=max(sub_rows,roll_rows)
                # print("Rows: ", rows)
                # print()
                height=10*rows
                pdf2.set_font(font, '', 10)

                curr_class=k[0]
                if prev_class==curr_class:
                    pdf2.cell(class_w, height, '"', align='C', border=True) # Class
                else:
                    pdf2.cell(class_w, height, curr_class, align='C', border=True) # Class
                prev_class=curr_class
                if sub_flag==0:
                    pdf2.multi_cell(65, height, k[1], align='C', border=True) # Subject when subject is one line only
                elif sub_flag==1 and roll_flag==0:
                    pdf2.multi_cell(65, 10, k[1], align='C', border=True) # Subject when subject is two line but roll no range is only one line
                elif sub_flag==1 and roll_flag==1:
                    pdf2.multi_cell(65, (10*rows)/2, k[1], align='C', border=True) # Subject subject is 2 line and roll range is also multi line
                else:
                    pdf2.multi_cell(65, 10, k[1], align='C', border=True) # Subject in other cases

                pdf2.set_y(y_pos)
                pdf2.set_x(pdf2.w-(pdf2.w-(18.061+65))+10)
                if sub_flag==1 and roll_flag==0:
                    pdf2.multi_cell(30, height, temp1, align='C', border=True) # Roll no range when sub is 2 line and roll range is one line
                else:
                    pdf2.multi_cell(30, 10, temp1, align='C', border=True) # Roll no range
                pdf2.set_y(y_pos)
                pdf2.set_x(class_w+65+30+10)

                pdf2.cell(30, height, str(k[3]), align='C', border=True) # No of candidates
                pdf2.cell(0, height, "", border=True, new_x="LMARGIN", new_y="NEXT") # Absentees blank column
                y_pos+=height
            
            pdf2.set_font(font, 'B', 10)
            pdf2.cell(class_w+65+30, 10, "Total:", border=True, align="C") # Total
            for l in R_list:
                if l[0]==hall_name:
                    pdf2.cell(30, 10, str(l[1]), border=True, align="C") # Total count
            pdf2.cell(0, 10, "", border=True, new_x="LMARGIN", new_y="NEXT") # Final blank cell

            y_pos+=25
            pdf2.set_y(y_pos)
            pdf2.set_font(font, '', 15)
            pdf2.write_html("<U>Invigilators must</U>:")
            pdf2.write_html("<br><br>&nbsp;&nbsp;&nbsp;1.  &nbsp;Ensure that all candidates have ID-Cards & are in proper uniform.")
            pdf2.write_html("<br><br>&nbsp;&nbsp;&nbsp;2. Announce that mobile phones, smartwatches & other electronic")
            pdf2.write_html("<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;gadgets, pouches, bags, calculator-cover etc. are <B>NOT</B> allowed")
            pdf2.set_y(pdf2.get_y()+1.25)
            pdf2.write_html("<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;inside.")
            
            PDF_list = [["Class", "Subject", "RollNo", "No. of candidates"]]

            hall_name = subject[0]
            class_name = subject[1]
            subject_name = subject [2]
            roll_list = []
            roll_list.append(subject[3])

        if Q_list[-1] == subject:
            roll_ = ranges(roll_list)
            no_of_candidates = len(roll_list)
            PDF_list.append([class_name, subject_name, str(list(roll_))[1:-1], no_of_candidates])
            
            pdf2.add_page()
            pdf2.set_font(font, '', 27)
            text="Marian Engineering College"
            text_w=pdf2.get_string_width(text)+6
            pdf2.w=pdf2.w
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 23, text,  new_x="LMARGIN", new_y="NEXT", align='C')

            pdf2.set_font(font, '', 20)
            text="Packing List for Internal Examination"
            text_w=pdf2.get_string_width(text)+6
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 10, text,  new_x="LMARGIN", new_y="NEXT", align='C')

            pdf2.set_y(45)
            pdf2.set_font(font, '', 18)
            pdf2.set_x(30)
            pdf2.write_html(f"<align=\"center\">Hall No: <b>{hall_name}</b>      Date: <b>{Date}</b>      Session: <b>{Session}<b/>")
            pdf2.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

            #Create Table Header
            pdf2.set_font(font, 'B', 10)
            pdf2.set_y(60)
            class_w=pdf2.get_string_width("Class")+8
            pdf2.cell(class_w, 20, "Class", align='C', border=True)
            pdf2.cell(65, 20, "Subject", align='C', border=True)
            pdf2.cell(30, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+65+14)
            pdf2.write_html("<b>Roll No.s of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+65+13.1)
            pdf2.write_html("<b>Candidates</b>")

            pdf2.set_y(60)
            pdf2.set_x(class_w+65+30+10)
            pdf2.cell(30, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+65+14+35)
            pdf2.write_html("<b>No. of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+65+13.1+30)
            pdf2.write_html("<b>Candidates</b>")
            
            pdf2.set_y(60)
            pdf2.set_x(class_w+65+30+10+30)
            pdf2.cell(0, 20, "", align='C', border=True, new_x="LMARGIN", new_y="NEXT")
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+65+14+35+34)
            pdf2.write_html("<b>Roll No.s of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+65+13.1+30+40)
            pdf2.write_html("<b>Absentees</b>")

            #Create Table Body
            y_pos=80
            pdf2.set_y(80)
            pdf2.set_x(10)
            prev_class=""
            PDF_list.pop(0)
            for k in PDF_list:
                sub_rows=1
                sub_flag=0
                if len(k[1])>33:
                    sub_rows=2
                    sub_flag=1

                roll_range_raw=k[2]
                temp1=""
                a=[]
                # print("Roll rage raw: ",roll_range_raw)
                for m in roll_range_raw:
                    if m.isdigit():
                        temp1+=m
                    elif m==',':
                        temp1+=','
                    elif m=='(':
                        temp1=""
                    elif m==')':
                        a.append(temp1)
                # print("a: ",a)
                # roll_rows=len(a)
                roll_rows=1
                temp1=""
                # char_count=1
                for m in a:
                    x=m.split(',')
                    if x[0]==x[1]:
                        temp1+=x[0]+", "
                        # char_count+=len(x[0])+2
                    else:
                        temp1+=x[0]+"-"+x[1]+", "
                        # char_count+=len(x[0])+len(x[1])+2
                    # if char_count>16:
                    #     # temp1+="\n"
                    #     roll_rows+=1
                    #     char_count=1
                # while temp1[-1].isnumeric()==False:
                #     temp1=temp1[:-1]
                temp1=temp1[:-2]
                roll_rows=int(math.ceil(len(temp1)/17))
                if len(temp1)>50:
                    roll_rows+=1
                # if temp1[-1]=="\n":
                #     temp1=temp1[:-1]
                #     roll_rows-=1
                # temp1=temp1[:-2]
                # temp1+="test"
                # print("Temp: ",temp1)
                # print()
                # print("temp1: ",temp1)
                # roll_rows=int(math.ceil(len(temp1)/17))
                # char_count=0
                # for e in temp1:
                #     char_count+=1
                #     if e==",":
                #         if char_count>16

                roll_flag=0
                # if roll_rows>1:
                #     roll_flag=1
                
                # print(hall_name, " ", curr_class," ",k[1])
                # print("Sub r: ", sub_rows)
                # print("Roll r: ", roll_rows)
                rows=max(sub_rows,roll_rows)
                # print("Rows: ", rows)
                # print()
                height=10*rows
                pdf2.set_font(font, '', 10)

                curr_class=k[0]
                if prev_class==curr_class:
                    pdf2.cell(class_w, height, '"', align='C', border=True) # Class
                else:
                    pdf2.cell(class_w, height, curr_class, align='C', border=True) # Class
                prev_class=curr_class
                if sub_flag==0:
                    pdf2.multi_cell(65, height, k[1], align='C', border=True) # Subject when subject is one line only
                elif sub_flag==1 and roll_flag==0:
                    pdf2.multi_cell(65, 10, k[1], align='C', border=True) # Subject when subject is two line but roll no range is only one line
                elif sub_flag==1 and roll_flag==1:
                    pdf2.multi_cell(65, (10*rows)/2, k[1], align='C', border=True) # Subject subject is 2 line and roll range is also multi line
                else:
                    pdf2.multi_cell(65, 10, k[1], align='C', border=True) # Subject in other cases

                pdf2.set_y(y_pos)
                pdf2.set_x(pdf2.w-(pdf2.w-(18.061+65))+10)
                if sub_flag==1 and roll_flag==0:
                    pdf2.multi_cell(30, height, temp1, align='C', border=True) # Roll no range when sub is 2 line and roll range is one line
                else:
                    pdf2.multi_cell(30, 10, temp1, align='C', border=True) # Roll no range
                pdf2.set_y(y_pos)
                pdf2.set_x(class_w+65+30+10)

                pdf2.cell(30, height, str(k[3]), align='C', border=True) # No of candidates
                pdf2.cell(0, height, "", border=True, new_x="LMARGIN", new_y="NEXT") # Absentees blank column
                y_pos+=height
            
            pdf2.set_font(font, 'B', 10)
            pdf2.cell(class_w+65+30, 10, "Total:", border=True, align="C") # Total
            for l in R_list:
                if l[0]==hall_name:
                    pdf2.cell(30, 10, str(l[1]), border=True, align="C") # Total count
            pdf2.cell(0, 10, "", border=True, new_x="LMARGIN", new_y="NEXT") # Final blank cell

            y_pos+=25
            pdf2.set_y(y_pos)
            pdf2.set_font(font, '', 15)
            pdf2.write_html("<U>Invigilators must</U>:")
            pdf2.write_html("<br><br>&nbsp;&nbsp;&nbsp;1.  &nbsp;Ensure that all candidates have ID-Cards & are in proper uniform.")
            pdf2.write_html("<br><br>&nbsp;&nbsp;&nbsp;2. Announce that mobile phones, smartwatches & other electronic")
            pdf2.write_html("<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;gadgets, pouches, bags, calculator-cover etc. are <B>NOT</B> allowed")
            pdf2.set_y(pdf2.get_y()+1.25)
            pdf2.write_html("<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;inside.")

            PDF_list = []

    file_name="Packaging "+Date+" "+Session+".pdf"
    pdf2.output(file_name)


    # Seating List PDF------------------------------------------------------------------------------------------------
    pdf3.set_auto_page_break(auto = True, margin = 15) # Set auto page break

    cmd = """SELECT DISTINCT HALL , CLASS
            FROM REPORT
            ORDER BY HALL"""
    cursor = conn.execute(cmd)
    x = cursor.fetchall()
    distinct_class = []
    for subject in x:
        distinct_class.append(list(subject))

    cmd = """SELECT HALL,SEAT_NO,ID
            FROM REPORT
            ORDER BY HALL,SEAT_NO"""
    cursor = conn.execute(cmd)
    x = cursor.fetchall()
    query_list = []
    for subject in x:
        query_list.append(list(subject))

    hall_distinct_list = [[distinct_class[0][0]]]
    hall = query_list[0][0]
    hall_check_for_distinct = distinct_class[0][0]

    for subject in distinct_class:
        if hall_check_for_distinct == subject[0]:
            if subject[1] not in hall_distinct_list:
                hall_distinct_list[-1].append(subject[1])
        else:
            hall_check_for_distinct = subject[0]
            hall_distinct_list.append(subject)
            if subject[1] not in hall_distinct_list[-1]:
                hall_distinct_list[-1].append(subject[1])

    # print distinct
    for subject in hall_distinct_list:
        seat_List = [["Seat", "RollNo"]]
        hall = subject[0]
        for j in query_list:
            if hall == j[0]:
                seat_List.append([j[1], j[2]])
        last_seat_no=seat_List[-1][0]
        for k in range(1, last_seat_no+1):
            if seat_List[k][0]!=k:
                seat_List.insert(k, [k, "-"])
        classes_list = subject[1:]
        
        seat_List.pop(0)
        row_number = int(math.ceil(len(seat_List)/4))
        seat_List=divide_chunks(seat_List, row_number)
        x=list(seat_List)

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
        col1_width=((pdf3.w-20)/(len(classes_list)+1))+15
        col_rest_width=(pdf3.w-20-col1_width)/len(classes_list)
        pdf3.set_font(font, '', 14)
        pdf3.cell(col1_width, 11, "Classes:", border=True, align="C")
        pdf3.set_font(font, 'B', 14)
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
    file_name="Seating "+Date+" "+Session+".pdf"
    pdf3.output(file_name)

    print("Done")



print("ExamHall-SeatAllocator | EHSA v2.x - protoRes\n")
choice = input("Enter Choice (1)JSON Generator, (2)Report Generator: ")
print()

if choice == "1":
    generate_JSON()

elif choice == "2": 
    generate_report()


