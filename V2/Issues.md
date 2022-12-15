Issues

#1 | PDF Generation | Bug | Quality of Life | Low

Sort the halls list (notice board) by roll numbers if possible


#2 | Dont Care Functionality | Feature Request | High

manually enable (hard coded) when logic 2 fails . Allocate seats disregarding if same class students are sitting together
when dont care is set to true


#3 | Better randomiser | Improvement | Medium

Currently only class distribution is randomised by seed , add one more seed parameter that changes distribution of students within each class , ie: roll numbers of same class / subject get shuffled 

Also modify the input function so that it can take two parameters 0 0 , 0 1 , 1 1 , etc for the seed number ( first is the class distribution randomiser , second is the roll number distribution randomiser)


#4 | Seat split Functionality | Improvement | Low

to fill classes equally instead of best optimisation , so that there are no cases where 3 students alone are in a class , instead have the distribution be more equal ( this might require some from of running the loop again or adding a parameter while generating pdf)

Split seats equally among halls even if it takes up an extra hall . no need to fill halls completely in this case


#5 | Better Input Parameters for Report Generator | Improvement | Medium 

Input Parameters : Seed 1 | Seed 2 | Threshold Value | Dont Care ( Boolean)
eg : 7 0 80 1 ( seed 1 : 7 , seed 2 : 0 {standard generation} , Threshold value to trigger logic 2 , Dont Care boolean if seat insufficinent )

Need default values for these parameters so that , i can just skip entering the parameters and defauts are used 
0 0 80 0

Optionally this can be later expanded to included the ( Seat split functionality to specify something like how many halls need to be redistributed or something) [currenty out of scope]

enter done in input parameter to exit generation loop and exit program 


#6 | More Detailed Status Reports after each generation | Low

Allocation : Sucessful
Input params  : 0 0 80 0
Allocated students : 256
Left to allocate : 0
Halls used : 7

#7 | Data Collection form sample | Quality of life | Medium

Make a sample data collecition form on paper to show swapna miss how data can be collected or formatted so that pdf generation is easier

Also sketch a sample layout for how drawing halls are allocated on paper , so as to give an idea about allocation process

