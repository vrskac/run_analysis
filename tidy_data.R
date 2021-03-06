# The prepared dataset must be supplied as a parameter.
tidy_data <- function(dataset) {
    
    # Get the dataset column names.
    oldcols <- as.character(colnames(dataset))
    newcols <- new("character")
    
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
    
    dataset %>% 
    # Arrange by subject then activity.
    arrange(subject, activity) %>%
    # Setup groupings.
    group_by(subject, activity) %>%
    # Within the groups get the mean for each variable.
    summarise_each(funs(mean)) %>%
    # Return tidied dataset.
    return()
    
}