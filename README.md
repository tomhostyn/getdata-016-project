getdata-016-project
===================

Course project for Coursera getdata-016


# run_analysis.R


This file transforms the Human Activity Recognition Using Smartphones data package into a tidy data set.
The original data set has thousand+ observations of various smartphone sensors of humans performing activities such as walking, sitting, laying,..

The resulting tidy data set contains the mean of all observations for the same subject performing the same action.

The resulting  file is a [180x68] data frame.  
There are 180 rows, one row for the observations of each of the  30 subjects * 6 activities
There are 68 columns.  2 Categorical variables (Subject, Activity), and 66 observations.
Please note that  measurements based on  meanFreq were dropped.  E.g. the table contains observations for fBodyAccMag-mean() and fBodyAccMag-std(), but not for fBodyAccMag-meanFreq()

More information about the original project here:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Here are the data for the project: 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# operation

1. Download & unzip the dataset 
2. Set the R working directory to the directory where you unzipped the package.
3. Run run_analysis()
4. the dataset is transformed in a tidy data set and saved in mean_uci_har.txt

# Functions
## run_analysis 

Loads the various files of the unzipped package in the current directory, transforms it into a tidy package, writes the resulting data table to mean_uci_har.txt

## load_har_data_table

given a directory with the unzipped original files, returns a data.table containing a tidy version of the original observations.

1. Defines paths in the unzipped package
2. For both train and test datasets:  loads the observations,  assign clear column names based on the original observation names.  loads the subject ID, and activity ID 
3. Drop all columns that are not -mean() or -std()
4. Bind observation columns with Subject and ActivityID columns for both test and train sets
5. combine test and train sets to a single table.
6. replace the ActivityID with the activity name
7. process the column names to remove awkward characters such as () and -

## transform_har_data_table

Takes a tidy data set as created by load_har_data_table
Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

1. clone the data set
2. for all observation columns, add a new column that contains the mean of each variable for each activity and each subject
3. drop all original observation columns, drop all duplicate rows, sort by Subject and Activity
