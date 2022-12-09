import json

output_mode = int(input("Display Mode: (1)Text (2)JSON: "))

list_to_generate = int(
    input("Generate: Hall List(1) Subject List(2): "))

if list_to_generate == 1:
    halls = int(input("Enter number of halls: "))

    # Bench(B) or Drawing Hall(D)
    Halls = {
        "B" : {},
        "D" : {}
    }
    

    for i in range(halls):
        hall_name = input("Hall Name: ")
        capacity = int(input("Table Count : "))

        cols = input("Coloumn Count : ") # leave empty if not a drawing hall
        if cols == "":
            Halls["B"][hall_name] = [capacity]
        else:
            cols = int(cols)
            Halls["D"][hall_name] = [capacity, cols]

    if output_mode == 2:
        with open('Halls.json', 'w') as fp:
            json.dump(Halls, fp)
    elif output_mode == 1:
        print(Halls)

elif list_to_generate == 2:

    session_name = input("Enter Session name: ")  # 12-04-2022 FN
    MetaInfo = {"Session_Name": session_name}
    Subjects = {}
    Subjects["meta"] = MetaInfo

    option = 1
    subject_list = {}

    print('Press "done" to exit')

    while True:
        subjects = str(input("Enter Subject name: "))
        if subjects.lower() == "done":
            break
        
        subject_list[option] = subjects
        option +=1

    print('Press "done" to exit')

    while True:
        class_name = input("Enter class name: ")
        if class_name.lower() == "done":
            break

        # count = classname.split() # s3r1 2 , s3r1 5 , something like this or simplu s3r1 if no electives
        # if len(count) == 1 , reperat below loop only once
        # else count = count[1]
        # take in one more argument with classname , ie the number of subjects , if none provided cosider 1 subject
        
        while True:
            for i in subject_list:
                print(f'{i} - {subject_list[i]}')
                
            subject = input("Enter Subject ID: ")
            if subject.lower() == "done":
                break
                
            subject_ID = int(subject)

            if subject_list[subject_ID] in Subjects:
                roll = input("Enter roll number list: ")
                roll_list = roll.split(',')
                for item in roll_list:
                    if "-" in item:
                        roll_no_range = item
                        for roll_ in range(int(roll_no_range.split('-')[0]), int(roll_no_range.split('-')[1])+1):
                            Subjects[subject_list[subject_ID]].append(class_name + '-' + str(roll_))
                    else:
                        Subjects[subject_list[subject_ID]].append(class_name + '-' + item)
            else:
                Subjects[subject_list[subject_ID]] = []

                roll = input("Enter roll number list: ")
                roll_list = roll.split(',')
                for item in roll_list:
                    if "-" in item:
                        roll_no_range = item
                        for roll_ in range(int(roll_no_range.split('-')[0]), int(roll_no_range.split('-')[1])+1):
                            Subjects[subject_list[subject_ID]].append(class_name + '-' + str(roll_))
                    else:
                        Subjects[subject_list[subject_ID]].append(class_name + '-' + item)

    if output_mode == 1:
        print(json.dumps(Subjects, indent=4))

    elif output_mode == 2:
        with open('Subjects.json', 'w') as fp:
            json.dump(Subjects, fp, indent=4)

input("\n Enter any key to exit ")  # dummy input function to wait for user input to exit script
