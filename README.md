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
- for benches the table count is a single number `30`<br>
- for drawing halls the table count is a two part number `36 7`. The first indicating the number of benches and the second indicating the number of columns <br>
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

#### Advantages + A few Quirks of using JSON
- Human readable and therefore easy to edit the data even after entry using a simple text editor ( eg : changing subject names , combining different subjects into one , adding or removing halls / students )<br>
- With text mode in json generator , new data can be generated and copy pasted into the json file , in a sense botching together for edit functionality<br>
<br>


### Report Generator
Run report_generator to create your pdf <br>

Launch the script and enter the argument list for generation ( seed_value threshold_value dont_care) eg : 7 80 1
NOTE : If the argument list is empty , the default argument list is taken as 0 80 0 , to exit enter done

The seed value determines the shuffling around of students / classes among halls , so try various seed values to get different arrangements ( 0 is the default unrandomised seed )

The threshold value determines at what value ( number of students to allocate ) does it not matter that students of the same subject sit together as long as they are in different classes (ie, cases where everone has the same subject so its inevitable to pair students of the same subject together) . Put this at a high value so that it is not triggered easily
NOTE : The program will try its best to pair students with different subjects together , only if its not possible does it trigger this allocation logic ( logic = 2 )
Defalult value is 80

dont_care is a boolean and can be a 0 or 1 . If dont care is set to true , then it doesnt care if same classmates are together as long as a seat is available . Only use this when you are tight on seats to spare
NOTE : As earlier the program tries its best to allocate students with different subjects together and if not possible triggers logic 2 allocating students with different classes together ( ignoring subjects ) . Logic 3 ( dont care ) only triggers if logic 2 is triggered


The program will generate an intermediary db that can be queried to get any detailed information regarding the allocation ( though the CLI shows a basic report on how the allocation went and the arguments it was passed )

The pdfs will be generated in the same directory as the report_generator file



### Drawing Hall Layout
<img src="https://user-images.githubusercontent.com/62943847/208338088-c07cbad2-cfde-4177-a800-2cfa30ba3d87.jpg" width="400">

# Archive
A bunch of previous dev logs / development process <br>
https://youtu.be/5hF7kAOf8Hg <br>
https://youtu.be/rd7YkNYW1LA <br>
https://youtu.be/FkvNkvsTHTw <br>
https://youtu.be/hHiUC9pe138 <br>
