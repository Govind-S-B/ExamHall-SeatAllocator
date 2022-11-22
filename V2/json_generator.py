import json

output_mode = int(input("Display Mode: (1)Text (2)JSON: "))

list_to_generate = int(
    input("Generate: Hall List(1) Subject List(2): "))

if list_to_generate == 1:
    halls = int(input("Enter number of halls: "))

    Halls = {}
    for i in range(halls):
        hall_name = input(
            "Enter Hall Name: ")
        capacity = int(input("Enter capacity: "))
        columns = int(input("Enter number of columns: "))

        Halls[hall_name] = [capacity, columns]
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

    no_of_classes = int(input("Enter number of classes: "))
    for class_ in range(0, no_of_classes):
        class_name = input("Enter class name: ")
        no_of_subjects = int(input("Enter number of subjects: "))

        for subject_ in range(no_of_subjects):
            subject = input("Enter Subject: ")

            if subject in Subjects:
                roll = input("Enter roll number list: ")
                roll_list = roll.split(',')
                for item in roll_list:
                    if "-" in item:
                        roll_no_range = item
                        for roll_ in range(int(roll_no_range.split('-')[0]), int(roll_no_range.split('-')[1])+1):
                            Subjects[subject].append(class_name + '-' + str(roll_))
                    else:
                        Subjects[subject].append(class_name + '-' + item)
            else:
                Subjects[subject] = []

                roll = input("Enter roll number list: ")
                roll_list = roll.split(',')
                for item in roll_list:
                    if "-" in item:
                        roll_no_range = item
                        for roll_ in range(int(roll_no_range.split('-')[0]), int(roll_no_range.split('-')[1])+1):
                            Subjects[subject].append(class_name + '-' + str(roll_))
                    else:
                        Subjects[subject].append(class_name + '-' + item)

    if output_mode == 1:
        print(json.dumps(Subjects, indent=4, sort_keys=True))

    elif output_mode == 2:
        with open('Subjects.json', 'w') as fp:
            json.dump(Subjects, fp, indent=4)

input("\n Enter any key to exit ")  # dummy input function to wait for user input to exit script
