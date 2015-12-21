CookBook
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
-   We will match the converted variable names for the strings ".mean.." and ".std.." for the purpose of identifying the mean and standard deviation columns we are interested in keeping.

Checks
------

-   Once the "test" and "train" datasets have been joined, there should be exactly 10,299 observations.
-   The "test" dataset should have 9 unique subjects.
-   The "train" dataset should have 21 unique subjects.
-   The joined dataset of 10,299 observations should have 30 unique subjects.

Detailed functional description of the scripts
----------------------------------------------

### run\_analysis.R

-   When calling the run\_analysis function three parameters can be supplied, all of which are logical and default to FALSE.
    -   return\_tidy\_data is a flag to indicate if a dplyr tbl\_df of the tidy data should be returned to the function caller.
    -   re\_prepare is a flag to indicate if the raw data needs to be re-prepared and the prepare\_data.csv file rebuilt.
    -   re\_tidy is a flag to indicate if the prepared data needs to be re-tidied and the tidy\_data.csv file rebuilt.

``` r
run_analysis <- function(return_tidy_data = FALSE, re_prepare = FALSE, re_tidy = FALSE)
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

-   If return\_tidy\_data is TRUE, then read the tidy data from CSV and return it to the function caller.

``` r
if(return_tidy_data) {
    cols = c(subject = "integer", 
             activity = "character",
             domain = "character",
             signal_type = "character",
             signal_source = "character",
             signal_form = "character", 
             calculation = "character", 
             axis = "character", 
             value = "double")
    return(tbl_df(read.csv(filename_tidy_data,
                           colClasses = cols)))
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

-   We match the converted variable names for the strings ".mean.." and ".std.." for the purpose of identifying the mean and standard deviation columns we are interested in keeping. We create a logical vector so we know the positions of the variables we want to keep.

``` r
# Get a list of the variables we need to work with, based on matching the
# list for ".mean.." and ".std..".
selected_variables <- as.logical(
    grepl(".mean..", valid_variable_labels, fixed = TRUE) + 
        grepl(".std..", valid_variable_labels, fixed = TRUE))
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

-   Tidy up the measurement variables, following our convention to use "\_" to split out information within the variable name. We also follow a convention of using lowercase for our padding information, i.e. the extra parts of the variable name that are not part of the main identifier. Lastly we remove any trailing characters that we don't need, before setting the new columns names for the dataset.

``` r
# Tidy the variable name strings.
newcols <- gsub(".mean.", "_mean_", newcols, fixed = TRUE)
newcols <- gsub(".std.", "_std_", newcols, fixed = TRUE)
newcols <- gsub("..X", "x", newcols, fixed = TRUE)
newcols <- gsub("..Y", "y", newcols, fixed = TRUE)
newcols <- gsub("..Z", "z", newcols, fixed = TRUE)
newcols <- gsub("_.", "", newcols, fixed = TRUE)

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

#### Output variable descriptions

The output data is grouped with the following heirarchy.

-   subject \> activity \> domain \> signal\_type \> signal\_source \> signal\_form \> calculation \> axis

| Variable       | Class | Description                                                                                                                                                                                                                                                                                                                                                       |
|----------------|-------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| subject        | int   | The subject identifier from 1 to 30.                                                                                                                                                                                                                                                                                                                              |
| activity       | chr   | The activity type from a list of 6 options of "laying", "sitting", "standing", "walking", "walking\_downstairs", "walking\_upstairs".                                                                                                                                                                                                                             |
| domain         | chr   | Domain signal type, either "time" for time or "freq" for frequency.                                                                                                                                                                                                                                                                                               |
| signal\_type   | chr   | The acceleration signal type, either "body" or "gravity".                                                                                                                                                                                                                                                                                                         |
| signal\_source | chr   | The source of the signal, either "accelerometer", "bodyaccelerometer", "bodygyroscope" or "gyroscope". Note that the string "body" was featured twice in some of the messy variable names. For these variables we have used the first "body" for the "signal\_type" variable and the second "body" has been left as part of this "signal\_source" variable value. |
| signal\_form   | chr   | The signal form, either "jerk", "mag", "jerkmag" or NA.                                                                                                                                                                                                                                                                                                           |
| calculation    | chr   | The calculation performed, either "mean" for the mean or "std" for the standard deviation.                                                                                                                                                                                                                                                                        |
| axis           | chr   | The signal axis, if any, either "x", "y", "z" or NA.                                                                                                                                                                                                                                                                                                              |
| mean\_value    | dbl   | The mean value of the measurement.                                                                                                                                                                                                                                                                                                                                |
