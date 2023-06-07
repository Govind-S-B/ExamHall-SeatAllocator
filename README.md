# ExamHall-SeatAllocator
A GUI application built in Flutter, Rust, and Python that automates the assignment of student seats in examinations and generates appropriate PDFs

# Requirements
Windows 10 and above  
MSVC++ Redist. ( packaged with installer )

# Algorithm
the seat assignment algorithm has 3 modes
1. seperate students by subject
   - students are seperated by subjects
   - first priority is given to subjects that have already placed students (if they're not empty) 
   - second priority is given to the subject with the greatest number of students
   - if there is only one subject left, seats are left intentionally empty between students
   - if there are no extra seats left to leave intentionnally empty, start seperating student by class instead
2. seperate students by class
   - first priority is given to classes that have already placed students (if they're not empty) 
   - second priority is given to the classes with the greatest number of students
   - if there is only one class left, the remaining students are assigned seats in roll no. order
### additional notes
* lower roll numbers are always given higher priority
* halls are assigned students from highest seating capacity to lowest

# Contribution Guide
- always add an issue before implementing new features or bug fixes that do not already have Issues

# Issue Format

## Template for Feature Request

- Describe the problem or issue the feature resolves
- Mention and describe the feature
- Mention the merit of implementing the feature and the improvements it offers
- (Optional) Suggest a solution and ideas for implementation

## Template for Bug Report

- Mention The Bug
- What the expected behavior was
- Steps to Reproduce
- (Optional) your attempts to fix the bug (and why they didn’t work)
