# The prepared dataset must be supplied as a parameter.
tidy_data <- function(dataset) {
    
    # Use tidyr's gather() function to make the data long rather than wide.
    # Exclude the subject and activity columns from the operation, include 
    # all other columns.
    dataset <- dataset %>%
        gather(signal, value, everything(), -subject, -activity) %>%
        # Separate the signal column, putting the calculation and axis part
        # into a new column named calculation.
        separate(signal, c("signal", "calculation"), extra = "merge") %>%
        # Separate the axis value from the calculation column.
        separate(calculation, c("calculation", "axis")) %>%
        # Separate the domain (value t or f) from the signal column, based on
        # separating at the first character, the value of that character going 
        # into a new column called domain.
        separate(signal, c("domain", "signal"), sep = 1)

    # Separate signal for body and gravity.
    dataset$signal <- as.character(dataset$signal)
    dataset$signal <- sub("Body", "body.", dataset$signal, fixed = TRUE)
    dataset$signal <- sub("Gravity", "gravity.", dataset$signal, fixed = TRUE)
    dataset <- dataset %>%
        separate(signal, c("signal_type", "signal"))
    
    # Separate signal for accelerometer and gyroscope.
    dataset$signal <- sub("Acc", "accelerometer.", dataset$signal, fixed = TRUE)
    dataset$signal <- sub("Gyro", "gyroscope.", dataset$signal, fixed = TRUE)
    dataset <- dataset %>%
        separate(signal, c("signal_source", "signal_form"))
    
    # Tidy up activity values.
    dataset$activity <- as.character(dataset$activity)
    dataset$activity[dataset$activity == "STANDING"] <- "standing"
    dataset$activity[dataset$activity == "SITTING"] <- "sitting"
    dataset$activity[dataset$activity == "LAYING"] <- "laying"
    dataset$activity[dataset$activity == "WALKING"] <- "walking"
    dataset$activity[dataset$activity == "WALKING_DOWNSTAIRS"] <- 
        "walking_downstairs"
    dataset$activity[dataset$activity == "WALKING_UPSTAIRS"] <- 
        "walking_upstairs"
    
    # Tidy up domain values.
    dataset$domain <- as.character(dataset$domain)
    dataset$domain[dataset$domain == "t"] <- "time"
    dataset$domain[dataset$domain == "f"] <- "freq"
    
    # Tidy up signal_source values.
    dataset$signal_source <- as.character(dataset$signal_source)
    dataset$signal_source[dataset$signal_source == "Bodyaccelerometer"] <- "bodyaccelerometer"
    dataset$signal_source[dataset$signal_source == "Bodygyroscope"] <- "bodygyroscope"
    
    # Tidy up signal_form values.
    dataset$signal_form[dataset$signal_form == ""] <- NA
    dataset$signal_form[dataset$signal_form == "Jerk"] <- "jerk"
    dataset$signal_form[dataset$signal_form == "Mag"] <- "mag"
    dataset$signal_form[dataset$signal_form == "JerkMag"] <- "jerkmag"
    
    # Tidy up axis values.
    dataset$axis <- as.character(dataset$axis)
    dataset$axis[dataset$axis == "X"] <- "x"
    dataset$axis[dataset$axis == "Y"] <- "y"
    dataset$axis[dataset$axis == "Z"] <- "z"
    
    # Set blank axis values to NA.
    dataset$axis[dataset$axis == ""] <- NA
    
    # Arrange the dataset.
    dataset <- arrange(dataset, subject, activity, domain, signal_type, 
                       signal_source, signal_form, calculation, axis, value)
    
    # Setup groupings.
    dataset <- group_by(dataset, subject, activity, domain, signal_type, 
                        signal_source, signal_form, calculation, axis)
    
    # Summarise mean of the value by groupings.
    summary_dataset <- summarise(dataset, mean_value = mean(value))
    
    # Return the summary dataset.
    return(summary_dataset)
    
}