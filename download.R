# Download 
library(here)
library(jsonlite)
library(tidyverse)

# https://www.newcastlede.gov/318/Crime-Map
query_URL <- "https://gis.nccde.org/agsserver/rest/services/PublicSafety/Public_Safety_Civic/FeatureServer/0/query?f=json&outfields=*"
container_df <- NULL
cur_page <- 1
result_offset <- 0 # offset for query

# Paginate the 
while(TRUE){
  cat("Processing Cases starting with ", result_offset, "\n")

  queary_URL_paged <- paste0(query_URL, "&resultOffset=", result_offset)
  
  downloaded_list <- fromJSON(queary_URL_paged)
  
  crimes_df <- downloaded_list[["features"]][["attributes"]] %>%
    as_tibble()
  
  container_df <- container_df %>% 
    bind_rows(crimes_df)
  
  # Update offset
  result_offset <- result_offset + nrow(crimes_df)
  
  # Do not continue if the obtained json does not exceed the transfer limit
  if(is.null(downloaded_list$exceededTransferLimit)) break
}
# Output the file
write_rds(container_df, compress = "gz",
          here("data.rds"))
