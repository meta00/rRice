# noDoubleIds
#
# This function allows to avoid the problem when the id is composed by 2 ids
# Example : Os01g0115500,Os01g0115566
#
# @param id character
# @return It will return only one id if it is not a double ID. Otherwise, it
# will return a list with the both ids
# @rdname noDoubleIds-function
#noDoubleIds <- function (id) { 
#    ##print(id[[1]]) -> id
#    ##print(id[[2]]) -> msu7Name
#    ##print(id)
#    msu7Name <- as.character(id[[2]])
#    iricname <- as.character(id[[3]])
#    id <- as.character(id[[1]])
#    
#    
#    ##for the ids like "Os01g0115500,Os01g0115566" (the double ids)
#    ##we only test the first id
#    if(grepl(',', id)) 
#    {
#        ids <- strsplit(id, ",")
#        id <- ids[[1]][[1]]
#        id1 <- ids[[1]][[2]]
#        liste <- list(id,id1)
#        return(list(list(id,msu7Name,iricname),list(id1,msu7Name,iricname)))
#    }
#    else {
#        return(list(list(id,msu7Name,iricname)))
#    }
#}

# id
#
# This function will only return the id from the rOutput 
# 
# @param rOutput character
# @return this funciton will only return the id
# @importFrom jsonlite fromJSON
# @rdname id-function
#id <- function (rOutput) {
    #output <- getOutPutJSON(rOutput)
    #print(rOutput)
    
    #t <- '{"msu7Name": "LOC_Os01g01970"}' # --> BON
    #t <- "{'msu7Name': 'LOC_Os01g01970'}" # --> PAS BON POUR JSON
    # rOutput <- {'contig': 'chr01',
    #             'fmin': 524578, 
    #             'rappredName': 'None', 
    #             'fmax': 528002, 
    #             'strand': -1, 
    #             'uniquename': 'LOC_Os01g01970', 
    #             'fgeneshName': 'chr01-gene_91', 
    #             'msu7Name': 'LOC_Os01g01970', 
    #             'description': 'expressed protein', 
    #             'raprepName': 'Os01g0109750', 
    #             'iricname': 'OsNippo01g015950'}
    
    ##A VOIR AVEC BAPTISTE POUR QUE JE RECOIVE UN BON JSON
#    rOutput <- gsub('\'', '"', rOutput)
 #   rOutput <- gsub('None', '"None"', rOutput)
    
    #print(j['msu7Name'])
   # jsonOutput <- fromJSON(rOutput)
   # if (jsonOutput['rappredName'] == "None"){
   #     id <- jsonOutput['raprepName']
   # }
   # else if (jsonOutput['rapredName'] == "None") {
   #     id <- jsonOutput['rappredName']
   # }
   # else {
   #     id <- jsonOutput['raprepName']
   # }
    
   # locName <- jsonOutput['msu7Name']
   # iricname <- jsonOutput['iricname']
    #print(iricname)
    
    #if (id != "None") {
   #     return (list(id,locName,iricname))
    #}
    
#}

#' getIds
#'
#' This function is called for each locus and has to return the list of ids 
#' present in the locus
#' 
#' @param i number
#' @param locusList list
#' @return This function will return a list with all the ids from a locus
#' @importFrom jsonlite fromJSON
#' @importFrom findpython find_python_cmd
#' @rdname getIds-function
getIds <- function (i, locusList) {
    ##PATH for package when it will be installed -> when it will be released
    path <- system.file("python",
                        "run.py",
                        package = "rRice")
    
    ##manage the spaces -> for example "Program Files" under windows will 
    ##generate an error because with system2 we generate a command line
    ##with multiple arguments in one string. 
    if (Sys.info()["sysname"] == "Windows"){
        path <- shortPathName(path)
    }
    
    if (as.integer(locusList[i,1]) < 10) {
        ch <- paste("chr0", locusList[i,1], sep = "")
    } else {
        ch <- paste("chr", locusList[i,1], sep = "")
    }

    start <- as.character(locusList[i,2])
    end <- as.character(locusList[i,3])
    
    if (ch != "" && start != "" && end != "") {
        ##Call run.py from python
        if (Sys.info()["sysname"] == "Windows") {
            args <- c(path, "snpseek", ch, start, end, "rap", "-f csv", "-o genesInfo.csv")
            cmd <- findpython::find_python_cmd()
            rOutput <- system2(command = cmd, args=args, stdout = TRUE)
        } else {
            args <- c(path, "snpseek", ch, start, end, "rap", "-f csv", "-o genesInfo.csv")
            rOutput <- system2(command = path, args=args, stdout = TRUE)
        }

        ##Display error if appeared and stop the execution
        error <- FALSE
        for (i in seq (1, length(rOutput))) {
            if (showError(rOutput[i])) {
                error <- TRUE
           }     
        }
        if (!error) {
            rOutput <- read.csv2("genesInfo.csv", sep = ',')
        } else {
            stop("The database call generates an error")
        }

        ##Delete the temporal csv file
        file.remove("genesInfo.csv")

        ##Get only the information we want
        genesIds <- data.frame("Rap_ID" = rOutput$uniquename,
                               "Msu7_name" = rOutput$msu7Name, 
                               "Iric_name" =  rOutput$iricname)

        return (genesIds)

    } else {
        return (list())
    }
}

#' CallSnpSeek
#' 
#' It will return a list of Genes IDs (RapDB, Msu7 and Iric format)
#' 
#' @param locus the list of locus for which we want the ids as a Data Frame
#' @return the list of id's of each genes we want
#' @export
#' @rdname callSnpSeek-function
#' @examples 
#' locusList <- data.frame()
#'                   
#' callSnpSeek(locusList)
callSnpSeek <- function(locus){
    
    listIds <- data.frame()
    
    if (nrow(locus) > 0) {
       for (i in seq(1, nrow(locus))) {
            listIds <- rbind(listIds, getIds(i, locus))
        } 
    }
    return (listIds)
}



