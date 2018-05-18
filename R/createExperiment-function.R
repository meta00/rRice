#' Function to create an Experiment
#' 
#' This function allows to create an Experiment object, with a name and a
#' locus list. The locus list is a .txt file, so you have to do a "read.table"
#' of your file into a variable and put this variable as the "locus" parameter
#' in the constructor. 
#'
#' @param name The name of the Experiment
#' @param locus The Table of locus 
#' @importFrom methods new
#' @return An Experiment
#' @export
#' @rdname createExperiment-function
#' @examples 
#' locusListExample <- data.frame(ch = c("1"),st = c("148907"),end = c("248907"))
#'
#' Exemple file provided in the package :
#' locusList <- read.table(file = ".../locusList.txt", col.names = c("ch","start","end")) 
#' 
#' createExperiment("example",locusList)

createExperiment <- function(name, locus){


    ## User choice of databases
    databasesList()
    correctInput <- FALSE
    while (!correctInput) {
        correctInput <- TRUE
        input <- readline( prompt= "Please choose databases you want to add to your experiment ( i.e.  2/3/7 ) : ")
        if ( grepl('/', input) ) { 
            choosenDBs <- unlist(strsplit(input, split="/"))
            choosenDBs <- unique(choosenDBs)
        } else {
            choosenDBs <- unlist(input)
        }
        nbdb <- length(choosenDBs)
        databases <<- vector(mode='list', length=nbdb)
        for (i in seq(1, nbdb)) {
            if ( is.na( as.numeric(choosenDBs[i]) ) || as.numeric(choosenDBs[i]) > databasesAvailables() ) { 
                correctInput <- FALSE
                message("Please write it in the asked format")
                break;
            }
                databases[[i]] <<- changeNumberIntoDBName( as.numeric(choosenDBs[i]) )##
            }
        }

        ## User choice of date
        correctDate <- FALSE
        while (!correctDate) {
            date <- ( readline(prompt="Enter the date of the experiment (mm/dd/yyyy) : ") )
            date <- as.Date( c(date), format =  "%m/%d/%Y" )
            if (!is.na(date) && 
               format(date, '%Y') > 1900 &&
               format(date, '%Y') <= format(Sys.Date(), '%Y'))
            {
                correctDate <- TRUE
            } else {
                message("Please write the date in the asked format")
            }
        }


        message("Reception of genes IDs ...")
        message("It can take a moment")

        ##Getting all the geneIds of the locuses
        genesIds <- genesIds(locus)
        View(genesIds) ## DEV

        ##Creating of the list which will have the genes of the databases DB calls
        genes <- list()
        for (i in seq(1, nbdb)) {
               message( paste("Loading information from", databases[[i]], "...", sep=" "))
               ###showError(....)               ////Ne pas oublier la gestion des erreurs 
               ##callDB <- paste("callDB",
               ####                 changeDBNameIntoNumber(databases[i]),
               ####                 sep="")
               #### genes[[i]] <- (do.call(callDB, args = list(genesIds, locus)))                
        }

        result <- new("Experiment",
                      name=name,
                      date=date,
                      databases=databases,
                      genes=genes,
                      others=list())
        return(result)
}
    
