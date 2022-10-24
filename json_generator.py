import json

print("Input Mode: \nJSON File \nJSON text")

print("Generate: \n1. Hall List \n2. Subject List")

print("Enter number of halls")

print("Enter details in the format \nHall_Name,Capacity,Columns\n")

print("Enter input mode 1.Subject Roll List 2.Class Subject distribution")

# mode 1 :  // value mode ( most probably used by uni exam)
#   subject name : mat102
#   enter roll list :
#       s2r1-32,s2r1-33,s2r1-34,s2r1-34

# mode 2 : // range mode
#   enter number of classes : 75
#   class name : s3r1
#   enter number of subjects : 1
#   enter subject : mat302
#   enter roll number ranges : 1-63

# make input functions depending on the requirements




# Output requirements
Halls = {"SJ310":[68,8],
        "SJ308":[57,5]}

Subjects = {"Discrete Mathematics":["s3r1-1","s3r1-2","s3r1-3","s3r1-4","s3r1-5","s3r1-6","s3r1-7","s3r1-8","s3r1-9"],
            "Object Oriented Programming with Java":["s3r2-1","s3r2-2","s3r2-3","s3r2-4","s3r2-5","s3r2-6","s3r2-7","s3r2-8","s3r2-9"]}

with open('Halls.json', 'w') as fp:
    json.dump(Halls, fp)

with open('Subjects.json', 'w') as fp:
    json.dump(Subjects, fp, indent=4)

# If teacher wants to fine control anything , or make verification , she can check the generated json file before running the report gen script
