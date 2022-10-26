import sqlite3 as sq
from reportlab.platypus import SimpleDocTemplate
from reportlab.lib.pagesizes import letter
from reportlab.platypus import TableStyle
from reportlab.lib import colors
from reportlab.platypus import Table
from reportlab.pdfgen import canvas

def createpdf(data):

    fileName = 'pdfTable.pdf'
    pdf = SimpleDocTemplate(
        fileName,
        pagesize=letter)
    

    table = Table(data)

    # add style


    style = TableStyle([
        ('BACKGROUND', (0,0), (3,0), colors.green),
        ('TEXTCOLOR',(0,0),(-1,0),colors.whitesmoke),

        ('ALIGN',(0,0),(-1,-1),'CENTER'),

        ('FONTNAME', (0,0), (-1,0), 'Courier-Bold'),
        ('FONTSIZE', (0,0), (-1,0), 14),

        ('BOTTOMPADDING', (0,0), (-1,0), 12),

        ('BACKGROUND',(0,1),(-1,-1),colors.beige),
    ])
    table.setStyle(style)
    style1 = TableStyle([
        ('TEXTCOLOR',(0,0),(-1,0),colors.black),
        ('ALIGN',(0,0),(-1,-1),'CENTER'),
    ])

   
    # 2) Alternate backgroud color. Make changes here if needed alt colours 
    rowNumb = len(data)
    for i in range(1, rowNumb):
        if i % 2 == 0:
            bc = colors.white
        else:
            bc = colors.white
        
        ts = TableStyle(
            [('BACKGROUND', (0,i),(-1,i), bc)]
        )
        table.setStyle(ts)

    # 3) Add borders
    ts = TableStyle(
        [
        ('BOX',(0,0),(-1,-1),2,colors.black),

        ('LINEBEFORE',(2,1),(2,-1),2,colors.red),
        ('LINEABOVE',(0,2),(-1,2),2,colors.green),

        ('GRID',(0,1),(-1,-1),2,colors.black),
        ]
    )
    table.setStyle(ts)

    elems = []
    
    elems.append(table)
    pdf.build(elems)

conn = sq.connect("report.db")


# Notice board 

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
            PDF_list.append([class_name,hall_name,str(roll_list)[1:-1]])
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

createpdf(PDF_list)

