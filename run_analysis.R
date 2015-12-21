# return_tidy_data flag is used to return a tbl_df of the tidy data.
# re_prepare flags rebuild of "prepared_data.csv" file.
# re_tidy flags rebuild of "tidy_data.csv" file.
# Both flags false by default, script will attempt to use existing local files.
run_analysis <- function(return_tidy_data = FALSE, re_prepare = FALSE, 
                         re_tidy = FALSE) {
    
    # Load libraries.
    library(dplyr, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
    library(tidyr, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)

    # Source scripts.
    source("prepare_data.R")
    source("tidy_data.R")
    
    # Setup the filenames.
    filename_prepared_data <- "prepared_data.csv"
    filename_tidy_data <- "tidy_data.csv"  
    
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
    
    if(re_tidy) {
        # Read and tidy the prepared data.
        tidy_df <- tidy_data(tbl_df(read.csv(filename_prepared_data)))
        
        # Write a CSV with the tidy data.
        write.csv(tidy_df, file.path(filename_tidy_data), row.names = FALSE)
        
        message("Info: File tidy_data.csv has been rebuilt.")
    }
    
    if(re_prepare == FALSE & re_tidy == FALSE) {
        message("Warning: No processing was performed.")
        message("Info: prepared_data.csv and tidy_data.csv already exist.")
        message("Info: Set parameter re_prepare = TRUE to re-prepare data.")
        message("Info: Set parameter re_tidy = TRUE to re-tidy data.")
    }
    
    if(return_tidy_data) {
        return(tbl_df(read.csv(filename_tidy_data)))
    }

}