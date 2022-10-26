from reportlab.platypus import SimpleDocTemplate
from reportlab.lib.pagesizes import letter
from reportlab.platypus import TableStyle
from reportlab.lib import colors
from reportlab.platypus import Table
from reportlab.pdfgen import canvas
data= [["abc","123", "koppu"],["abc","123", "koppu"],["abc","123", "koppu"]]
def create(clg,sub,data):
    FileName ="REpo.pdf"
    pdf = canvas.Canvas(FileName)
    pdf.setFont("Courier-Bold", 24)
    pdf.drawCentredString(250,800, clg)
    pdf.setFont("Courier-Bold", 24)
    pdf.drawCentredString(250,750, sub)
    pdf1= SimpleDocTemplate(FileName, pagesize= letter)
    table = Table(data)
    elems= []
    elems.append(table)
    if cols ==3:
        pdf.drawBoundary("abcf",20,20,550,700)
        #pdf1.build(elems)
    pdf.save()

create("Marian", "Internal",data)
