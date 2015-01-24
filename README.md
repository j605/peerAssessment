# Getting and Cleaning Data
## Peer Assessment

The script first checks if it can find the data directory and stops otherwise.
Then we read all the data into `data.table` objects. `grepl` is used to filter
column names that contain `mean` and `std` data. Mutate is used to add columns
 to the data table and `rbindlist` is used to merge both training and testing 
data. Then I used piping to group data by subject and activity and use `summary
_each` to to get mean for every variable. Finally, I wrote the result into a
text file. 
