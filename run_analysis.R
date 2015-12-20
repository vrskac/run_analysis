# If "regenerate" is TRUE then regenerate the "dataset.csv" file, otherwise it
# will be loaded locally if available.
run_analysis <- function(regenerate = FALSE) {
    
    # Load libraries.
    library(dplyr)
    library(tidyr)
    
    # Source scripts.
    source("prepare_data.R")
    source("tidy_data.R")
    
    # Check if the dataset file exists already.
    dataset_filename <- "dataset.csv"
    if(!file.exists(dataset_filename)) {
        regenerate = TRUE
    }
    
    if(regenerate) {
        # Prepare and load the data.
        test_data <- prepare_data("test")
        train_data <- prepare_data("train")
        
        # Join the datasets.
        dataset <- bind_rows(test_data, train_data)
        
        # Check there are 10,299 observations.
        if(nrow(dataset) != 10299) {
            stop("Observations count is not 10,299.")
        }
        
        # Write a CSV with the dataset for further processing.
        write.csv(dataset, file.path(dataset_filename), row.names = FALSE)
    }
    
    # Load the dataset.
    dataset <- tbl_df(read.csv(dataset_filename))
    
    # Tidy the dataset.
    tidy_dataset <- tidy_data(dataset)
    
    return(tidy_dataset)
}