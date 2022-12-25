
import json


def populate_halls(halls):
    print('\nPress "done" to exit\n')
    while True:
        hall_name = input("Hall Name: ")

        if hall_name.lower() == "done":
            break

        while True:
            args = input("Table Count: ").split()
            
            # ERROR HANDLING

            if len(args) > 2 or len(args) == 0:
                print("Error: invalid input")
                print("input should be of the form 'x' or 'x y' where x and y are numbers")
                continue

            arg_is_valid = True
            for num in args:
                try:
                    int(num)
                except ValueError:
                    print(f"Error: '{num}' is not a number")
                    arg_is_valid = False
            
            if not arg_is_valid:
                continue
            
            # by now the input should be 100% validated and can safely be used and put in the dictionary

            if len(args) == 1:
                halls["B"][hall_name] = [ int(args[0]) ]
            elif len(args) == 2:
                halls["D"][hall_name] = [int(args[0]),int(args[1])]

            break

        print()


def output_list(dictionary, mode, list_type):
    assert mode in [1, 2]
    assert list_type in [1, 2] # 1: Hall, 2: Subjects 
    
    indent = None if list_type == 1 else 4

    if mode == 1: # Text mode
        print()
        print(json.dumps(dictionary, indent=indent))

    elif mode == 2: #JSON Mode
        with open(f'{"Halls" if list_type == 1 else "Subjects"}.json', 'w') as fp:
            json.dump(dictionary, fp, indent=indent)


def generate_hall_JSON():
    
        # Bench(B) or Drawing Hall(D)
        halls = {
            "B": {},
            "D": {}
        }
        
        populate_halls(halls)
        return halls


def get_subject_list():
    print('\nPress "done" to exit\n')

    subjects = []
    while True:
        subject = str(input("Enter Subject Name: "))
        if subject.lower() == "done":
            break
        
        subjects.append(subject)
    return subjects



def generate_subject_JSON():
    session_name = input("Enter Session Name: ")  #eg: 12-04-2022 FN
    meta_info = {"Session_Name": session_name}
    Subjects = {}
    Subjects["meta"] = meta_info

    subject_list = get_subject_list()



    print('\nPress "done" to exit\n')

    while True:
        class_name = input("Enter Class Name: ")
        if class_name.lower() == "done":
            break

        args = class_name.split() # s3r1 2 , s3r1 5 , something like this or simplu s3r1 if no electives
        class_name = args[0]
        
        if len(args) == 1:
            count = 1 #, repeat below loop only once
        else:
            count = int(args[1])
        # take in one more argument with classname , ie the number of subjects , if none provided cosider 1 subject
        
        for i in range(count):
            for i in range(len(subject_list)):
                print(f'{i+1} - {subject_list[i]}')  # +1 because in code indexing starts from 0
                                                     # but for user indexing starts from 1
                
            subject = input("Enter Subject ID: ")
            if subject.lower() == "done":
                break
                
            subject_ID = int(subject) - 1 # -1 here for the same reasons as mentioned in the above comment 
            subject = subject_list[subject_ID]





            if subject not in Subjects:
                Subjects[subject] = []

            roll = input("Enter roll number list: ")
            roll_list = roll.split(',')
            for item in roll_list:
                if "-" in item:  # item is a roll_no range (eg: 1-20, 10-11 etc)
                    roll_no_range = item.split('-')
                    
                    lower_bound = int(roll_no_range[0])
                    upper_bound = int(roll_no_range[1]) + 1

                    for roll_no in range(lower_bound, upper_bound):
                        Subjects[subject].append(class_name + '-' + str(roll_no))

                else:  # item is an individual roll_no (eg: 1, 2, 10 etc)
                    Subjects[subject].append(class_name + '-' + str(item))
    return Subjects


# this is what gets exported
def generate_JSON():
    
    while True:
        output_mode = int(input("Display Mode: (1)Text, (2)JSON: "))

        if output_mode not in [1, 2]:
            print("please type 1 or 2")
            continue
        break

    while True:
        list_to_generate = int(input("Generate: (1)Hall List, (2)Subject List: "))

        if list_to_generate not in [1, 2]:
            print("please type 1 or 2")
            continue
        break



    if list_to_generate == 1: # Hall List
        generated_JSON = generate_hall_JSON()

    elif list_to_generate == 2: # Subject List
        generated_JSON = generate_subject_JSON()

    else:
        raise Exception("ERROR: selected JSON type not hall or subject")
    
    output_list(generated_JSON, output_mode, list_to_generate)

    input("\nEnter any key to exit ")  # dummy input function to wait for user input to exit script
