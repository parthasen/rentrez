#' See how many hits there are for a given term across all NCBI Entrez databases
#'
#' 
#'
#'@export
#'@param term the search term to use
#'@param config vector configuration options passed to httr::GET  
#'@param ... additional arguments to add to the query
#'@seealso \code{\link[httr]{config}} for available configs 
#'@return a named vector with counts for each a database
#'
#'@import XML
#' @examples
#' 
#' NCBI_data_on_best_butterflies_ever <- entrez_global_query(term="Heliconius")

entrez_global_query <- function(term, config=NULL, ...){
    response <- make_entrez_query("egquery", 
                                    term=gsub(" ", "+", term), 
                                    config=config,
                                    ...)
    record <- XML::xmlTreeParse(response, useInternalNodes=TRUE)
    db_names <- XML::xpathSApply(record, "//ResultItem/DbName", XML::xmlValue)
    get_Ids <- function(dbname){
        path <-  paste("//ResultItem/DbName[text()='", dbname, "']/../Count", sep="")
        res <- as.numeric(XML::xpathSApply(record, path, XML::xmlValue))
    }
    #NCBI limits requests to three per second
    Sys.sleep(0.33)
    res <- structure(sapply(db_names, get_Ids), names=db_names)
    return(res)
}
