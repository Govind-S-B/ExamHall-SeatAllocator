import json

check_array = set()

with open('Subjects.json', 'r') as JSON:
    subjects_json = json.load(JSON)
    subjects_json.pop("meta")

    for i in subjects_json:
        for j in subjects_json[i]:
            if j in check_array:
                print(i,j)
            else:
                check_array.add(j)