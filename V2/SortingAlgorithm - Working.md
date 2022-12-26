# Sorting Algorithm - Working
> before looking at the code I suggest that you run the report generator with a few test cases and test out all the functionalities that if offers .  
>  You can look at a description about all the functionalities offered in the main ReadMe file

The description here is for commit [`ea10e998709dc8880b70b08e5cfb0629b57db68c` ](https://github.com/Govind-S-B/ExamHall-SeatAllocator/tree/ea10e998709dc8880b70b08e5cfb0629b57db68c)

the sorting algorithm is till line `658` , after which it is actually the pdf generation part handled mainly by siby . while sorting algorithm is by me ( govind )

## Code Explanation

#### Argument Input
line 10 to 35 is just an input statement to set the initial values for a few arguments that will be used by a few functionality in the sorting algo .
- the seed_value determines the random number seed used to shuffle lists ( to provide randomising functionality )
- threshold_value is the point after which logic 1 switches to logic 2 ( more detailed description given in the ReadMe )
- dont_care handles when the program switches to logic 3 ( the logic where it doesnt care for constraints and just allocates if a seat is free )
- I used args and args list for a dumb reason . I wanted args to be displayed as a text while args_list is the actual variable containing args . So one case where this gets messy is when i enter args list as empty the args that needs to be printed out become `0 80 0` ( the default values )

The program uses args_list to also keep the program looping ( check line `56`

args_list and args can again be seen found being used in the status report printing section from line `1377` to `1425`

This section prints out how the allocation went and takes in args for the next generation ( if the user wants to try a different generation for the same dataset with a different set of arguments or to use split functionality)

#### Loading JSON Files
line `40-52` loads the json files and loads them into appropriate dictionaries . 
line `52` removes the meta info from the subject dictionary and puts it in a variable on its own ( cause its only needed by the pdf generator , not the sorting algo )

prev_halls_allocated_count in line `54` is a variable used to keep track of how many halls were allocated in the previous generation ( since this is the first time the program is being executed its 0 ) . This variable comes to use for tracking number of halls used in the split functionality

line `56` is from which the main loop body of the program starts

#### Initializing lists / database for allocation
lines `58-136` is all setting up a bunch of stuff for the allocation to begin

first a seed value is set for the random function to work with seed_value . This affects the behavior of the shuffle() function used later in the code to shuffle lists randomly

`60-63` a bunch a variable to count stuff

`65-74` make a subjects list which is contains a list of [no of students in the subject , subject name , the roll numbers ... ] , which is sorted by the number of students in the subject

If the seed is not 0 ( 0 is the default value ) , then the sorted list gets shuffled with the seed set earlier
( PS : Now that i think about it , if im shuffling why am i bothering with sorting in the first place ) 

lines `80-84` again a bunch of variables initialised , these variables are used to handle the logic swaps . the variable `logic` handles which sorting logic is being used now ( ie , standard allocation(logic - 1) or sorting where same classed do not sit together (logic -2 ) or dont care ( logic - 3)

`86-135` sets up the database for storing data . after each student is allocated to a seat that data is stored in the db . Its from this final db where the pdf generator takes data

line `92-126` within it is quite peculiar , its used for the split functionality ( which expects there to be a previously generated database to be there ) . 
What it essentially does is that it makes a list of hall names that needs to be split students equally in between
`check_for_split_halls_list` contains those hall names ( last n halls which were allocated )
`split_mean_capacity` contains the number of students that should be limited by for halls which belong to the list above

> I would recommend that you view the db file after a few test generation using the "SQLite Viewer" extension in vscode or something to see how the data is processed and stored before the pdf generation starts

line `138-407` is the logic to handle sorting when a hall is of type drawing hall
`409-655` is the logic to handle halls of type benches

A lot of code is going to seem copy paste from this point on

#### Drawing Hall Logic
`140-144` the subjects ( which are sorted ) are split into even_subjects and odd_subjects 

`146-152` a list of halls ( Drawing halls) sorted  by their capacities . the list is of the format
[Hall capacity , Hall name , Hall column size]

*NOTE* : First the drawing halls are all allocated before the benches are allocated 

Halls_sorted_list is a variable where i add sorted halls ( line `154` and `407` ) . I think its not used now , it was there for debugging in initial version 

##### For each hall loop
line 156 , for each hall in list of drawing halls

Hall name , capacity , columns , for it are  stored in appropriate variables 
`halls_allocated_count` keeps track of how many halls have been allocated yet . 
`current_hall_allocated_count` keeps track of how many students have been allocated in the current hall ( this is used for split functionality later with `split_mean_capacity` to limit the number of students in a class )

lines `168-187` is used to make a hall structure using lists and give seat number to each seat
## the read me is abandoned now since arjun is working on the refactoring ( and its going well )
