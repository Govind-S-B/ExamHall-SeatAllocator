from reportlab.lib.pagesizes import letter
from reportlab.platypus import TableStyle
from reportlab.lib import colors
from reportlab.platypus import Table,Frame
from reportlab.pdfgen import canvas






def createpdf(fname,data,clg,sub,datesession): #datesession list containing date and session
    FileName =fname+".pdf"
    pdf = canvas.Canvas(FileName)
    pdf.setFont("Times-Roman", 20)
    pdf.drawCentredString(300,775, clg)
    pdf.setFont("Times-Roman", 20)
    pdf.drawCentredString(300,750, sub)
    pdf.setFont("Times-Roman", 20)
    pdf.drawCentredString(300,725, str(datesession)[1:-1])
    if (len(data))>35:
        dat = []
        del_list=[]
        for i in range(35,(len(data))):
            dat.append(data[i])
        for i in range(35,(len(data))):
            del_list.append(i)
        for i in sorted(del_list, reverse=True):
            del data[i]
        rdata= []
        rdata1= []
        for i in data:
            if (len(data[2])) <30:
                i[2]=str(i[2])[1:-1]
                rdata.append(i)
            else:
                leng = len(i[2])
                l1 = str(i[2][0:int(leng/2)])[1:-1]
                l2 = str(i[2][int(leng/2):leng])[1:-1]
                i[2] = l1
                f1 = ["     ","    ",l2]
                rdata.append(i)
                rdata.append(f1)
        for i in dat:
            if (len(i[2])) <30:
                i[2]=str(i[2])[1:-1]
                rdata1.append(i)
            else:
                leng = len(i[2])
                l1 = str(i[2][0:int(leng/2)])[1:-1]
                l2 = str(i[2][int(leng/2):leng])[1:-1]
                i[2] = l1
                f1 = ["     ","    ",l2]
                rdata1.append(i)
                rdata1.append(f1)

        obj=[]
        obj1=[]
        trow = Table(rdata)
        trow1= Table(rdata1)
        obj.append(trow)
        obj1.append(trow1)  
        ts= TableStyle([("GRID",(0,0),(-1,-1), 2, colors.black)])
        trow.setStyle(ts) 
        trow1.setStyle(ts)
        frame = Frame(20,20,550,650,showBoundary=1)
        frame.addFromList(obj, pdf)
        pdf.showPage()
        frame = Frame(20,20,550,650,showBoundary=1)
        frame.addFromList(obj1, pdf)
        pdf.save()

    else:
        rdata=[]
        for i in data:
            if (len(i[2])) <30:
                i[2]=str(i[2])[1:-1]
                rdata.append(i)
            else:
                leng = len(i[2])
                l1 = str(i[2][0:int(leng/2)])[1:-1]
                l2 = str(i[2][int(leng/2):leng])[1:-1]
                i[2] = l1
                f1 = ["     ","    ",l2]
                rdata.append(i)
                rdata.append(f1)
        obj=[]
        trow = Table(rdata)
        obj.append(trow)
        ts= TableStyle([("GRID",(0,0),(-1,-1), 2, colors.black)])
        trow.setStyle(ts)
        frame = Frame(20,20,550,650,showBoundary=1)
        frame.addFromList(obj, pdf)
        pdf.save()

#createpdf("Hello", data, "Marian Engineering College", "Internal Examination",["20/11/2022","fn"] )

def createpdf1(fname,data,clg,sub,datesession):#for seating arrangement
    FileName =fname+".pdf"
    pdf = canvas.Canvas(FileName)
    pdf.setFont("Times-Roman", 20)
    pdf.drawCentredString(300,800, clg)
    pdf.setFont("Times-Roman", 20)
    pdf.drawCentredString(300,775, sub)
    pdf.setFont("Times-Roman", 20)
    pdf.drawCentredString(300,750, str(datesession)[1:-1])
    length = (len(data))
    div = int((len(data))/4)
    dat1=[]
    dat2=[]
    dat3=[]
    dat4=[]
    for i in range(div):
        dat1.append(data[i])
    for i in range(div,(div*2)):
        dat2.append(data[i])
    for i in range((div*2),(div*3)):
        dat3.append(data[i])
    for i in range((div*3),(div*4)):
        dat4.append(data[i]) 
    obj=[]
    obj1=[]
    obj2=[]
    obj3=[]
    trow = Table(dat1)
    trow1 = Table(dat2)
    trow2 = Table(dat3)
    trow3 = Table(dat4)
    obj.append(trow)
    obj1.append(trow1)
    obj2.append(trow2)
    obj3.append(trow3)
    ts= TableStyle([("GRID",(0,0),(-1,-1), 2, colors.black)])
    trow.setStyle(ts)
    trow1.setStyle(ts)
    trow2.setStyle(ts)
    trow3.setStyle(ts)
    frame = Frame(20,20,183,700,showBoundary=0)
    frame.addFromList(obj, pdf)
    frame = Frame(180,20,183,700,showBoundary=0)
    frame.addFromList(obj1, pdf)
    frame = Frame(300,20,183,700,showBoundary=0)
    frame.addFromList(obj2, pdf)
    frame = Frame(420,20,183,700,showBoundary=0)
    frame.addFromList(obj3, pdf)
    pdf.save()
#createpdf1("Hello", data, "Marian Engineering College", "Internal Examination",["20/11/2022","fn"] ) #this is how you need to pass data




