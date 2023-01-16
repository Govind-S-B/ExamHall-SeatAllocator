# ExamHall-SeatAllocator | EHSA
Seat Allocating script for college internal exams

### Data Collection Format and Seat Numbering
<img src="https://user-images.githubusercontent.com/62943847/212641221-4e9b5139-1cad-45f6-bf15-c09501cd879b.jpg" width="500">  
Collecting data in this format will make it easier for data entry  

The seat numbering goes from left to right for each row of seats ( NOT top to bottom )
  
## How to use  
  
Launch the EHSA script ([windows](https://github.com/Govind-S-B/ExamHall-SeatAllocator/blob/main/FINAL_BUILD/windows_build/EHSA.exe) , [linux](https://github.com/Govind-S-B/ExamHall-SeatAllocator/blob/dev/FINAL_BUILD/linux_build/EHSA)) and choose the appopriate generator utility

  
### Json Generator  
Use json generator utlity from EHSA script to create a json file containing your data  
Sample data can be found [here](https://github.com/Govind-S-B/ExamHall-SeatAllocator/tree/main/FINAL_BUILD/Backups)  
  
To use Json Generator just launch the script
  
#### 1. Select the mode  
- text mode shows output on screen ( this is for testing / botching purposes : copy pasting data into json)  
- json mode writes the data on file ( this is the required file for processing )  
#### 2. Select the data you are going to input ( halls or subjects/classes list )  
  
#### 3. In Halls mode
enter the Hall name and the seating capacity 
  
press done to exit the data entry loop  
  
#### 4. In Subjects mode 
First enter the session name. eg: `12-12-2012 AN`  
  
Next enter the subjects list ( ie , name of all the subjects for which exams are beind conducted that session )  
  
![image](https://user-images.githubusercontent.com/62943847/208369199-5fb92125-1e5e-4f8e-8144-2f64d7e071d9.png)  
  
Next to enter each class and their subjects , roll number list  
  
Enter the Class Name  
**NOTE** : If a class has multiple subjects ( electives / minor ) enter the number of subjects along with the class name eg : `S3R1 2` ( this indicates that S3R2 has two subjects , by default this is treated as 1 and need not be entered along with the name eg:`S3R1`
  
Choose the subject from the list of subjects entered earlier  
  
Enter the roll number list  
**NOTE** : This can be done as comma seperated distinct values and ranges ( inclusive of both ends )  
  
example :  
  
![image](https://user-images.githubusercontent.com/62943847/208370110-4ca6514b-e4a5-42cb-b21c-b7bbe365dece.png)  
  
press done to exit the data entry loop  
  
#### Advantages + A few Quirks of using JSON  
  
- Human readable and therefore easy to edit the data even after entry using a simple text editor ( eg : changing subject names , combining different subjects into one , adding or removing halls / students )
- With text mode in json generator , new data can be generated and copy pasted into the json file , in a sense botching together for edit functionality  
  
### Report Generator  

Run report generator utility from EHSA script to create your pdf ( Make sure you have the Halls.json and Subjects.json file in the same directory as the script )  
The program will generate an intermediary db that can be queried to get any detailed information regarding the allocation  
The pdfs will be generated in the same directory as the EHSA scirpt  

The script allocates students with maximum packaging efficiency while also distributing the students equally through out the minimum number of halls required so as to not have any disprportionately less number of students in one class

The script by default uses the constaint of same subjects not sitting together and only moves to allocating based on class constaint ( same classes not sitting together but same subjects can ) only if there is no halls available to allocate and if even that doesnt work it moves to a dont care logic where students are made to fit in the class somehow

If the default allocation is unsatisfactory you can try constaining the halls availabe for the script by editing out the json file
