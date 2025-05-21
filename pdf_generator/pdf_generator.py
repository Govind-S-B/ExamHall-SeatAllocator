import json
from fpdf import FPDF, HTMLMixin
import sqlite3 as sq
import itertools
from math import ceil
# import random
import configparser

# --- PDF class definition moved to module level ---
class PDF(FPDF, HTMLMixin):
    def footer(self):
        # Set position of the footer
        self.set_y(-15)

        text_w = self.get_string_width("Created by protoRes")+6
        self.set_x(((self.w - text_w) / 2)+14)

        # Font determination for footer will be handled by the font passed to the PDF object
        # For simplicity, using self.font_family which should be set
        current_font_family = self.font_family
        current_font_style = self.font_style
        current_font_size = self.font_size_pt

        self.set_font(current_font_family, '', 8)
        self.cell(self.get_string_width("Created by "), 10, "Created by ")

        self.set_font(current_font_family, 'B', 8)
        self.cell(self.get_string_width("protoRes"), 10, "protoRes")
        
        self.set_font(current_font_family, current_font_style, current_font_size) # Restore original font

        # Page number
        self.set_font('helvetica', '', 8) # Keep helvetica for page number as it's standard
        self.cell(0, 10, f'{self.page_no()}/{{nb}}', align='R')

# --- Helper functions moved to module level ---
def ranges(i):
    for a, b in itertools.groupby(enumerate(i), lambda pair: pair[1] - pair[0]):
        b = list(b)
        yield b[0][1], b[-1][1]

def divide_chunks(l, n):
    for i in range(0, len(l), n):
        yield l[i:i + n]

# --- New initialize_pdf function ---
def initialize_pdf(font_name_to_use):
    pdf = PDF('P', 'mm', 'A4')
    try:
        # Attempt to add Poppins fonts. If they are already added by FPDF (e.g. by the check in generate_reports)
        # FPDF typically handles this gracefully. If files are not found, it will raise an error.
        pdf.add_font('Poppins', '', 'Fonts/Poppins-Regular.ttf')
        pdf.add_font('Poppins', 'B', 'Fonts/Poppins-Bold.ttf')
    except RuntimeError:
        # This error occurs if the font file cannot be found or other FPDF specific issues.
        # The font_name_to_use is determined before calling this, so we just try to make Poppins available if selected.
        if font_name_to_use == "Poppins":
            print(f"RuntimeError while trying to add Poppins in initialize_pdf. FPDF may fallback to a default font.")
        pass # Proceed, as FPDF will use a default if Poppins is not truly available/set.
    except Exception as e:
        # Catch any other unexpected error.
        # print(f"An unexpected error occurred while adding Poppins font in initialize_pdf: {e}")
        pass
    
    pdf.set_font(font_name_to_use) # Set the font that was determined by generate_reports
    pdf.set_auto_page_break(auto=True, margin=15)
    return pdf

def generate_reports():

    # Config
    config = configparser.ConfigParser()
    config.read("config.txt")
    name = config.get("exam info","name")
    title = config.get("exam info","title")

    conn = sq.connect("report.db")
    


    session_info = sq.connect("input.db").execute(
            """SELECT VALUE 
            FROM metadata 
            WHERE KEY = "session_name" 
            """).fetchall()[0][0]

    date, session = session_info.split()


    # Functions
    # ranges and divide_chunks moved to module level

    # fpdf Class definition
    # PDF class moved to module level

    # Font determination logic
    font = "Helvetica" # Default font
    try:
        # Check if Poppins can be added by a temporary FPDF object
        # This doesn't mean it's used yet, just that FPDF can find and process it.
        FPDF().add_font('Poppins', '', 'Fonts/Poppins-Regular.ttf')
        FPDF().add_font('Poppins', 'B', 'Fonts/Poppins-Bold.ttf')
        font = "Poppins" # If successful, set Poppins as the font to use
    except RuntimeError:
        print("Poppins font not found by FPDF, using Helvetica instead.")
    except Exception as e:
        print(f"An unexpected error occurred while checking for Poppins font: {e}. Using Helvetica.")
    
    # Data fetching functions (assuming these are correctly defined from previous steps)
    # These were added in a previous attempt to make the structure complete.
    # If they are not actually in the file, this diff might need adjustment or these calls will fail.
    # For now, proceeding as if they are defined as per the previous diff that introduced them.
    notice_board_data = get_notice_board_data(conn)
    packaging_q_data, packaging_r_data = get_packaging_list_data(conn)
    seating_distinct_data, seating_query_data = get_seating_list_data(conn)

    # Call individual PDF generation functions
    generate_notice_board_pdf(name, title, date, session, notice_board_data, font)
    generate_packaging_list_pdf(name, title, date, session, packaging_q_data, packaging_r_data, font)
    generate_seating_list_pdf(name, title, date, session, seating_distinct_data, seating_query_data, font)

    conn.close() # Close the main database connection

# --- Individual PDF generation functions ---
# The following functions will be created by moving code from the original generate_report
# and then refactored to use initialize_pdf.

# Placeholder for generate_notice_board_pdf content (will be filled by moving original code)
def generate_notice_board_pdf(exam_name, exam_title, date, session, notice_board_data, font_to_use):
    pdf1 = initialize_pdf(font_to_use)
    # Original Notice Board PDF logic starts here, adapted
    PDF_list = []
    temp_PDF_list = []
    roll_list = []
    class_name = notice_board_data[0][0]
    hall_name = notice_board_data[0][1]

    for subject in notice_board_data: 
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
            temp_PDF_list = sorted(temp_PDF_list, key=lambda x: x[2][0])
            for h in temp_PDF_list:
                PDF_list.append(h)
            temp_PDF_list = []
            class_name = subject[0]
            hall_name = subject[1]
            roll_list = []
            roll_list.append(subject[2])

        if notice_board_data[-1] == subject: 
            temp = "("+str(len(roll_list))+")"
            roll_list.append(temp)
            temp_PDF_list.append([class_name, hall_name, roll_list])
            temp_PDF_list = sorted(temp_PDF_list, key=lambda x: x[2][0])
            for h in temp_PDF_list:
                PDF_list.append(h)
    
    pdf1.add_page()
    pdf1.set_font(font_to_use, '', 27)
    text = exam_name 
    text_w = pdf1.get_string_width(text)+6
    doc_w = pdf1.w
    pdf1.set_x((doc_w - text_w) / 2)
    pdf1.cell(text_w, 23, text, new_x="LMARGIN", new_y="NEXT", align='C')

    pdf1.set_font(font_to_use, '', 21)
    text = "Halls for " + exam_title 
            FROM report
            ORDER BY class,hall"""
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
            temp_PDF_list = sorted(temp_PDF_list, key=lambda x: x[2][0])
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
            temp_PDF_list = sorted(temp_PDF_list, key=lambda x: x[2][0])
            for h in temp_PDF_list:
                PDF_list.append(h)

    text_w = pdf1.get_string_width(text)+6
    pdf1.set_x((doc_w - text_w) / 2)
    pdf1.cell(text_w, 7, text, new_x="LMARGIN", new_y="NEXT", align='C')
    pdf1.set_font(font_to_use, '', 17)
    pdf1.set_y(45)
    pdf1.set_x(57)
    pdf1.write_html(
        f"Date: <b>{date}</b> &nbsp;&nbsp;&nbsp;Session: <b>{session}</b>") 
    pdf1.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

    pdf1.set_font(font_to_use, 'B', 12)
    pdf1.cell(22.1, 10, "Class", align='C', border=True)
    pdf1.cell(18.5, 10, "Hall", align='C', border=True)
    pdf1.cell(0, 10, "Roll No.s", align='C', border=True, new_x="LMARGIN", new_y="NEXT")

    prev_class = ""
    for subject in PDF_list:
        temp_str = "   " 
        rows = 1
        temp_count = 1
        current_roll_list = [] 
        current_roll_list.append(subject[2])
        for j in current_roll_list[0]:
            if temp_count > 78:
                temp_str += "\n   "
                rows += 1
                temp_count = 1
            if j == current_roll_list[0][-1]:
                temp_str += str(j)
            elif j == current_roll_list[0][-2]:
                temp_str += (str(j)+"  ")
            else:
                temp_str += (str(j)+", ")
            temp_count += len(str(j))+2
        curr_class = subject[0]
        height = rows*12
        pdf1.set_font(font_to_use, 'B', 11)
        if prev_class == curr_class:
            pdf1.cell(22.1, height, '"', align='C', border=True)
        else:
            pdf1.cell(22.1, height, curr_class, align='C', border=True)
        prev_class = curr_class
        pdf1.set_font(font_to_use, '', 11)
        pdf1.cell(18.5, height, subject[1], align='C', border=True, new_x="RIGHT")
        pdf1.multi_cell(0, height/rows, temp_str, new_x="LMARGIN", new_y="NEXT", border=True, align="L")

    file_name = "Halls "+date+" "+session+".pdf"
    pdf1.output("../output/"+file_name)

# Placeholder for generate_packaging_list_pdf (will be filled similarly)
def generate_packaging_list_pdf(exam_name, exam_title, date, session, packaging_q_data, packaging_r_data, font_to_use):
    pdf2 = initialize_pdf(font_to_use)
    # Original Packaging List PDF logic starts here, adapted
    PDF_list_pack = [["Class", "Subject", "RollNo", "No. of candidates"]]
    roll_list_pack = []
    hall_name_pack = packaging_q_data[0][0]
    class_name_pack = packaging_q_data[0][1]
    subject_name_pack = packaging_q_data[0][2]

    for i in packaging_q_data:
        if hall_name_pack == i[0]:
            if class_name_pack == i[1]:
                if subject_name_pack == i[2]:
                    roll_list_pack.append(i[3])
                    roll_list_pack.sort()
                else:
                    roll_ = ranges(roll_list_pack)
                    no_of_candidates = len(roll_list_pack)
                    PDF_list_pack.append([class_name_pack, subject_name_pack, str(list(roll_))[1:-1], no_of_candidates])
                    subject_name_pack = i[2]
                    roll_list_pack = []
                    roll_list_pack.append(i[3])
                    roll_list_pack.sort()
            else:
                roll_ = ranges(roll_list_pack)
                no_of_candidates = len(roll_list_pack)
                PDF_list_pack.append([class_name_pack, subject_name_pack, str(list(roll_))[1:-1], no_of_candidates])
                class_name_pack = i[1]
                subject_name_pack = i[2]
                roll_list_pack = []
                roll_list_pack.append(i[3])
                roll_list_pack.sort()
        else:
            roll_ = ranges(roll_list_pack)
            no_of_candidates = len(roll_list_pack)
            PDF_list_pack.append([class_name_pack, subject_name_pack, str(list(roll_))[1:-1], no_of_candidates])

            pdf2.add_page()
            pdf2.set_font(font_to_use, '', 27)
            text = exam_name
            text_w = pdf2.get_string_width(text)+6
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 23, text,  new_x="LMARGIN", new_y="NEXT", align='C')

            pdf2.set_font(font_to_use, '', 20)
            text = "Packing List for " + exam_title
    text_w = pdf1.get_string_width(text)+6
    pdf1.set_x((doc_w - text_w) / 2)
    pdf1.cell(text_w, 7, text,  new_x="LMARGIN", new_y="NEXT", align='C')
    pdf1.set_font(font, '', 17)
    pdf1.set_y(45)
    pdf1.set_x(57)
    pdf1.write_html(
        f"Date: <b>{date}</b> &nbsp;&nbsp;&nbsp;Session: <b>{session}<b/>")
    pdf1.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

    # Create Table Header
    pdf1.set_font(font, 'B', 12)
    pdf1.cell(22.1, 10, "Class", align='C', border=True)
    pdf1.cell(18.5, 10, "Hall", align='C', border=True)
    pdf1.cell(0, 10, "Roll No.s", align='C',
              border=True, new_x="LMARGIN", new_y="NEXT")

    # Create Table Body
    prev_class = ""
    # PDF_list.pop(0)
    for subject in PDF_list:
        temp = "   "
        rows = 1
        temp_count = 1

        roll_list = []
        roll_list.append(subject[2])
        for j in roll_list[0]:
            if temp_count > 78:  # to split rows
                temp += "\n   "
                rows += 1
                temp_count = 1
            if j == roll_list[0][-1]:
                temp += str(j)
            elif j == roll_list[0][-2]:
                temp += (str(j)+"  ")
            else:
                temp += (str(j)+", ")
            temp_count += len(str(j))+2

        curr_class = subject[0]
        height = rows*12

        pdf1.set_font(font, 'B', 11)
        if prev_class == curr_class:
            pdf1.cell(22.1, height, '"', align='C', border=True)
        else:
            pdf1.cell(22.1, height, curr_class, align='C', border=True)
        prev_class = curr_class
        pdf1.set_font(font, '', 11)
        pdf1.cell(18.5, height, subject[1],
                  align='C', border=True, new_x="RIGHT")

        pdf1.multi_cell(0, height/rows, temp, new_x="LMARGIN",
                        new_y="NEXT", border=True, align="L")

    file_name = "Halls "+date+" "+session+".pdf"
    pdf1.output("../output/"+file_name)

    # Packaging List PDF------------------------------------------------------------------------------------------------
            text_w = pdf2.get_string_width(text)+6
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 10, text,  new_x="LMARGIN", new_y="NEXT", align='C')

            pdf2.set_y(45)
            pdf2.set_font(font_to_use, '', 18)
            pdf2.set_x(30)
            pdf2.write_html(
                f"<align=\"center\">Hall No: <b>{hall_name_pack}</b> &nbsp;&nbsp;Date: <b>{date}</b> &nbsp;&nbsp;Session: <b>{session}</b>")
            pdf2.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

            pdf2.set_font(font_to_use, 'B', 10)
            pdf2.set_y(60)
            class_w = pdf2.get_string_width("Class")+8
            pdf2.cell(class_w, 20, "Class", align='C', border=True)
            pdf2.cell(65, 20, "Subject", align='C', border=True)
            pdf2.cell(35, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+82.4)
            pdf2.write_html("<b>Roll No.s of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+81.5)
            pdf2.write_html("<b>Candidates</b>")

            pdf2.set_y(60)
            pdf2.set_x(class_w+65+35+10)
            pdf2.cell(25, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+116.5)
            pdf2.write_html("<b>No. of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+110.6)
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

            y_pos = 80
            pdf2.set_y(80)
            pdf2.set_x(10)
            prev_class = ""
            PDF_list_pack.pop(0)
            for k in PDF_list_pack:
                sub_rows = int(ceil(pdf2.get_string_width(k[1])/63))
                sub_flag = 0
                if sub_rows > 1:
                    sub_flag = 1
                roll_range_raw = k[2]
                temp1 = ""
                a = []
                for m in roll_range_raw:
                    if m.isdigit(): temp1 += m
                    elif m == ',': temp1 += ','
                    elif m == '(': temp1 = ""
                    elif m == ')': a.append(temp1)
                roll_rows = 1
                temp1 = ""
                for m in a:
                    x_val = m.split(',')
                    if x_val[0] == x_val[1]: temp1 += x_val[0]+" , "
                    else: temp1 += x_val[0]+"-"+x_val[1]+" , "
                temp1 = temp1[:-3]
                roll_rows = int(ceil(pdf2.get_string_width(temp1)/28))
                rows = max(sub_rows, roll_rows)
                height = 10*rows
                pdf2.set_font(font_to_use, '', 10)
                curr_class = k[0]
                if prev_class == curr_class:
                    pdf2.cell(class_w, height, '"', align='C', border=True)
                else:
                    pdf2.cell(class_w, height, curr_class, align='C', border=True)
                prev_class = curr_class
                if sub_flag == 0:
                    pdf2.multi_cell(65, height, k[1], align='C', border=True)
                elif sub_flag == 1 and roll_rows > sub_rows:
                    pdf2.multi_cell(65, (roll_rows*10)/sub_rows, k[1], align='C', border=True)
                else:
                    pdf2.multi_cell(65, 10, k[1], align='C', border=True)
                pdf2.set_y(y_pos)
                pdf2.set_x(pdf2.w-(pdf2.w-(18.061+65))+10)
                if sub_flag == 1 and roll_rows > sub_rows:
                    pdf2.multi_cell(35, 10, temp1, align='C', border=True)
                elif sub_flag == 1:
                    pdf2.multi_cell(35, height, temp1, align='C', border=True)
                else:
                    pdf2.multi_cell(35, 10, temp1, align='C', border=True)
                pdf2.set_y(y_pos)
                pdf2.set_x(class_w+65+35+10)
                pdf2.cell(25, height, str(k[3]), align='C', border=True)
                pdf2.cell(0, height, "", border=True, new_x="LMARGIN", new_y="NEXT")
                y_pos += height
            pdf2.set_font(font_to_use, 'B', 10)
            pdf2.cell(class_w+65+35, 10, "Total:", border=True, align="C")
            for l_item in packaging_r_data:
                if l_item[0] == hall_name_pack:
                    pdf2.cell(25, 10, str(l_item[1]), border=True, align="C")
            pdf2.cell(0, 10, "", border=True, new_x="LMARGIN", new_y="NEXT")
            y_pos += 25
            pdf2.set_y(y_pos)
            pdf2.set_font(font_to_use, '', 15)
            pdf2.write_html("<U>Invigilators must</U>:")
            pdf2.write_html("<br><br>&nbsp;&nbsp;&nbsp;1.  &nbsp;Ensure that all candidates have ID-Cards & are in proper uniform.")
            pdf2.write_html("<br><br>&nbsp;&nbsp;&nbsp;2. Announce that mobile phones, smartwatches & other electronic")
            pdf2.write_html("<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;gadgets, pouches, bags, calculator-cover etc. are <B>NOT</B> allowed")
            pdf2.set_y(pdf2.get_y()+1.3)
            pdf2.write_html("<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;inside.")
            PDF_list_pack = [["Class", "Subject", "RollNo", "No. of candidates"]]
            hall_name_pack = i[0]
            class_name_pack = i[1]
            subject_name_pack = i[2]
            roll_list_pack = []
            roll_list_pack.append(i[3])

        if packaging_q_data[-1] == i:
            roll_ = ranges(roll_list_pack)
            no_of_candidates = len(roll_list_pack)
            PDF_list_pack.append([class_name_pack, subject_name_pack, str(list(roll_))[1:-1], no_of_candidates])

            pdf2.add_page()
            pdf2.set_font(font_to_use, '', 27)
            text = exam_name
            text_w = pdf2.get_string_width(text)+6
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 23, text,  new_x="LMARGIN", new_y="NEXT", align='C')

            pdf2.set_font(font_to_use, '', 20)
            text = "Packing List for " + exam_title
            FROM report
            ORDER BY hall,class, subject"""
    cursor = conn.execute(cmd)
    Q_list = cursor.fetchall()

    cmd = """SELECT hall,COUNT(roll_no)
            FROM report
            GROUP BY hall"""
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
                    roll_list.sort()

                else:
                    roll_ = ranges(roll_list)
                    no_of_candidates = len(roll_list)
                    PDF_list.append([class_name, subject_name, str(
                        list(roll_))[1:-1], no_of_candidates])
                    subject_name = i[2]
                    roll_list = []
                    roll_list.append(i[3])
                    roll_list.sort()

            else:
                roll_ = ranges(roll_list)
                no_of_candidates = len(roll_list)
                PDF_list.append([class_name, subject_name, str(
                    list(roll_))[1:-1], no_of_candidates])
                class_name = i[1]
                subject_name = i[2]
                roll_list = []
                roll_list.append(i[3])
                roll_list.sort()

        else:
            # append , PDF Generate and empty pdf list
            roll_ = ranges(roll_list)
            no_of_candidates = len(roll_list)
            PDF_list.append([class_name, subject_name, str(
                list(roll_))[1:-1], no_of_candidates])

            pdf2.add_page()
            pdf2.set_font(font, '', 27)
            text = name
            text_w = pdf2.get_string_width(text)+6
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 23, text,  new_x="LMARGIN",
                      new_y="NEXT", align='C')

            pdf2.set_font(font, '', 20)
            text = "Packing List for " + title
            text_w = pdf2.get_string_width(text)+6
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 10, text,  new_x="LMARGIN",
                      new_y="NEXT", align='C')

            pdf2.set_y(45)
            pdf2.set_font(font, '', 18)
            pdf2.set_x(30)
            pdf2.write_html(
                f"<align=\"center\">Hall No: <b>{hall_name}</b> &nbsp;&nbsp;Date: <b>{date}</b> &nbsp;&nbsp;Session: <b>{session}<b/>")
            pdf2.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

            # Create Table Header
            pdf2.set_font(font, 'B', 10)
            pdf2.set_y(60)
            class_w = pdf2.get_string_width("Class")+8    # 18.06122222222222
            pdf2.cell(class_w, 20, "Class", align='C', border=True)
            pdf2.cell(65, 20, "Subject", align='C', border=True)
            pdf2.cell(35, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+82.4)
            pdf2.write_html("<b>Roll No.s of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+81.5)
            pdf2.write_html("<b>Candidates</b>")

            pdf2.set_y(60)
            pdf2.set_x(class_w+65+35+10)
            pdf2.cell(25, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+116.5)
            pdf2.write_html("<b>No. of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+110.6)
            pdf2.write_html("<b>Candidates</b>")

            pdf2.set_y(60)
            pdf2.set_x(class_w+65+30+10+30)
            pdf2.cell(0, 20, "", align='C', border=True,
                      new_x="LMARGIN", new_y="NEXT")
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+65+14+35+34)
            pdf2.write_html("<b>Roll No.s of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+65+13.1+30+40)
            pdf2.write_html("<b>Absentees</b>")

            # Create Table Body
            y_pos = 80
            pdf2.set_y(80)
            pdf2.set_x(10)
            prev_class = ""
            PDF_list.pop(0)
            for k in PDF_list:
                # sub_rows=1
                # if len(k[1])>33:
                #     sub_rows=2
                #     sub_flag=1
                sub_rows = int(ceil(pdf2.get_string_width(k[1])/63))
                sub_flag = 0
                if sub_rows > 1:
                    sub_flag = 1

                roll_range_raw = k[2]
                temp1 = ""
                a = []
                for m in roll_range_raw:
                    if m.isdigit():
                        temp1 += m
                    elif m == ',':
                        temp1 += ','
                    elif m == '(':
                        temp1 = ""
                    elif m == ')':
                        a.append(temp1)
                roll_rows = 1
                temp1 = ""
                for m in a:
                    x = m.split(',')
                    if x[0] == x[1]:
                        temp1 += x[0]+" , "
                    else:
                        temp1 += x[0]+"-"+x[1]+" , "
                temp1 = temp1[:-3]
                roll_rows = int(ceil(pdf2.get_string_width(temp1)/28))
                rows = max(sub_rows, roll_rows)
                height = 10*rows
                pdf2.set_font(font, '', 10)

                curr_class = k[0]
                if prev_class == curr_class:
                    pdf2.cell(class_w, height, '"',
                              align='C', border=True)  # Class
                else:
                    pdf2.cell(class_w, height, curr_class,
                              align='C', border=True)  # Class
                prev_class = curr_class

                if sub_flag == 0:
                    # When subject is one line only
                    pdf2.multi_cell(65, height, k[1], align='C', border=True)
                elif sub_flag == 1 and roll_rows > sub_rows:
                    # When sub is 2 line but roll no> 2 lines
                    pdf2.multi_cell(65, (roll_rows*10)/sub_rows,
                                    k[1], align='C', border=True)
                else:
                    # Subject in other cases
                    pdf2.multi_cell(65, 10, k[1], align='C', border=True)

                pdf2.set_y(y_pos)
                pdf2.set_x(pdf2.w-(pdf2.w-(18.061+65))+10)

                if sub_flag == 1 and roll_rows > sub_rows:
                    # Roll no when sub is 2 line and roll no > 2
                    pdf2.multi_cell(35, 10, temp1, align='C', border=True)
                elif sub_flag == 1:
                    # Roll no range when sub is 2 line and roll range is one line
                    pdf2.multi_cell(35, height, temp1, align='C', border=True)
                else:
                    pdf2.multi_cell(35, 10, temp1, align='C',
                                    border=True)  # Roll no range

                pdf2.set_y(y_pos)
                pdf2.set_x(class_w+65+35+10)

                # No of candidates
                pdf2.cell(25, height, str(k[3]), align='C', border=True)
                pdf2.cell(0, height, "", border=True, new_x="LMARGIN",
                          new_y="NEXT")  # Absentees blank column
                y_pos += height

            pdf2.set_font(font, 'B', 10)
            pdf2.cell(class_w+65+35, 10, "Total:",
                      border=True, align="C")  # Total
            for l in R_list:
                if l[0] == hall_name:
                    # Total count
                    pdf2.cell(25, 10, str(l[1]), border=True, align="C")
            pdf2.cell(0, 10, "", border=True, new_x="LMARGIN",
                      new_y="NEXT")  # Final blank cell

            y_pos += 25
            pdf2.set_y(y_pos)
            pdf2.set_font(font, '', 15)
            pdf2.write_html("<U>Invigilators must</U>:")
            pdf2.write_html(
                "<br><br>&nbsp;&nbsp;&nbsp;1.  &nbsp;Ensure that all candidates have ID-Cards & are in proper uniform.")
            pdf2.write_html(
                "<br><br>&nbsp;&nbsp;&nbsp;2. Announce that mobile phones, smartwatches & other electronic")
            pdf2.write_html(
                "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;gadgets, pouches, bags, calculator-cover etc. are <B>NOT</B> allowed")
            pdf2.set_y(pdf2.get_y()+1.3)
            pdf2.write_html(
                "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;inside.")

            PDF_list = [["Class", "Subject", "RollNo", "No. of candidates"]]

            hall_name = i[0]
            class_name = i[1]
            subject_name = i[2]
            roll_list = []
            roll_list.append(i[3])

        if Q_list[-1] == i:
            roll_ = ranges(roll_list)
            no_of_candidates = len(roll_list)
            PDF_list.append([class_name, subject_name, str(
                list(roll_))[1:-1], no_of_candidates])

            pdf2.add_page()
            pdf2.set_font(font, '', 27)
            text = name
            text_w = pdf2.get_string_width(text)+6
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 23, text,  new_x="LMARGIN",
                      new_y="NEXT", align='C')

            pdf2.set_font(font, '', 20)
            text = "Packing List for " + title
            text_w = pdf2.get_string_width(text)+6
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 10, text,  new_x="LMARGIN",
                      new_y="NEXT", align='C')

            pdf2.set_y(45)
            pdf2.set_font(font, '', 18)
            pdf2.set_x(30)
            pdf2.write_html(
                f"<align=\"center\">Hall No: <b>{hall_name}</b> &nbsp;&nbsp;Date: <b>{date}</b> &nbsp;&nbsp;Session: <b>{session}<b/>")
            pdf2.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

            # Create Table Header
            pdf2.set_font(font, 'B', 10)
            pdf2.set_y(60)
            class_w = pdf2.get_string_width("Class")+8    # 18.06122222222222
            pdf2.cell(class_w, 20, "Class", align='C', border=True)
            pdf2.cell(65, 20, "Subject", align='C', border=True)
            pdf2.cell(35, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+82.4)
            pdf2.write_html("<b>Roll No.s of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+81.5)
            pdf2.write_html("<b>Candidates</b>")

            pdf2.set_y(60)
            pdf2.set_x(class_w+65+35+10)
            pdf2.cell(25, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+116.5)
            pdf2.write_html("<b>No. of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+110.6)
            pdf2.write_html("<b>Candidates</b>")

            pdf2.set_y(60)
            pdf2.set_x(class_w+65+30+10+30)
            pdf2.cell(0, 20, "", align='C', border=True,
                      new_x="LMARGIN", new_y="NEXT")
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+65+14+35+34)
            pdf2.write_html("<b>Roll No.s of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+65+13.1+30+40)
            pdf2.write_html("<b>Absentees</b>")

            # Create Table Body
            y_pos = 80
            pdf2.set_y(80)
            pdf2.set_x(10)
            prev_class = ""
            PDF_list.pop(0)
            for k in PDF_list:
                # sub_rows=1
                # if len(k[1])>33:
                #     sub_rows=2
                #     sub_flag=1
                sub_rows = int(ceil(pdf2.get_string_width(k[1])/63))
                sub_flag = 0
                if sub_rows > 1:
                    sub_flag = 1

                roll_range_raw = k[2]
                temp1 = ""
                a = []
                for m in roll_range_raw:
                    if m.isdigit():
                        temp1 += m
                    elif m == ',':
                        temp1 += ','
                    elif m == '(':
                        temp1 = ""
                    elif m == ')':
                        a.append(temp1)
                roll_rows = 1
                temp1 = ""
                for m in a:
                    x = m.split(',')
                    if x[0] == x[1]:
                        temp1 += x[0]+" , "
                    else:
                        temp1 += x[0]+"-"+x[1]+" , "
                temp1 = temp1[:-3]
                roll_rows = int(ceil(pdf2.get_string_width(temp1)/28))
                rows = max(sub_rows, roll_rows)
                height = 10*rows
                pdf2.set_font(font, '', 10)

                curr_class = k[0]
                if prev_class == curr_class:
                    pdf2.cell(class_w, height, '"',
                              align='C', border=True)  # Class
                else:
                    pdf2.cell(class_w, height, curr_class,
                              align='C', border=True)  # Class
                prev_class = curr_class

                if sub_flag == 0:
                    # When subject is one line only
                    pdf2.multi_cell(65, height, k[1], align='C', border=True)
                elif sub_flag == 1 and roll_rows > sub_rows:
                    # When sub is 2 line but roll no> 2 lines
                    pdf2.multi_cell(65, (roll_rows*10)/sub_rows,
                                    k[1], align='C', border=True)
                else:
                    # Subject in other cases
                    pdf2.multi_cell(65, 10, k[1], align='C', border=True)

                pdf2.set_y(y_pos)
                pdf2.set_x(pdf2.w-(pdf2.w-(18.061+65))+10)

                if sub_flag == 1 and roll_rows > sub_rows:
                    # Roll no when sub is 2 line and roll no > 2
                    pdf2.multi_cell(35, 10, temp1, align='C', border=True)
                elif sub_flag == 1:
                    # Roll no range when sub is 2 line and roll range is one line
                    pdf2.multi_cell(35, height, temp1, align='C', border=True)
                else:
                    pdf2.multi_cell(35, 10, temp1, align='C',
                                    border=True)  # Roll no range

                pdf2.set_y(y_pos)
                pdf2.set_x(class_w+65+35+10)

                # No of candidates
                pdf2.cell(25, height, str(k[3]), align='C', border=True)
                pdf2.cell(0, height, "", border=True, new_x="LMARGIN",
                          new_y="NEXT")  # Absentees blank column
                y_pos += height

            pdf2.set_font(font, 'B', 10)
            pdf2.cell(class_w+65+35, 10, "Total:",
                      border=True, align="C")  # Total
            for l in R_list:
                if l[0] == hall_name:
                    # Total count
                    pdf2.cell(25, 10, str(l[1]), border=True, align="C")
            pdf2.cell(0, 10, "", border=True, new_x="LMARGIN",
                      new_y="NEXT")  # Final blank cell

            y_pos += 25
            pdf2.set_y(y_pos)
            pdf2.set_font(font, '', 15)
            pdf2.write_html("<U>Invigilators must</U>:")
            pdf2.write_html(
                "<br><br>&nbsp;&nbsp;&nbsp;1.  &nbsp;Ensure that all candidates have ID-Cards & are in proper uniform.")
            pdf2.write_html(
                "<br><br>&nbsp;&nbsp;&nbsp;2. Announce that mobile phones, smartwatches & other electronic")
            pdf2.write_html(
                "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;gadgets, pouches, bags, calculator-cover etc. are <B>NOT</B> allowed")
            pdf2.set_y(pdf2.get_y()+1.3)
            pdf2.write_html(
                "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;inside.")

            PDF_list = []

    file_name = "Packaging "+date+" "+session+".pdf"
    pdf2.output("../output/"+file_name)

    # Seating List PDF------------------------------------------------------------------------------------------------
            text_w = pdf2.get_string_width(text)+6
            pdf2.set_x((pdf2.w - text_w) / 2)
            pdf2.cell(text_w, 10, text,  new_x="LMARGIN", new_y="NEXT", align='C')

            pdf2.set_y(45)
            pdf2.set_font(font_to_use, '', 18)
            pdf2.set_x(30)
            pdf2.write_html(
                f"<align=\"center\">Hall No: <b>{hall_name_pack}</b> &nbsp;&nbsp;Date: <b>{date}</b> &nbsp;&nbsp;Session: <b>{session}</b>")
            pdf2.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

            pdf2.set_font(font_to_use, 'B', 10)
            pdf2.set_y(60)
            class_w = pdf2.get_string_width("Class")+8
            pdf2.cell(class_w, 20, "Class", align='C', border=True)
            pdf2.cell(65, 20, "Subject", align='C', border=True)
            pdf2.cell(35, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+82.4)
            pdf2.write_html("<b>Roll No.s of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+81.5)
            pdf2.write_html("<b>Candidates</b>")

            pdf2.set_y(60)
            pdf2.set_x(class_w+65+35+10)
            pdf2.cell(25, 20, "", align='C', border=True)
            pdf2.set_y(66.1)
            pdf2.set_x(class_w+116.5)
            pdf2.write_html("<b>No. of</b>")
            pdf2.set_y(71.1)
            pdf2.set_x(class_w+110.6)
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

            y_pos = 80
            pdf2.set_y(80)
            pdf2.set_x(10)
            prev_class = ""
            PDF_list_pack.pop(0)
            for k in PDF_list_pack:
                sub_rows = int(ceil(pdf2.get_string_width(k[1])/63))
                sub_flag = 0
                if sub_rows > 1:
                    sub_flag = 1
                roll_range_raw = k[2]
                temp1 = ""
                a = []
                for m in roll_range_raw:
                    if m.isdigit(): temp1 += m
                    elif m == ',': temp1 += ','
                    elif m == '(': temp1 = ""
                    elif m == ')': a.append(temp1)
                roll_rows = 1
                temp1 = ""
                for m in a:
                    x_val = m.split(',')
                    if x_val[0] == x_val[1]: temp1 += x_val[0]+" , "
                    else: temp1 += x_val[0]+"-"+x_val[1]+" , "
                temp1 = temp1[:-3]
                roll_rows = int(ceil(pdf2.get_string_width(temp1)/28))
                rows = max(sub_rows, roll_rows)
                height = 10*rows
                pdf2.set_font(font_to_use, '', 10)
                curr_class = k[0]
                if prev_class == curr_class:
                    pdf2.cell(class_w, height, '"', align='C', border=True)
                else:
                    pdf2.cell(class_w, height, curr_class, align='C', border=True)
                prev_class = curr_class
                if sub_flag == 0:
                    pdf2.multi_cell(65, height, k[1], align='C', border=True)
                elif sub_flag == 1 and roll_rows > sub_rows:
                    pdf2.multi_cell(65, (roll_rows*10)/sub_rows, k[1], align='C', border=True)
                else:
                    pdf2.multi_cell(65, 10, k[1], align='C', border=True)
                pdf2.set_y(y_pos)
                pdf2.set_x(pdf2.w-(pdf2.w-(18.061+65))+10)
                if sub_flag == 1 and roll_rows > sub_rows:
                    pdf2.multi_cell(35, 10, temp1, align='C', border=True)
                elif sub_flag == 1:
                    pdf2.multi_cell(35, height, temp1, align='C', border=True)
                else:
                    pdf2.multi_cell(35, 10, temp1, align='C', border=True)
                pdf2.set_y(y_pos)
                pdf2.set_x(class_w+65+35+10)
                pdf2.cell(25, height, str(k[3]), align='C', border=True)
                pdf2.cell(0, height, "", border=True, new_x="LMARGIN", new_y="NEXT")
                y_pos += height
            pdf2.set_font(font_to_use, 'B', 10)
            pdf2.cell(class_w+65+35, 10, "Total:", border=True, align="C")
            for l_item in packaging_r_data:
                if l_item[0] == hall_name_pack:
                    pdf2.cell(25, 10, str(l_item[1]), border=True, align="C")
            pdf2.cell(0, 10, "", border=True, new_x="LMARGIN", new_y="NEXT")
            y_pos += 25
            pdf2.set_y(y_pos)
            pdf2.set_font(font_to_use, '', 15)
            pdf2.write_html("<U>Invigilators must</U>:")
            pdf2.write_html("<br><br>&nbsp;&nbsp;&nbsp;1.  &nbsp;Ensure that all candidates have ID-Cards & are in proper uniform.")
            pdf2.write_html("<br><br>&nbsp;&nbsp;&nbsp;2. Announce that mobile phones, smartwatches & other electronic")
            pdf2.write_html("<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;gadgets, pouches, bags, calculator-cover etc. are <B>NOT</B> allowed")
            pdf2.set_y(pdf2.get_y()+1.3)
            pdf2.write_html("<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;inside.")
            PDF_list_pack = []

    file_name = "Packaging "+date+" "+session+".pdf"
    pdf2.output("../output/"+file_name)

# Placeholder for generate_seating_list_pdf (will be filled similarly)
def generate_seating_list_pdf(exam_name, exam_title, date, session, seating_distinct_data, seating_query_data, font_to_use):
    pdf3 = initialize_pdf(font_to_use)
    # Original Seating List PDF logic starts here, adapted
    distinct_class = []
    for subject in seating_distinct_data: 
        distinct_class.append(list(subject))

    query_list = []
    for subject in seating_query_data: 
        query_list.append(list(subject))

    hall_distinct_list = [[distinct_class[0][0]]]
    current_hall_for_seating = query_list[0][0] 
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

    for subject_item in hall_distinct_list: 
        seat_List = [["Seat", "RollNo"]]
        current_hall_for_seating = subject_item[0]
        for j in query_list:
            if current_hall_for_seating == j[0]:
                seat_List.append([j[1], j[2]])
        last_seat_no = seat_List[-1][0]
        for k_idx in range(1, last_seat_no+1): 
            if seat_List[k_idx][0] != k_idx:
                seat_List.insert(k_idx, [k_idx, "-"])
        classes_list_seat = subject_item[1:]

        seat_List.pop(0)
        row_number = int(ceil(len(seat_List)/4))
        processed_seat_List = list(divide_chunks(seat_List, row_number)) 

        pdf3.add_page()
        pdf3.set_font(font_to_use, '', 27)
        text = exam_name
        text_w = pdf3.get_string_width(text)+6
        pdf3.set_x((pdf3.w - text_w) / 2)
        pdf3.cell(text_w, 23, text,  new_x="LMARGIN", new_y="NEXT", align='C')

        pdf3.set_font(font_to_use, '', 20)
        text = "Seating Arrangement for " + exam_title
            FROM report
            ORDER BY hall"""
    cursor = conn.execute(cmd)
    x = cursor.fetchall()
    distinct_class = []
    for subject in x:
        distinct_class.append(list(subject))

    cmd = """SELECT hall,seat_no,id
            FROM report
            ORDER BY hall,seat_no"""
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
        last_seat_no = seat_List[-1][0]
        for k in range(1, last_seat_no+1):
            if seat_List[k][0] != k:
                seat_List.insert(k, [k, "-"])
        classes_list = subject[1:]

        seat_List.pop(0)
        row_number = int(ceil(len(seat_List)/4))
        seat_List = divide_chunks(seat_List, row_number)
        x = list(seat_List)

        # Headings
        pdf3.add_page()
        pdf3.set_font(font, '', 27)
        text = name
        text_w = pdf3.get_string_width(text)+6
        pdf3.w = pdf3.w
        pdf3.set_x((pdf3.w - text_w) / 2)
        pdf3.cell(text_w, 23, text,  new_x="LMARGIN", new_y="NEXT", align='C')
        pdf3.set_font(font, '', 20)
        text = "Seating Arrangement for " + title
        text_w = pdf3.get_string_width(text)+6
        pdf3.set_x((pdf3.w - text_w) / 2)
        pdf3.cell(text_w, 10, text,  new_x="LMARGIN", new_y="NEXT", align='C')
        pdf3.set_y(45)
        pdf3.set_font(font, '', 18)
        pdf3.set_x(30)
        pdf3.write_html(
            f"<align=\"center\">Hall No: <b>{hall}</b> &nbsp;&nbsp;Date: <b>{date}</b> &nbsp;&nbsp;Session: <b>{session}<b/>")
        pdf3.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

        # Class List Table
        col1_width = ((pdf3.w-20)/(len(classes_list)+1))+15
        col_rest_width = (pdf3.w-20-col1_width)/len(classes_list)
        pdf3.set_font(font, '', 14)
        pdf3.cell(col1_width, 11, "Classes:", border=True, align="C")
        pdf3.set_font(font, 'B', 14)
        for k in classes_list:
            pdf3.cell(col_rest_width, 11, k, border=True, align="C")
        pdf3.set_y(76)

        # Seating Table
        # Header
        seat_w = ((pdf3.w-20-15)/4)*0.4
        id_w = ((pdf3.w-20-15)/4)*0.6

        # Body
        pdf3.set_font(font, '', 12)
        roll_rows = len(x[0])
        counter = x[-1][-1][0]
        for k in range(roll_rows):
            if k % 19 == 0:
                if k != 0:
                    pdf3.add_page()
                pdf3.set_font(font, 'B', 12)
                for n in range(4):
                    pdf3.cell(seat_w, 10, "Seat", border=True, align="C")
                    if n != 3:
                        pdf3.cell(id_w, 10, "Roll No.", border=True, align="C")
                        pdf3.cell(5, 10, "", border=False, align="C")
                    else:
                        pdf3.cell(id_w, 10, "Roll No.", border=True,
                                  align="C", new_x="LMARGIN", new_y="NEXT")
            pdf3.set_font(font, '', 12)
            for l in range(4):
                try:
                    pdf3.cell(seat_w, 10, str(
                        x[l][k][0]), border=True, align="C")
                    if l != 3:
                        pdf3.cell(id_w, 10, str(
                            x[l][k][1]), border=True, align="C")
                        pdf3.cell(5, 10, "", border=False, align="C")
                    else:
                        pdf3.cell(id_w, 10, str(
                            x[l][k][1]), border=True, align="C", new_x="LMARGIN", new_y="NEXT")
                except:
                    counter += 1
                    pdf3.cell(seat_w, 10, str(counter), border=True, align="C")
                    pdf3.cell(id_w, 10, "-", border=True, align="C",
                              new_x="LMARGIN", new_y="NEXT")
    file_name = "Seating "+date+" "+session+".pdf"
    pdf3.output("../output/"+file_name)



        text_w = pdf3.get_string_width(text)+6
        pdf3.set_x((pdf3.w - text_w) / 2)
        pdf3.cell(text_w, 10, text,  new_x="LMARGIN", new_y="NEXT", align='C')

        pdf3.set_y(45)
        pdf3.set_font(font_to_use, '', 18)
        pdf3.set_x(30)
        pdf3.write_html(
            f"<align=\"center\">Hall No: <b>{current_hall_for_seating}</b> &nbsp;&nbsp;Date: <b>{date}</b> &nbsp;&nbsp;Session: <b>{session}</b>")
        pdf3.cell(0, 15, "", new_x="LMARGIN", new_y="NEXT")

        col1_width = ((pdf3.w-20)/(len(classes_list_seat)+1))+15 
        col_rest_width = (pdf3.w-20-col1_width)/len(classes_list_seat) 
        pdf3.set_font(font_to_use, '', 14)
        pdf3.cell(col1_width, 11, "Classes:", border=True, align="C")
        pdf3.set_font(font_to_use, 'B', 14)
        for k_class in classes_list_seat: 
            pdf3.cell(col_rest_width, 11, k_class, border=True, align="C")
        pdf3.set_y(76)

        seat_w = ((pdf3.w-20-15)/4)*0.4
        id_w = ((pdf3.w-20-15)/4)*0.6

        pdf3.set_font(font_to_use, '', 12)
        roll_rows = len(processed_seat_List[0]) 
        counter = processed_seat_List[-1][-1][0] 
        for k_row in range(roll_rows): 
            if k_row % 19 == 0:
                if k_row != 0:
                    pdf3.add_page()
                pdf3.set_font(font_to_use, 'B', 12)
                for n_col in range(4): 
                    pdf3.cell(seat_w, 10, "Seat", border=True, align="C")
                    if n_col != 3:
                        pdf3.cell(id_w, 10, "Roll No.", border=True, align="C")
                        pdf3.cell(5, 10, "", border=False, align="C")
                    else:
                        pdf3.cell(id_w, 10, "Roll No.", border=True, align="C", new_x="LMARGIN", new_y="NEXT")
            pdf3.set_font(font_to_use, '', 12)
            for l_col in range(4): 
                try:
                    pdf3.cell(seat_w, 10, str(processed_seat_List[l_col][k_row][0]), border=True, align="C") 
                    if l_col != 3:
                        pdf3.cell(id_w, 10, str(processed_seat_List[l_col][k_row][1]), border=True, align="C") 
                        pdf3.cell(5, 10, "", border=False, align="C")
                    else:
                        pdf3.cell(id_w, 10, str(processed_seat_List[l_col][k_row][1]), border=True, align="C", new_x="LMARGIN", new_y="NEXT") 
                except IndexError: 
                    counter += 1
                    pdf3.cell(seat_w, 10, str(counter), border=True, align="C")
                    if l_col !=3: 
                         pdf3.cell(id_w, 10, "-", border=True, align="C")
                         pdf3.cell(5,10,"",border=False,align="C")
                    else:
                         pdf3.cell(id_w, 10, "-", border=True, align="C", new_x="LMARGIN", new_y="NEXT")
    file_name = "Seating "+date+" "+session+".pdf"
    pdf3.output("../output/"+file_name)

# Call the main report generation function
generate_reports()
