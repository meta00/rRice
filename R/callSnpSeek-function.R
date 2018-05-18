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

#' genesIds
#' 
#' It will return a list of IDs (in RapDB, Msu7 and Iric format) of genes
#' for each locus of the locus list
#' 
#' @param locusList the list of locus for which we want the genes IDs
#' @return the list of IDs of each gene present in the locuses 
#' @rdname genesIds-function
#' @examples 
#' locusList <- read.table(file = ".../locusList.txt", col.names = c("ch","start","end"))              
#' genesIds(locusList)

genesIds <- function(locusList){
    listIds <- data.frame()
    badFormat <- FALSE
    apply(locusList, 1, checkInput)
    
    #lapply( split(locusList, seq( nrow(locusList))), getIds)

    for (i in seq(1 : nrow(locusList))) {
            listIds <- rbind(listIds, callSnpSeek(locusList[i,]))
     } 

    return (listIds)
}


#' callSnpSeek
#'
#' This function makes a SnpSeek DB call for a locus and has to return the list of ids 
#' present in this locus
#' 
#' @param locus The locus we want to get the genes IDs 
#' @return This function will return a list which contains the genes ids present in a locus
#' @importFrom findpython find_python_cmd
#' @rdname callSnpSeek-function
#' @example
#' 

callSnpSeek <- function(locus) {
    ##Changing the working directory to give access at python files no matter the user current directory
    ## (Because database-description.xml is called at current directory in python code)
    wd <- getwd()
    python <- system.file("python",
                          package = "rRice")
    setwd(python)

    ##Path of python db call file, run.py
    path <- system.file("python",
                        "run.py",
                        package = "rRice")
    if ( whichOS() == "Windows"){ path <- shortPathName(path) }
    
    ch <- as.integer(locus[[1]])
    start <- as.integer(locus[[2]])
    end <- as.integer(locus[[3]])

    if (ch >= 10 && ch <= 12) {
        ch <- paste("chr", locus[[1]], sep = "")

    } else if (ch < 10 && ch > 0) {
        ch <- paste("chr0", locus[[1]], sep = "")
    }   


    tmpFile <- tempfile(pattern = "", fileext = ".csv")
    
    if (ch != "" && start != "" && end != "") {
        ##Call run.py from python
        if ( whichOS() == "Windows") {
            args <- c(path, "snpseek", ch, start, end, "rap", "-f csv", paste("-o", tmpFile, sep=" "))
            cmd <- findpython::find_python_cmd()
            rOutput <- system2(command = cmd, args=args, stdout = TRUE)
        } else {
            args <- c(path, "snpseek", ch, start, end, "rap", "-f csv", paste("-o", tmpFile, sep=" "))
            rOutput <- system2(command = path, args=args, stdout = TRUE)
        }

        print( paste(ch, start, end, ":", rOutput[2], sep=" "))  #DEV
        
        ##Display errors if appeared and then stop the execution
        error <- FALSE
        if ( !grepl("Query exported to", rOutput[2])) {
            error <- TRUE
            errorMessage <- unlist( lapply( seq_along(rOutput), FUN = function(x) showError(rOutput[x])))
        } 
        if (!error) {
            ##Read of generated csv file only if there is no error
            rOutput <- read.csv2(tmpFile, na.string = "", sep = ',')
        } else {
            stop(errorMessage)
        }      

        ##Get only the information we want
        genesIds <- data.frame("Rap_ID" = rOutput$uniquename,
                               "Msu7_name" = rOutput$msu7Name, 
                               "Iric_name" =  rOutput$iricname)

        ##Back to original user working directory
        setwd(wd)

        return (genesIds)
    } else {
        return (list())
    }
}


#' checkInput
#' 
#' Check if the input is in a good format, if not, stop the program 
#' and displays the error
#' 
#' @param locus The locus we want to get the genes IDs 
#' @rdname checkInput-function

checkInput <- function(locus){

    ch <- as.integer(locus[[1]])
    start <- as.integer(locus[[2]])
    end <- as.integer(locus[[3]])

    msg <- ""

    if (length(locus) != 3) {
        msg <- paste(msg, "Input is not on a good format" , sep = '\n')

    } else if ( nrow(locusList) == 0 ) {
        msg <-  paste(msg, "Input is empty" , sep = '\n')

    } else if (is.na(ch) || is.na(start) || is.na(end)) {
        msg <-  paste(msg, 
                paste("Not number values in", locus[[1]], locus[[2]], locus[[3]]), sep = '\n')
    
    } else if (ch < 1 || ch > 12 ) {
        msg <-  paste(msg,
                paste("Wrong chromosone number in", ch, start, end), sep = '\n')

    } else if (start < 0 || end < 0 || end < start) {
        msg <- paste(msg,
               paste("Wrong locus in", ch, start, end), sep = '\n')
    }

    if (msg != "") { stop(msg) }

    return()
}

