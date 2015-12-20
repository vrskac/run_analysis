# The prepared dataset must be supplied as a parameter.
tidy_data2 <- function(dataset) {
    
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

    # Tidy up the occurence of mean and std in the variable names.
    newcols <- gsub(".mean.", "_mean_", newcols, fixed = TRUE)
    newcols <- gsub(".std.", "_std_", newcols, fixed = TRUE)
    
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