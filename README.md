# ExamHall-SeatAllocator | EHSA
Seat Allocating script for college exams ( swapna miss paranjond mathram )<br>

### Data Collection Format
<img src="https://user-images.githubusercontent.com/62943847/208335041-01fe287d-3959-4a95-96eb-ad83967b1c0c.jpg" width="500"><br>
Collecting data in this format will make it easier for data entry<br>

## How to use

### Json Generator
Use json_generator to create a json file containing your data <br>
Sample data can be found here https://github.com/Govind-S-B/ExamHall-SeatAllocator/tree/main/FINAL_BUILD/Backups <br>
<br>
To use Json Generator just launch the script<br>
<br>
1\. Select the mode <br>
text mode shows output on screen ( this is for testing / botching purposes : copy pasting data into json)<br>
json mode writes the data on file ( this is the required file for processing )<br>
<br>
2. Select the data you are going to input ( halls or subjects/classes list )<br>
<br>
3. In Halls mode <br>
enter the Hall name and the table count<br>
for benches the table count is a single number `30`<br>
for drawing halls the table count is a two part number `36 7`. The first indicating the number of benches and the second indicating the number of columns <br>
<br>
example : <br>
![image](https://user-images.githubusercontent.com/62943847/208368062-1722b871-98c4-401e-8954-376a0512df25.png)<br>
<br>
press done to exit the data entry loop<br>
<br>
4. In Subjects mode <br>
<br>
First enter the session name. eg:`12-12-2012 AN`<br>
<br>
Next enter the subjects list ( ie , name of all the subjects for which exams are beind conducted that session )<br>
![image](https://user-images.githubusercontent.com/62943847/208369199-5fb92125-1e5e-4f8e-8144-2f64d7e071d9.png)<br>
<br>
Next to enter each class and their subjects , roll number list<br>
<br>
Enter the Class Name<br>
**NOTE** : If a class has multiple subjects ( electives / minor ) enter the number of subjects along with the class name eg : `S3R1 2` ( this indicates that S3R2 has two subjects , by default this is treated as 1 and need not be entered along with the name eg:`S3R1`<br>
<br>
Choose the subject from the list of subjects entered earlier<br>
<br>
Enter the roll number list<br>
**NOTE** : This can be done as comma seperated distinct values and ranges ( inclusive of both ends )<br>
<br>
example : <br>
![image](https://user-images.githubusercontent.com/62943847/208370110-4ca6514b-e4a5-42cb-b21c-b7bbe365dece.png)<br>
<br>
press done to exit the data entry loop<br>
<br>


### Report Generator
Run report_generator to create your pdf <br>

### Drawing Hall Layout
<img src="https://user-images.githubusercontent.com/62943847/208338088-c07cbad2-cfde-4177-a800-2cfa30ba3d87.jpg" width="400">

# Archive
A bunch of previous dev logs / development process <br>
https://youtu.be/5hF7kAOf8Hg <br>
https://youtu.be/rd7YkNYW1LA <br>
https://youtu.be/FkvNkvsTHTw <br>
https://youtu.be/hHiUC9pe138 <br>
