run_analysis <- function() {
    
    # Load libraries.
    library(dplyr)
    library(tidyr)

    # Prepare and load the data.
    test_data <- prepare_data("test")
    train_data <- prepare_data("train")
    
    # Join the datasets.
    dataset <- bind_rows(test_data, train_data)
    
    # Check there are 10,299 observations.
    if(nrow(dataset) != 10299) {
        stop("Observations count is not 10,299.")
    }
    
    return(dataset)
    
}