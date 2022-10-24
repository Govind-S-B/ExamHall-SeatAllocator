import json

list_to_generate = int(
    input("Generate: \nHall List(1) \nSubject List(2)\n"))

if list_to_generate == 1:
    halls = int(input("Enter number of halls: "))

    Halls = {}
    for i in range(halls):
        hall_name = input(
            "Enter Hall Name: ")
        capacity = int(input("Enter the capacity: "))
        columns = int(input("Enter the number of columns: "))

        Halls[hall_name] = [capacity, columns]

    with open('Halls.json', 'w') as fp:
        json.dump(Halls, fp)

elif list_to_generate == 2:
    mode = int(input("Value mode(1) or Continuous Range mode(2): "))
    Subjects = {}

    if mode == 1:
        subject_name = input("Enter the subject name: ")
        Subjects[subject_name] = []
        roll = input("Enter the roll number list: ")
        roll_list = roll.split(',')
        print(roll_list)

        for roll_ in roll_list:
            Subjects[subject_name].append(roll_)

    elif mode == 2:
        no_of_classes = int(input("Enter the number of classes: "))
        for class_ in range(0, no_of_classes):
            class_name = input("Enter class name: ")
            no_of_subjects = int(input("Enter the number of subjects: "))

            for subject_ in range(no_of_subjects):
                subject = input("Enter Subject: ")

                if subject in Subjects:
                    roll_no_range = input("Enter roll number range: ")
                    for roll_ in range(int(roll_no_range.split('-')[0]), int(roll_no_range.split('-')[1])+1):
                        Subjects[subject].append(class_name + '-' + str(roll_))
                else:
                    Subjects[subject] = []
                    roll_no_range = input("Enter roll number range: ")

                    for roll_ in range(int(roll_no_range.split('-')[0]), int(roll_no_range.split('-')[1])+1):
                        Subjects[subject].append(class_name + '-' + str(roll_))

    with open('Subjects.json', 'w') as fp:
        json.dump(Subjects, fp, indent=4)
