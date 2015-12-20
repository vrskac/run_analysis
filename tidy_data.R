tidy_data <- function(dataset) {
    
    # Tidy the dataset.
    dataset <- dataset %>%
        gather(signal, value, everything(), -subject, -activity) %>%
        separate(signal, c("signal", "calculation"), extra = "merge") %>%
        separate(calculation, c("calculation", "axis")) %>%
        arrange(subject)
    
    # Set blank axis values to NA.
    dataset$axis[dataset$axis == ""] <- NA
    
    # Tidy up activity values.
    dataset$activity <- as.character(dataset$activity)
    dataset$activity[dataset$activity == "STANDING"] <- "standing"
    dataset$activity[dataset$activity == "SITTING"] <- "sitting"
    dataset$activity[dataset$activity == "LAYING"] <- "laying"
    dataset$activity[dataset$activity == "WALKING"] <- "walking"
    dataset$activity[dataset$activity == "WALKING_DOWNSTAIRS"] <- "walking_downstairs"
    dataset$activity[dataset$activity == "WALKING_UPSTAIRS"] <- "walking_upstairs"
    
    return(dataset)
    
}