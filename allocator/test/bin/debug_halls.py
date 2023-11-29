import sqlite3 as sq
from termcolor import cprint
from itertools import product
import os

LETTERS = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
]

CLASS_COLORS = [
    "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
    "light_grey", "dark_grey", "light_red", "light_green", "light_yellow",
    "light_blue", "light_magenta", "light_cyan"
]

BACKGROUNDS = [
    "on_black",
    "on_red",
    "on_green",
    "on_yellow",
    "on_blue",
    "on_magenta",
    "on_cyan",
    "on_white",
    "on_light_grey",
    "on_dark_grey",
    "on_light_red",
    "on_light_green",
    "on_light_yellow",
    "on_light_blue",
    "on_light_magenta",
    "on_light_cyan"
]


directory_path = r"..\output"
sample_data = os.listdir(directory_path)

for file_name in sample_data:
    file_path = os.path.join(directory_path, file_name)
    # print(f"{file_path=}, {file_name=}")
    # print(file_path, file_name, sep=';')
    conn = sq.connect(file_path)
    cmd = "SELECT * FROM report ORDER BY hall,seat_no;"
    rows = conn.execute(cmd).fetchall()

    cmd = "SELECT DISTINCT subject FROM report ;"
    subjects = [row[0] for row in conn.execute(cmd)]
    letter = {sub: letter for (sub, letter) in zip(subjects, LETTERS)}
    # print(letter)

    cmd = "SELECT DISTINCT class FROM report ;"
    classes = [row[0] for row in conn.execute(cmd)]
    color_map = {class_name: color for (
        class_name, color) in zip(classes, product(BACKGROUNDS, CLASS_COLORS))}
    # print(color)

    # if len(subjects) > len(LETTERS) or len(classes) > len(COLORS):
    #     print(f"{len(subjects)=}, {len(LETTERS)=}, {len(classes)=}, {len(product(COLORS,)=}")
    #     raise ValueError

    # print("="*50)

    cur_hall = None
    for row in rows:
        id, class_name, roll_no, hall, seat_no, subject = row
        if cur_hall != hall:
            input("\npress enter to see next hall: ")
            cur_hall = hall
            print("\n")
            print(hall)
            print("")

        bg, class_color = color_map[class_name]
        cprint(letter[subject], class_color, bg, end=(
            "\n" if seat_no % 10 == 0 else ""))
