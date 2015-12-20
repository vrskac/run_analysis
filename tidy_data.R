tidy_data <- function(dataset) {
    
    # Convert the activity column to character vector.
    dataset$activity <- as.character(dataset$activity)
    
    # Tidy the dataset.
    dataset <- dataset %>%
    gather(signal, value, everything(), -subject, -activity) %>%
    separate(signal, c("signal", "calculation"), extra = "merge") %>%
    separate(calculation, c("calculation", "axis"))
    
    # Set blank axis values to NA.
    dataset$axis[dataset$axis == ""] <- NA
    
    return(dataset)
    
}