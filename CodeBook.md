CodeBook
========

Dataset information
-------------------

-   Dataset full name is "Human Activity Recognition Using Smartphones Dataset".
-   The dataset folder is named "UCI HAR Dataset" and is located in the root of the repository.
-   Information about the dataset can be found at;
    -   [<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).
-   The dataset can be downloaded at;
    -   [<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).

Assumptions
-----------

-   Variable count and ordering is the same between the "X\_test.txt" and "X\_train.txt" files.
-   Each line in the data files is one observation.
-   There should be the same number of observations in each of the 3 data files for the "test" and "train" datasets.
-   The "Inertial Signals" folder within the "test" and "train" folders can be ignored.
-   We will match the lowercase converted variable names for the strings "mean" and "std" for the purpose of identifying the mean and standard deviation columns we are interested in keeping.

Checks
------

-   Once the "test" and "train" datasets have been joined, there should be exactly 10,299 observations.
-   The "test" dataset should have 9 unique subjects.
-   The "train" dataset should have 21 unique subjects.
-   The joined dataset of 10,299 observations should have 30 unique subjects.

Detailed functional description of the scripts
----------------------------------------------

Scripts summary
---------------

| Script          | Summary                                                                                                                                                                                                                                                                                                          |
|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| run\_analysis.R | This is the main entry point script. It makes calls to the prepare and tidy scripts. Can be called with arguments to return the tidy data, write the tidy data to a textfile, re-prepare the data, or re-tidy the data. This script is responsible for creating the local files of the prepared and tidied data. |
| prepare\_data.R | Takes an argument value of "test" or "train" to indicate which dataset is to be prepared and returned.                                                                                                                                                                                                           |
| tidy\_data.R    | Takes an argument value of the prepared data, tidies it, then summarises it for return.                                                                                                                                                                                                                          |

### run\_analysis.R

-   When calling the run\_analysis function four parameters can be supplied, all of which are logical and default to FALSE.
    -   return\_tidy\_data\_frame is a flag to indicate if a data frame of the tidy data should be returned to the function caller.
    -   write\_tidy\_txt is a flag to indicate if the tidy data should be output to a tidy\_data.txt textfile.
    -   re\_prepare is a flag to indicate if the raw data needs to be re-prepared and the prepare\_data.csv file rebuilt.
    -   re\_tidy is a flag to indicate if the prepared data needs to be re-tidied and the tidy\_data.csv file rebuilt.

``` r
run_analysis <- function(return_tidy_data_frame = FALSE, 
                         write_tidy_txt = FALSE, 
                         re_prepare = FALSE, 
                         re_tidy = FALSE)
```

-   Load the libraries we'll be using.

``` r
# Load libraries.
library(dplyr, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
library(tidyr, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
```

-   Source the prepare and tidy scripts.

``` r
# Source scripts.
source("prepare_data.R")
source("tidy_data.R")
```

-   Setup filename variables.

``` r
# Setup the filenames.
filename_prepared_data <- "prepared_data.csv"
filename_tidy_data <- "tidy_data.csv" 
```

-   Check if the prepared and tidy data files exist already. If they do not exist, or if they need to be rebuilt then set the flag and output a message. If we are re-preparing the data then we should also re-tidy the newly prepared data.

``` r
# Check if the prepared data file exists.
if(file.exists(filename_prepared_data) == FALSE | re_prepare == TRUE) {
    re_prepare = TRUE
    message("Info: File prepared_data.csv will be rebuilt.")
}

# Check if the tidy data file exists.
if(file.exists(filename_tidy_data) == FALSE | re_tidy == TRUE) {
    re_tidy = TRUE
    message("Info: File tidy_data.csv will be rebuilt.")
}

# If we are re-preparing, then we should also re-tidy with the newly 
# prepared data
if(re_prepare == TRUE & re_tidy == FALSE) {
    re_tidy = TRUE
    message("Info: File tidy_data.csv will therefore also be rebuilt.")
}
```

-   Preparing (and re-preparing) the data.
    -   Make two calls to the prepare\_data function, passing "test" then "train".
    -   Row bind the results.
    -   Perform checks on the prepared data.
    -   Write the prepared data out to file "prepared\_data.CSV".
    -   Print completion message.

``` r
if(re_prepare) {
    # Prepare and load the data.
    test_data <- prepare_data("test")
    train_data <- prepare_data("train")
    
    # Join the datasets.
    prepared_data <- bind_rows(test_data, train_data)
    
    # Check there are 10,299 observations.
    if(nrow(prepared_data) != 10299) {
        stop("Observations count is not 10,299.")
    }
    
    # Write a CSV with the prepared data, ready for further processing.
    write.csv(prepared_data, file.path(filename_prepared_data), 
              row.names = FALSE)
    
    message("Info: File prepared_data.csv has been rebuilt.")
}
```

-   Tidying (and re-tidying) the data.
    -   Call the tidy\_data function, passing the prepared data read from CSV.
    -   Write the tidied data out to file "tidy\_data.CSV".
    -   Print completion message.

``` r
if(re_tidy) {
    # Read and tidy the prepared data.
    tidy_df <- tidy_data(tbl_df(read.csv(filename_prepared_data)))
    
    # Write a CSV with the tidy data.
    write.csv(tidy_df, file.path(filename_tidy_data), row.names = FALSE)
    
    message("Info: File tidy_data.csv has been rebuilt.")
}
```

-   Check if any processing was done and print messages if not.

``` r
if(re_prepare == FALSE & re_tidy == FALSE) {
    message("Warning: No processing was performed.")
    message("Info: prepared_data.csv and tidy_data.csv already exist.")
    message("Info: Set parameter re_prepare = TRUE to re-prepare data.")
    message("Info: Set parameter re_tidy = TRUE to re-tidy data.")
}
```

-   Read the tidy data from CSV, then output again as TXT if required.

``` r
# Read the tidy date from file.
tidy_data <- read.csv(filename_tidy_data)

# Output to textfile if required.
if(write_tidy_txt) {
    write.table(tidy_data, "tidy_data.txt", row.names = FALSE)
    message("Info: File tidy_data.txt has been created.")
}
```

-   If return\_tidy\_data\_frame is TRUE, then return the tidy data as a data frame to the function caller.

``` r
if(return_tidy_data_frame) {
    return(tidy_data)
}
```

### prepare\_data.R

-   When calling the prepare\_data function a single parameter must be supplied with a value of either "test" or "train", to indicate the dataset to work with.

``` r
# Input parameter should be either "train" or "test".
prepare_data <- function(dataset)
```

-   Validate the dataset parameter value.

``` r
# Validate the dataset to be worked with.
if(dataset %in% c("test", "train") == FALSE) {
    stop("Parameter \"dataset\" must be either \"test\" or \"train\".")
}
```

-   Setup variables.

``` r
# Variable setup.
dataset_folder <- "UCI HAR Dataset"
subject_values <- NULL
activity_values <- NULL
main_data <- NULL
```

-   Read the relevant files based on the value of the "dataset" parameter. Whichever case, the data is loaded into the same variables for further processing.

``` r
    # Read the relevant files.
    if(dataset == "test") {
        # dataset is "test".
        subject_values <- tbl_df(read.table(file.path(dataset_folder, 
                                                      "test", 
                                                      "subject_test.txt")))
        activity_values <- tbl_df(read.table(file.path(dataset_folder, 
                                                       "test", 
                                                       "y_test.txt")))
        main_data <- tbl_df(read.table(file.path(dataset_folder, 
                                                 "test", 
                                                 "X_test.txt")))
    } else {
        # dataset is "train".
        subject_values <- tbl_df(read.table(file.path(dataset_folder, 
                                                      "train", 
                                                      "subject_train.txt")))
        activity_values <- tbl_df(read.table(file.path(dataset_folder, 
                                                       "train", 
                                                       "y_train.txt")))
        main_data <- tbl_df(read.table(file.path(dataset_folder, 
                                                 "train", 
                                                 "X_train.txt")))
    }
```

-   Perform checks on the loaded data.

``` r
# Check for the correct number of unique subject values.
if(dataset == "test") {
    # dataset is "test".
    if(subject_values %>% distinct() %>% count() != 9) {
        stop("The count of unique subjects is not the expected value of 9.")
    }
} else {
    # dataset is "train".
    if(subject_values %>% distinct() %>% count() != 21) {
        stop("The count of unique subjects is not the expected value of 21."
             )
    }
}

# Check that loaded datasets all have the same number of observations.
if(!identical(nrow(subject_values), nrow(activity_values), 
             nrow(main_data))) {
    stop("Datasets have different count of observations.")
}
```

-   Set column names.

``` r
# Set column names for the subject and activity values datasets.
colnames(subject_values) <- "subject"
colnames(activity_values) <- "activity_id"
```

-   Validate that the activity values are as expected. Then load the activity labels and set column names.

``` r
# Check that the unique activity values are within the range 1 to 6.
if(!all(distinct(activity_values)$activity_id %in% c(1,2,3,4,5,6))) {
    stop("The activity values are not within the range of 1 to 6.")
}

# Load the activity labels.
activity_labels <- tbl_df(read.table(file.path(dataset_folder,
                                               "activity_labels.txt")))

# Set column names for the activity labels dataset.
colnames(activity_labels) <- c("activity_id", "activity")
```

-   Join the activity values and their labels, then select only the labels and convert the column class.

``` r
# Join the activity values and labels datasets, then select only labels.
activity_values <- 
    activity_values %>% 
    left_join(activity_labels, by = "activity_id") %>%
    select(activity)

# Convert the activity column to a character vector.
activity_values$activity <- as.character(activity_values$activity)
```

-   Bind the columns of the subject and activity datasets. The resulting dataset will be joined to the main data later on.

``` r
# Join the subject and activity datasets.
subjects_and_activities <- bind_cols(subject_values, activity_values)
```

-   Load the variable labels and set column names.

``` r
# Load the variable labels.
variable_labels <- tbl_df(read.table(file.path(dataset_folder, 
                                               "features.txt")))

# Set variables dataset column names.
colnames(variable_labels) <- c("variable_id", "variable")
```

-   Check that the number of variable labels matches the number of columns in the main data.

``` r
# Check the number of variable labels (columns).
if(!identical(nrow(variable_labels), ncol(main_data))) {
    stop("Variable count mismatch between labels and data.")       
}
```

-   Convert the variable labels to a character vector. The raw variable labels contain invalid characters which can cause problems, so we use the make.names() function to convert the variable labels to valid names and store in a new variable, which we use to set the column names of the main data.

``` r
# Convert variable labels to character vector.
variable_labels <- as.character(variable_labels$variable)

valid_variable_labels <- make.names(variable_labels, unique = TRUE, 
                                    allow_ = TRUE)

# Set column main data column names.
colnames(main_data) <- valid_variable_labels
```

-   We match the lowercase converted variable names for the strings "mean" and "std" for the purpose of identifying the mean and standard deviation columns we are interested in keeping. We create a logical vector so we know the positions of the variables we want to keep.

``` r
# Convert all the variable names to lowercase for matching.
valid_variable_labels <- tolower(valid_variable_labels)

# Get a list of the variables we need to work with, based on matching the
# list for "mean" and "std".
selected_variables <- as.logical(
    grepl("mean", valid_variable_labels, fixed = TRUE) + 
        grepl("std", valid_variable_labels, fixed = TRUE))
```

-   Create an integer vector of all the main data variable positions. Loop through the variable\_positions vector and check if the same position is TRUE in our selected\_variables logical vector. If TRUE, store the position value in a vector to be used to select only the required variables by position into our main\_data dataset.

``` r
# Create a vector of the column positions in the main data.
variable_positions <- as.integer(1:length(selected_variables))

# Create a vector with the column positions we need to select.
selected_positions <- NULL
for(i in variable_positions) {
    if(selected_variables[i] == TRUE) {
        selected_positions <- c(selected_positions, i)
    }
}

# Select only the required columns.
main_data <- select(main_data, selected_positions)
```

-   Now the main\_data dataset has only the necessary columns, we can join it with the subjects\_and\_activities dataset.

``` r
# Join the subject and activity dataset with the main dataset.
main_data <- bind_cols(subjects_and_activities, main_data)
```

-   The data is now prepared and can be returned to the caller.

``` r
# Return the dataset.
return(main_data)
```

### tidy\_data.R

-   When calling the tidy\_data function we must supply the prepared data as a parameter.

``` r
# The prepared dataset must be supplied as a parameter.
tidy_data <- function(dataset) {
```

-   Except for the "subject" and "activity" variables, the variable names need to be tidied up. Create character vectors to hold the old and new variable names.

``` r
# Get the dataset column names.
oldcols <- as.character(colnames(dataset))
newcols <- new("character")
```

-   The first letter of the measurement variable names is either "t" or "f", to indicate a time of frequency measurement. Loop through the variable names and where the first letter is "t" replace it with "time\_", where it is "f" replace it with "freq\_". We will use the "\_" character as a convention to split our variable names in a more tidy way that will make the variables easier to read. Doing the replacement for "time" and "freq" also makes the variables easier to understand.

``` r
# Loops through the column names and replace for time and freq.
for(i in 1:length(oldcols)) {
    # Get the first character of the variable name.
    firstchar <- substr(oldcols[i], 1, 1)
    # Match for time or freq and then replace.
    if(firstchar %in% c("t", "f")) {
        replacement <- NULL
        if(firstchar == "t") {
            # time.
            replacement <- "time_"
        } else {
            # freq.
            replacement <- "freq_"
        }
        newcols[i] <- paste(replacement, substr(oldcols[i], 2, nchar(oldcols[i])), sep = "")
    } else {
        newcols[i] <- oldcols[i]
    }
}
```

-   Tidy up the measurement variables and then set the names.
    -   We follow a convention of using an "\_" to separate out parts of the variable name.
    -   Transform the parts of the name relating to the mean and standard deviation.
    -   Tidy up the name of the angle variables.
    -   Tidy up the gravity part of the variables.
    -   Tidy up the X, Y, Z part of the variables.
    -   Tidy up trailing characters.

``` r
# Tidy the variable name strings.
newcols <- gsub(".mean.", "_mean_", newcols, fixed = TRUE)
newcols <- gsub(".meanFreq.", "_meanFreq_", newcols, fixed = TRUE)
newcols <- gsub(".std.", "_std_", newcols, fixed = TRUE)
newcols <- gsub(".X.gravityMean.", "_gravityMean_x", newcols, fixed = TRUE)
newcols <- gsub(".Y.gravityMean.", "_gravityMean_y", newcols, fixed = TRUE)
newcols <- gsub(".Z.gravityMean.", "_gravityMean_z", newcols, fixed = TRUE)
newcols <- gsub("angle.", "angle_", newcols, fixed = TRUE)
newcols <- gsub(".gravity", "_gravity", newcols, fixed = TRUE)    
newcols <- gsub("..X", "x", newcols, fixed = TRUE)
newcols <- gsub("..Y", "y", newcols, fixed = TRUE)
newcols <- gsub("..Z", "z", newcols, fixed = TRUE)
newcols <- gsub("_.", "", newcols, fixed = TRUE)
newcols <- gsub(".", "", newcols, fixed = TRUE)

# Set the dataset column names.
colnames(dataset) <- newcols
```

-   Use a convention of lowercase for the activity values.

``` r
# Tidy up the activity values.
dataset$activity <- as.character(dataset$activity)
dataset$activity[dataset$activity == "STANDING"] <- "standing"
dataset$activity[dataset$activity == "SITTING"] <- "sitting"
dataset$activity[dataset$activity == "LAYING"] <- "laying"
dataset$activity[dataset$activity == "WALKING"] <- "walking"
dataset$activity[dataset$activity == "WALKING_DOWNSTAIRS"] <- 
    "walking_downstairs"
dataset$activity[dataset$activity == "WALKING_UPSTAIRS"] <- 
    "walking_upstairs"
```

-   Arrange our data by subject and then activity.

``` r
dataset %>% 
# Arrange by subject then activity.
arrange(subject, activity) %>%
```

-   Group our data by subject and then activity, ready for it to be summarised.

``` r
# Setup groupings.
group_by(subject, activity) %>%
```

-   Use the summarise\_each() function to get the mean for each variable, summarising by our groups.

``` r
# Within the groups get the mean for each variable.
summarise_each(funs(mean)) %>%
```

-   Finally we return our data to the caller.

``` r
# Return tidied dataset.
return()
```

Usage
-----

The following call to the **run\_analysis** function will re-prepare and re-tidy the data before writing it as a textfile and then returning it.

``` r
source("run_analysis.R")
run_analysis(TRUE, TRUE, TRUE, TRUE)
```

Output
------

-   Data frame with 180 observations and 88 variables.
-   The output data is grouped by subject then activity.
-   The value provided for the numeric measurements columns 3:88 is the mean value for the measurement, grouped by activity and then subject.

### Example outputs

``` r
source("run_analysis.R")
str(run_analysis(TRUE, TRUE, FALSE, FALSE))
```

    ## Warning: No processing was performed.
    ## Info: prepared_data.csv and tidy_data.csv already exist.
    ## Info: Set parameter re_prepare = TRUE to re-prepare data.
    ## Info: Set parameter re_tidy = TRUE to re-tidy data.
    ## Info: File tidy_data.txt has been created.

    ## 'data.frame':    180 obs. of  88 variables:
    ##  $ subject                            : int  1 1 1 1 1 1 2 2 2 2 ...
    ##  $ activity                           : Factor w/ 6 levels "laying","sitting",..: 1 2 3 4 5 6 1 2 3 4 ...
    ##  $ time_BodyAcc_mean_x                : num  0.222 0.261 0.279 0.277 0.289 ...
    ##  $ time_BodyAcc_mean_y                : num  -0.04051 -0.00131 -0.01614 -0.01738 -0.00992 ...
    ##  $ time_BodyAcc_mean_z                : num  -0.113 -0.105 -0.111 -0.111 -0.108 ...
    ##  $ time_BodyAcc_std_x                 : num  -0.928 -0.977 -0.996 -0.284 0.03 ...
    ##  $ time_BodyAcc_std_y                 : num  -0.8368 -0.9226 -0.9732 0.1145 -0.0319 ...
    ##  $ time_BodyAcc_std_z                 : num  -0.826 -0.94 -0.98 -0.26 -0.23 ...
    ##  $ time_GravityAcc_mean_x             : num  -0.249 0.832 0.943 0.935 0.932 ...
    ##  $ time_GravityAcc_mean_y             : num  0.706 0.204 -0.273 -0.282 -0.267 ...
    ##  $ time_GravityAcc_mean_z             : num  0.4458 0.332 0.0135 -0.0681 -0.0621 ...
    ##  $ time_GravityAcc_std_x              : num  -0.897 -0.968 -0.994 -0.977 -0.951 ...
    ##  $ time_GravityAcc_std_y              : num  -0.908 -0.936 -0.981 -0.971 -0.937 ...
    ##  $ time_GravityAcc_std_z              : num  -0.852 -0.949 -0.976 -0.948 -0.896 ...
    ##  $ time_BodyAccJerk_mean_x            : num  0.0811 0.0775 0.0754 0.074 0.0542 ...
    ##  $ time_BodyAccJerk_mean_y            : num  0.003838 -0.000619 0.007976 0.028272 0.02965 ...
    ##  $ time_BodyAccJerk_mean_z            : num  0.01083 -0.00337 -0.00369 -0.00417 -0.01097 ...
    ##  $ time_BodyAccJerk_std_x             : num  -0.9585 -0.9864 -0.9946 -0.1136 -0.0123 ...
    ##  $ time_BodyAccJerk_std_y             : num  -0.924 -0.981 -0.986 0.067 -0.102 ...
    ##  $ time_BodyAccJerk_std_z             : num  -0.955 -0.988 -0.992 -0.503 -0.346 ...
    ##  $ time_BodyGyro_mean_x               : num  -0.0166 -0.0454 -0.024 -0.0418 -0.0351 ...
    ##  $ time_BodyGyro_mean_y               : num  -0.0645 -0.0919 -0.0594 -0.0695 -0.0909 ...
    ##  $ time_BodyGyro_mean_z               : num  0.1487 0.0629 0.0748 0.0849 0.0901 ...
    ##  $ time_BodyGyro_std_x                : num  -0.874 -0.977 -0.987 -0.474 -0.458 ...
    ##  $ time_BodyGyro_std_y                : num  -0.9511 -0.9665 -0.9877 -0.0546 -0.1263 ...
    ##  $ time_BodyGyro_std_z                : num  -0.908 -0.941 -0.981 -0.344 -0.125 ...
    ##  $ time_BodyGyroJerk_mean_x           : num  -0.1073 -0.0937 -0.0996 -0.09 -0.074 ...
    ##  $ time_BodyGyroJerk_mean_y           : num  -0.0415 -0.0402 -0.0441 -0.0398 -0.044 ...
    ##  $ time_BodyGyroJerk_mean_z           : num  -0.0741 -0.0467 -0.049 -0.0461 -0.027 ...
    ##  $ time_BodyGyroJerk_std_x            : num  -0.919 -0.992 -0.993 -0.207 -0.487 ...
    ##  $ time_BodyGyroJerk_std_y            : num  -0.968 -0.99 -0.995 -0.304 -0.239 ...
    ##  $ time_BodyGyroJerk_std_z            : num  -0.958 -0.988 -0.992 -0.404 -0.269 ...
    ##  $ time_BodyAccMag_mean               : num  -0.8419 -0.9485 -0.9843 -0.137 0.0272 ...
    ##  $ time_BodyAccMag_std                : num  -0.7951 -0.9271 -0.9819 -0.2197 0.0199 ...
    ##  $ time_GravityAccMag_mean            : num  -0.8419 -0.9485 -0.9843 -0.137 0.0272 ...
    ##  $ time_GravityAccMag_std             : num  -0.7951 -0.9271 -0.9819 -0.2197 0.0199 ...
    ##  $ time_BodyAccJerkMag_mean           : num  -0.9544 -0.9874 -0.9924 -0.1414 -0.0894 ...
    ##  $ time_BodyAccJerkMag_std            : num  -0.9282 -0.9841 -0.9931 -0.0745 -0.0258 ...
    ##  $ time_BodyGyroMag_mean              : num  -0.8748 -0.9309 -0.9765 -0.161 -0.0757 ...
    ##  $ time_BodyGyroMag_std               : num  -0.819 -0.935 -0.979 -0.187 -0.226 ...
    ##  $ time_BodyGyroJerkMag_mean          : num  -0.963 -0.992 -0.995 -0.299 -0.295 ...
    ##  $ time_BodyGyroJerkMag_std           : num  -0.936 -0.988 -0.995 -0.325 -0.307 ...
    ##  $ freq_BodyAcc_mean_x                : num  -0.9391 -0.9796 -0.9952 -0.2028 0.0382 ...
    ##  $ freq_BodyAcc_mean_y                : num  -0.86707 -0.94408 -0.97707 0.08971 0.00155 ...
    ##  $ freq_BodyAcc_mean_z                : num  -0.883 -0.959 -0.985 -0.332 -0.226 ...
    ##  $ freq_BodyAcc_std_x                 : num  -0.9244 -0.9764 -0.996 -0.3191 0.0243 ...
    ##  $ freq_BodyAcc_std_y                 : num  -0.834 -0.917 -0.972 0.056 -0.113 ...
    ##  $ freq_BodyAcc_std_z                 : num  -0.813 -0.934 -0.978 -0.28 -0.298 ...
    ##  $ freq_BodyAcc_meanFreq_x            : num  -0.1588 -0.0495 0.0865 -0.2075 -0.3074 ...
    ##  $ freq_BodyAcc_meanFreq_y            : num  0.0975 0.0759 0.1175 0.1131 0.0632 ...
    ##  $ freq_BodyAcc_meanFreq_z            : num  0.0894 0.2388 0.2449 0.0497 0.2943 ...
    ##  $ freq_BodyAccJerk_mean_x            : num  -0.9571 -0.9866 -0.9946 -0.1705 -0.0277 ...
    ##  $ freq_BodyAccJerk_mean_y            : num  -0.9225 -0.9816 -0.9854 -0.0352 -0.1287 ...
    ##  $ freq_BodyAccJerk_mean_z            : num  -0.948 -0.986 -0.991 -0.469 -0.288 ...
    ##  $ freq_BodyAccJerk_std_x             : num  -0.9642 -0.9875 -0.9951 -0.1336 -0.0863 ...
    ##  $ freq_BodyAccJerk_std_y             : num  -0.932 -0.983 -0.987 0.107 -0.135 ...
    ##  $ freq_BodyAccJerk_std_z             : num  -0.961 -0.988 -0.992 -0.535 -0.402 ...
    ##  $ freq_BodyAccJerk_meanFreq_x        : num  0.132 0.257 0.314 -0.209 -0.253 ...
    ##  $ freq_BodyAccJerk_meanFreq_y        : num  0.0245 0.0475 0.0392 -0.3862 -0.3376 ...
    ##  $ freq_BodyAccJerk_meanFreq_z        : num  0.02439 0.09239 0.13858 -0.18553 0.00937 ...
    ##  $ freq_BodyGyro_mean_x               : num  -0.85 -0.976 -0.986 -0.339 -0.352 ...
    ##  $ freq_BodyGyro_mean_y               : num  -0.9522 -0.9758 -0.989 -0.1031 -0.0557 ...
    ##  $ freq_BodyGyro_mean_z               : num  -0.9093 -0.9513 -0.9808 -0.2559 -0.0319 ...
    ##  $ freq_BodyGyro_std_x                : num  -0.882 -0.978 -0.987 -0.517 -0.495 ...
    ##  $ freq_BodyGyro_std_y                : num  -0.9512 -0.9623 -0.9871 -0.0335 -0.1814 ...
    ##  $ freq_BodyGyro_std_z                : num  -0.917 -0.944 -0.982 -0.437 -0.238 ...
    ##  $ freq_BodyGyro_meanFreq_x           : num  -0.00355 0.18915 -0.12029 0.01478 -0.10045 ...
    ##  $ freq_BodyGyro_meanFreq_y           : num  -0.0915 0.0631 -0.0447 -0.0658 0.0826 ...
    ##  $ freq_BodyGyro_meanFreq_z           : num  0.010458 -0.029784 0.100608 0.000773 -0.075676 ...
    ##  $ freq_BodyAccMag_mean               : num  -0.8618 -0.9478 -0.9854 -0.1286 0.0966 ...
    ##  $ freq_BodyAccMag_std                : num  -0.798 -0.928 -0.982 -0.398 -0.187 ...
    ##  $ freq_BodyAccMag_meanFreq           : num  0.0864 0.2367 0.2846 0.1906 0.1192 ...
    ##  $ freq_BodyBodyAccJerkMag_mean       : num  -0.9333 -0.9853 -0.9925 -0.0571 0.0262 ...
    ##  $ freq_BodyBodyAccJerkMag_std        : num  -0.922 -0.982 -0.993 -0.103 -0.104 ...
    ##  $ freq_BodyBodyAccJerkMag_meanFreq   : num  0.2664 0.3519 0.4222 0.0938 0.0765 ...
    ##  $ freq_BodyBodyGyroMag_mean          : num  -0.862 -0.958 -0.985 -0.199 -0.186 ...
    ##  $ freq_BodyBodyGyroMag_std           : num  -0.824 -0.932 -0.978 -0.321 -0.398 ...
    ##  $ freq_BodyBodyGyroMag_meanFreq      : num  -0.139775 -0.000262 -0.028606 0.268844 0.349614 ...
    ##  $ freq_BodyBodyGyroJerkMag_mean      : num  -0.942 -0.99 -0.995 -0.319 -0.282 ...
    ##  $ freq_BodyBodyGyroJerkMag_std       : num  -0.933 -0.987 -0.995 -0.382 -0.392 ...
    ##  $ freq_BodyBodyGyroJerkMag_meanFreq  : num  0.176 0.185 0.334 0.191 0.19 ...
    ##  $ angle_tBodyAccMean_gravity         : num  0.021366 0.027442 -0.000222 0.060454 -0.002695 ...
    ##  $ angle_tBodyAccJerkMean_gravityMean : num  0.00306 0.02971 0.02196 -0.00793 0.08993 ...
    ##  $ angle_tBodyGyroMean_gravityMean    : num  -0.00167 0.0677 -0.03379 0.01306 0.06334 ...
    ##  $ angle_tBodyGyroJerkMean_gravityMean: num  0.0844 -0.0649 -0.0279 -0.0187 -0.04 ...
    ##  $ angle_gravityMean_x                : num  0.427 -0.591 -0.743 -0.729 -0.744 ...
    ##  $ angle_gravityMean_y                : num  -0.5203 -0.0605 0.2702 0.277 0.2672 ...
    ##  $ angle_gravityMean_z                : num  -0.3524 -0.218 0.0123 0.0689 0.065 ...

``` r
tbl_df(run_analysis(TRUE, TRUE, FALSE, FALSE))
```

    ## Warning: No processing was performed.
    ## Info: prepared_data.csv and tidy_data.csv already exist.
    ## Info: Set parameter re_prepare = TRUE to re-prepare data.
    ## Info: Set parameter re_tidy = TRUE to re-tidy data.
    ## Info: File tidy_data.txt has been created.

    ## Source: local data frame [180 x 88]
    ## 
    ##    subject           activity time_BodyAcc_mean_x time_BodyAcc_mean_y
    ##      (int)             (fctr)               (dbl)               (dbl)
    ## 1        1             laying           0.2215982        -0.040513953
    ## 2        1            sitting           0.2612376        -0.001308288
    ## 3        1           standing           0.2789176        -0.016137590
    ## 4        1            walking           0.2773308        -0.017383819
    ## 5        1 walking_downstairs           0.2891883        -0.009918505
    ## 6        1   walking_upstairs           0.2554617        -0.023953149
    ## 7        2             laying           0.2813734        -0.018158740
    ## 8        2            sitting           0.2770874        -0.015687994
    ## 9        2           standing           0.2779115        -0.018420827
    ## 10       2            walking           0.2764266        -0.018594920
    ## ..     ...                ...                 ...                 ...
    ## Variables not shown: time_BodyAcc_mean_z (dbl), time_BodyAcc_std_x (dbl),
    ##   time_BodyAcc_std_y (dbl), time_BodyAcc_std_z (dbl),
    ##   time_GravityAcc_mean_x (dbl), time_GravityAcc_mean_y (dbl),
    ##   time_GravityAcc_mean_z (dbl), time_GravityAcc_std_x (dbl),
    ##   time_GravityAcc_std_y (dbl), time_GravityAcc_std_z (dbl),
    ##   time_BodyAccJerk_mean_x (dbl), time_BodyAccJerk_mean_y (dbl),
    ##   time_BodyAccJerk_mean_z (dbl), time_BodyAccJerk_std_x (dbl),
    ##   time_BodyAccJerk_std_y (dbl), time_BodyAccJerk_std_z (dbl),
    ##   time_BodyGyro_mean_x (dbl), time_BodyGyro_mean_y (dbl),
    ##   time_BodyGyro_mean_z (dbl), time_BodyGyro_std_x (dbl),
    ##   time_BodyGyro_std_y (dbl), time_BodyGyro_std_z (dbl),
    ##   time_BodyGyroJerk_mean_x (dbl), time_BodyGyroJerk_mean_y (dbl),
    ##   time_BodyGyroJerk_mean_z (dbl), time_BodyGyroJerk_std_x (dbl),
    ##   time_BodyGyroJerk_std_y (dbl), time_BodyGyroJerk_std_z (dbl),
    ##   time_BodyAccMag_mean (dbl), time_BodyAccMag_std (dbl),
    ##   time_GravityAccMag_mean (dbl), time_GravityAccMag_std (dbl),
    ##   time_BodyAccJerkMag_mean (dbl), time_BodyAccJerkMag_std (dbl),
    ##   time_BodyGyroMag_mean (dbl), time_BodyGyroMag_std (dbl),
    ##   time_BodyGyroJerkMag_mean (dbl), time_BodyGyroJerkMag_std (dbl),
    ##   freq_BodyAcc_mean_x (dbl), freq_BodyAcc_mean_y (dbl),
    ##   freq_BodyAcc_mean_z (dbl), freq_BodyAcc_std_x (dbl), freq_BodyAcc_std_y
    ##   (dbl), freq_BodyAcc_std_z (dbl), freq_BodyAcc_meanFreq_x (dbl),
    ##   freq_BodyAcc_meanFreq_y (dbl), freq_BodyAcc_meanFreq_z (dbl),
    ##   freq_BodyAccJerk_mean_x (dbl), freq_BodyAccJerk_mean_y (dbl),
    ##   freq_BodyAccJerk_mean_z (dbl), freq_BodyAccJerk_std_x (dbl),
    ##   freq_BodyAccJerk_std_y (dbl), freq_BodyAccJerk_std_z (dbl),
    ##   freq_BodyAccJerk_meanFreq_x (dbl), freq_BodyAccJerk_meanFreq_y (dbl),
    ##   freq_BodyAccJerk_meanFreq_z (dbl), freq_BodyGyro_mean_x (dbl),
    ##   freq_BodyGyro_mean_y (dbl), freq_BodyGyro_mean_z (dbl),
    ##   freq_BodyGyro_std_x (dbl), freq_BodyGyro_std_y (dbl),
    ##   freq_BodyGyro_std_z (dbl), freq_BodyGyro_meanFreq_x (dbl),
    ##   freq_BodyGyro_meanFreq_y (dbl), freq_BodyGyro_meanFreq_z (dbl),
    ##   freq_BodyAccMag_mean (dbl), freq_BodyAccMag_std (dbl),
    ##   freq_BodyAccMag_meanFreq (dbl), freq_BodyBodyAccJerkMag_mean (dbl),
    ##   freq_BodyBodyAccJerkMag_std (dbl), freq_BodyBodyAccJerkMag_meanFreq
    ##   (dbl), freq_BodyBodyGyroMag_mean (dbl), freq_BodyBodyGyroMag_std (dbl),
    ##   freq_BodyBodyGyroMag_meanFreq (dbl), freq_BodyBodyGyroJerkMag_mean
    ##   (dbl), freq_BodyBodyGyroJerkMag_std (dbl),
    ##   freq_BodyBodyGyroJerkMag_meanFreq (dbl), angle_tBodyAccMean_gravity
    ##   (dbl), angle_tBodyAccJerkMean_gravityMean (dbl),
    ##   angle_tBodyGyroMean_gravityMean (dbl),
    ##   angle_tBodyGyroJerkMean_gravityMean (dbl), angle_gravityMean_x (dbl),
    ##   angle_gravityMean_y (dbl), angle_gravityMean_z (dbl)

### Variable information

#### Notes

-   An "\_" character is used to split the variable name for ease of understanding and readability.
-   For columns 3 to 88 (the measurement variables);
    -   Values are normalized and bounded within [-1,1].
    -   The first part of the variable name before the first underscore, indicates if the measurement is for the time ("time") or frequency ("freq") domain, or an angle measurement.
    -   Some variables end with "\_x", "\_y" or "\_z", which indicates the axis of the measurement.
    -   The parts of the variable name after the first underscore and before any axis character, indicate the main identifier of the measurement being taken and the measurement function being performed.
    -   Refer to file README.txt within the "UCI HAR Dataset" folder for more details of the measurements.

#### Summary table

| Variable                              | Class  | Description                                                                                                                           |
|---------------------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------|
| subject                               | int    | The subject identifier from 1 to 30.                                                                                                  |
| activity                              | factor | The activity type from a list of 6 options of "laying", "sitting", "standing", "walking", "walking\_downstairs", "walking\_upstairs". |
| time\_BodyAcc\_mean\_x                | num    | Mean value in the X axis.                                                                                                             |
| time\_BodyAcc\_mean\_y                | num    | Mean value in the Y axis.                                                                                                             |
| time\_BodyAcc\_mean\_z                | num    | Mean value in the Z axis.                                                                                                             |
| time\_BodyAcc\_std\_x                 | num    | Standard deviation value in the X axis.                                                                                               |
| time\_BodyAcc\_std\_y                 | num    | Standard deviation value in the Y axis.                                                                                               |
| time\_BodyAcc\_std\_z                 | num    | Standard deviation value in the Z axis.                                                                                               |
| time\_GravityAcc\_mean\_x             | num    | Mean value in the X axis.                                                                                                             |
| time\_GravityAcc\_mean\_y             | num    | Mean value in the Y axis.                                                                                                             |
| time\_GravityAcc\_mean\_z             | num    | Mean value in the Z axis.                                                                                                             |
| time\_GravityAcc\_std\_x              | num    | Standard deviation value in the X axis.                                                                                               |
| time\_GravityAcc\_std\_y              | num    | Standard deviation value in the Y axis.                                                                                               |
| time\_GravityAcc\_std\_z              | num    | Standard deviation value in the Z axis.                                                                                               |
| time\_BodyAccJerk\_mean\_x            | num    | Mean value in the X axis.                                                                                                             |
| time\_BodyAccJerk\_mean\_y            | num    | Mean value in the Y axis.                                                                                                             |
| time\_BodyAccJerk\_mean\_z            | num    | Mean value in the Z axis.                                                                                                             |
| time\_BodyAccJerk\_std\_x             | num    | Standard deviation value in the X axis.                                                                                               |
| time\_BodyAccJerk\_std\_y             | num    | Standard deviation value in the Y axis.                                                                                               |
| time\_BodyAccJerk\_std\_z             | num    | Standard deviation value in the Z axis.                                                                                               |
| time\_BodyGyro\_mean\_x               | num    | Mean value in the X axis.                                                                                                             |
| time\_BodyGyro\_mean\_y               | num    | Mean value in the Y axis.                                                                                                             |
| time\_BodyGyro\_mean\_z               | num    | Mean value in the Z axis.                                                                                                             |
| time\_BodyGyro\_std\_x                | num    | Standard deviation value in the X axis.                                                                                               |
| time\_BodyGyro\_std\_y                | num    | Standard deviation value in the Y axis.                                                                                               |
| time\_BodyGyro\_std\_z                | num    | Standard deviation value in the Z axis.                                                                                               |
| time\_BodyGyroJerk\_mean\_x           | num    | Mean value in the X axis.                                                                                                             |
| time\_BodyGyroJerk\_mean\_y           | num    | Mean value in the Y axis.                                                                                                             |
| time\_BodyGyroJerk\_mean\_z           | num    | Mean value in the Z axis.                                                                                                             |
| time\_BodyGyroJerk\_std\_x            | num    | Standard deviation value in the X axis.                                                                                               |
| time\_BodyGyroJerk\_std\_y            | num    | Standard deviation value in the Y axis.                                                                                               |
| time\_BodyGyroJerk\_std\_z            | num    | Standard deviation value in the Z axis.                                                                                               |
| time\_BodyAccMag\_mean                | num    | Magnitude mean value.                                                                                                                 |
| time\_BodyAccMag\_std                 | num    | Magnitude standard deviation value.                                                                                                   |
| time\_GravityAccMag\_mean             | num    | Magnitude mean value.                                                                                                                 |
| time\_GravityAccMag\_std              | num    | Magnitude standard deviation value.                                                                                                   |
| time\_BodyAccJerkMag\_mean            | num    | Jerk magnitude mean value.                                                                                                            |
| time\_BodyAccJerkMag\_std             | num    | Jerk magnitude standard deviation value.                                                                                              |
| time\_BodyGyroMag\_mean               | num    | Magnitude mean value.                                                                                                                 |
| time\_BodyGyroMag\_std                | num    | Magnitude standard deviation value.                                                                                                   |
| time\_BodyGyroJerkMag\_mean           | num    | Jerk magnitude mean value.                                                                                                            |
| time\_BodyGyroJerkMag\_std            | num    | Jerk magnitude standard deviation value.                                                                                              |
| freq\_BodyAcc\_mean\_x                | num    | Mean value in the X axis.                                                                                                             |
| freq\_BodyAcc\_mean\_y                | num    | Mean value in the Y axis.                                                                                                             |
| freq\_BodyAcc\_mean\_z                | num    | Mean value in the Z axis.                                                                                                             |
| freq\_BodyAcc\_std\_x                 | num    | Standard deviation value in the X axis.                                                                                               |
| freq\_BodyAcc\_std\_y                 | num    | Standard deviation value in the Y axis.                                                                                               |
| freq\_BodyAcc\_std\_z                 | num    | Standard deviation value in the Z axis.                                                                                               |
| freq\_BodyAcc\_meanFreq\_x            | num    | Weighted average of the frequency components to obtain a mean frequency in the X axis.                                                |
| freq\_BodyAcc\_meanFreq\_y            | num    | Weighted average of the frequency components to obtain a mean frequency in the Y axis.                                                |
| freq\_BodyAcc\_meanFreq\_z            | num    | Weighted average of the frequency components to obtain a mean frequency in the Z axis.                                                |
| freq\_BodyAccJerk\_mean\_x            | num    | Mean value in the X axis.                                                                                                             |
| freq\_BodyAccJerk\_mean\_y            | num    | Mean value in the Y axis.                                                                                                             |
| freq\_BodyAccJerk\_mean\_z            | num    | Mean value in the Z axis.                                                                                                             |
| freq\_BodyAccJerk\_std\_x             | num    | Standard deviation value in the X axis.                                                                                               |
| freq\_BodyAccJerk\_std\_y             | num    | Standard deviation value in the Y axis.                                                                                               |
| freq\_BodyAccJerk\_std\_z             | num    | Standard deviation value in the Z axis.                                                                                               |
| freq\_BodyAccJerk\_meanFreq\_x        | num    | Weighted average of the frequency components to obtain a mean frequency in the X axis.                                                |
| freq\_BodyAccJerk\_meanFreq\_y        | num    | Weighted average of the frequency components to obtain a mean frequency in the Y axis.                                                |
| freq\_BodyAccJerk\_meanFreq\_z        | num    | Weighted average of the frequency components to obtain a mean frequency in the Z axis.                                                |
| freq\_BodyGyro\_mean\_x               | num    | Mean value in the X axis.                                                                                                             |
| freq\_BodyGyro\_mean\_y               | num    | Mean value in the Y axis.                                                                                                             |
| freq\_BodyGyro\_mean\_z               | num    | Mean value in the Z axis.                                                                                                             |
| freq\_BodyGyro\_std\_x                | num    | Standard deviation value in the X axis.                                                                                               |
| freq\_BodyGyro\_std\_y                | num    | Standard deviation value in the Y axis.                                                                                               |
| freq\_BodyGyro\_std\_z                | num    | Standard deviation value in the Z axis.                                                                                               |
| freq\_BodyGyro\_meanFreq\_x           | num    | Weighted average of the frequency components to obtain a mean frequency in the X axis.                                                |
| freq\_BodyGyro\_meanFreq\_y           | num    | Weighted average of the frequency components to obtain a mean frequency in the Y axis.                                                |
| freq\_BodyGyro\_meanFreq\_z           | num    | Weighted average of the frequency components to obtain a mean frequency in the Z axis.                                                |
| freq\_BodyAccMag\_mean                | num    | Magnitude mean value.                                                                                                                 |
| freq\_BodyAccMag\_std                 | num    | Magnitude standard deviation value.                                                                                                   |
| freq\_BodyAccMag\_meanFreq            | num    | Weighted average of the frequency components to obtain a mean frequency.                                                              |
| freq\_BodyBodyAccJerkMag\_mean        | num    | Jerk magnitude mean value.                                                                                                            |
| freq\_BodyBodyAccJerkMag\_std         | num    | Jerk magnitude standard deviation value.                                                                                              |
| freq\_BodyBodyAccJerkMag\_meanFreq    | num    | Weighted average of the frequency components to obtain a mean frequency.                                                              |
| freq\_BodyBodyGyroMag\_mean           | num    | Magnitude mean value.                                                                                                                 |
| freq\_BodyBodyGyroMag\_std            | num    | Magnitude standard deviation value.                                                                                                   |
| freq\_BodyBodyGyroMag\_meanFreq       | num    | Weighted average of the frequency components to obtain a mean frequency.                                                              |
| freq\_BodyBodyGyroJerkMag\_mean       | num    | Jerk magnitude mean value.                                                                                                            |
| freq\_BodyBodyGyroJerkMag\_std        | num    | Jerk magnitude standard deviation value.                                                                                              |
| freq\_BodyBodyGyroJerkMag\_meanFreq   | num    | Weighted average of the frequency components to obtain a mean frequency.                                                              |
| angle\_tBodyAccMean\_gravity          | num    | Additional vector obtained by averaging the signals in a signal window sample.                                                        |
| angle\_tBodyAccJerkMean\_gravityMean  | num    | Additional vector obtained by averaging the signals in a signal window sample.                                                        |
| angle\_tBodyGyroMean\_gravityMean     | num    | Additional vector obtained by averaging the signals in a signal window sample.                                                        |
| angle\_tBodyGyroJerkMean\_gravityMean | num    | Additional vector obtained by averaging the signals in a signal window sample.                                                        |
| angle\_x\_gravityMean                 | num    | Additional vector obtained by averaging the signals in a signal window sample.                                                        |
| angle\_y\_gravityMean                 | num    | Additional vector obtained by averaging the signals in a signal window sample.                                                        |
| angle\_z\_gravityMean                 | num    | Additional vector obtained by averaging the signals in a signal window sample.                                                        |
