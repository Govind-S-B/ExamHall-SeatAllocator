from createPDF import PDF
AasishDataForHalls = [
    ["Seat No", "Roll No", "Subject"], #Headings
    ["1", "1", "Maths"], ["2", "4", "Maths"], ["3", "6", "Maths"], ["4", "22", "Maths"], ["5", "40", "Maths"], ["6", "7", "Maths"]
    ,["6", "7", "Maths"], ["6", "7", "Maths"], ["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"]
    ,["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],
    ["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"]
    ,["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"]
    ,["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"]
    ,["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"],["6", "7", "Maths"]#Content
]

AasishDataForNoticeB = [
    ["Class", "Hall Name", "Roll No"],  #Headings
    ["S3R1", "Sj305", "1-20"], ["S3R1", "Sj309", "20-40"],
    ["S3R2", "Sj305", "46-60"]
] #Content

AasishDataForHallO = [
    ["Class Roll No", "Seat No"], #Headings
    ["S3R1_1", "1"], ["S3R1_2", "2"], ["S3R2_23", "5"]  #Content
]


pdf = PDF()
pdf.add_page()
pdf.set_font("Times", size=8)


def halls(data, HallName, date, session):
    #clg = "Marian Engineering College"
    ha = "Packing List for Internal Examination"
    msg1 = "Invigilators must:"
    msg2 = "        1. Ensure that all candidates have ID-Cards & are in proper uniform."
    msg3 = "        2. Anounce that mobile phones, smartwatches & other electronic gadgets,"
    msg4 = "           pouches, bags, calculator-cover, etc. are NOT allowed inside."
    pdf.set_font("Times", size=20)
    #pdf.cell(0, 0, txt=clg, align='C', new_y="NEXT", new_x="LEFT",)
    #pdf.ln(10)

    pdf.cell(0, 0, txt=ha, align='C', new_y="NEXT", new_x="LEFT")
    pdf.ln(10)
    pdf.cell(0, 0, txt="Date:"+str(date), align='L')
    pdf.cell(0, 0, txt="Session:" + str(session), align='R')
    pdf.ln(10)

    pdf.create_table(table_data=data, cell_width='even')
    pdf.ln()
    pdf.set_font("Times", size=15)
    pdf.cell(0, 0, txt=msg1)
    pdf.ln(5)
    pdf.cell(0, 0, txt=msg2)
    pdf.ln(5)
    pdf.cell(0, 0, txt=msg3)
    pdf.ln(5)
    pdf.cell(0, 0, txt=msg4)
    pdf.output("HallPdf.pdf")


def notice(data, date, session):
    clg = "Marian Engineering College"
    ha = "Halls for Internal Examination"
    pdf.set_font("Times", size=20)
    pdf.cell(0, 0, txt=clg, align='C', new_y="NEXT", new_x="LEFT",)
    pdf.ln(10)
    pdf.cell(0, 0, txt=ha, align='C', new_y="NEXT", new_x="LEFT")
    pdf.ln(10)
    pdf.cell(0, 0, txt="Date:"+str(date), align='L')
    pdf.cell(0, 0, txt="Session:" + str(session), align='R')
    pdf.ln(10)
    pdf.create_table(table_data=data, cell_width='even',)
    pdf.ln()
    pdf.output("HallPdf.pdf")


def hallo(data, HallName, date, session):
    clg = "Marian Engineering College"
    ha = "Seating Arrangement for Internal Examination"
    pdf.set_font("Times", size=20)
    pdf.cell(0, 0, txt=clg, align='C', new_y="NEXT", new_x="LEFT",)
    pdf.ln(10)
    pdf.cell(0, 0, txt=ha, align='C', new_y="NEXT", new_x="LEFT")
    pdf.ln(10)
    pdf.set_font("Times", size=15)
    pdf.cell(0, 0, txt="Hall Name:" + str(HallName), align='L')
    pdf.cell(0, 0, txt="Session:" + str(session), align='R')
    pdf.ln(5)
    pdf.cell(0, 0, txt="Date:" + str(date), align='L')
    pdf.ln(10)
    pdf.create_table(table_data=data, title=HallName, cell_width='even',x_start='C')
    #pdf.ln()
    pdf.output("HallPdf.pdf")


notice(AasishDataForNoticeB, "12/12/12", "Fn")