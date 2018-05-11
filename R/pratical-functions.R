#' Function that allows to know if a gene already exists or not
#' 
#' @param genes the list of unique genes.
#' @param id the id of the gene we don't want to duplicate.
#' @return Boolean TRUE if the gene exists, FALSE if not.
#' @rdname existsGene-function
existsGene <- function(genes, id){
    found <- FALSE
    i <- 1
    while(!found && i<=length(genes)){
        if (as.character(genes[[i]]@id) == as.character(id)){
            found <- TRUE
        }
        i <- i+1
    }
    return(found)
}

#' Function to know the OS using the package
#'
#' this function allows us to know if the user is using Linux or Windows
#' 
#' @return numeric 0 if windows, 1 if linux
#' @rdname whichOS-function
whichOS <- function(){
    found <- 0
    
    debut = getwd()
    if (substr(debut, 0,1) == '/') ##ubuntu
        found <- 1
    else ##windows
        found <- 0
    
    ##print(found)
    return(found)
}

#' Function checking if the database is already used
#' 
#' @param databases the list of the databases we have
#' @param i the number of the database we want to know if it's already used
#' @return Boolean TRUE if the database is already used, FALSE if not
#' @rdname alreadyUsedDB-function
alreadyUsedDB <- function(databases,i){
    j <- 1
    alreadyUsed <- FALSE
    while (j < i && !alreadyUsed) {
        if (databases[[j]] == databases[[i]]) {
            alreadyUsed <- TRUE
        }
        else{
            j <- j + 1
        }
    }
    return(alreadyUsed)
}

#' Function which shows errors in DB calls
#'
#' This function shows known errors that may appear in a DB call, 
#' 
#' @param outPut character
#' @return Boolean TRUE if the DB call return an error, FALSE if not
#' @rdname showError-function
showError <- function (outPut) {

    error <- FALSE
    if ( grepl("Website maintenance", outPut) ||
         grepl("Bad request", outPut) ||
         grepl("Forbidden", outPut) ||
         grepl("Not found", outPut) ||
         grepl("Too Many Requests", outPut) ||
         grepl("Internal Server Error", outPut) ||
         grepl("Gateway Timeout", outPut) ||
         grepl("Service Unavailable", outPut) ||
         grepl("HTTP Version Not Supported", outPut) ||
         grepl("Unknow internet error", outPut) ||
         grepl("Exception", outPut))
    {
         message(outPut)
         error <- TRUE
    }
    return (error)
}

#' Function for parsing a JSON format to Data Frame
#'
#' This function will detect in an output the JSON line and return it in Data Frame format
#'
#' @param outPut character
#' @return return in data.frame() format a JSON output
#' @rdname jsonToDataframe-function
jsonToDataframe <- function (outPut) {

    #Detection from which line to which line JSON content is stocked
    for (i in seq(1, length(outPut))){
        if(identical( substr(outPut[i], 1, 2), "[{")) { startLine <- i }
        if(identical( substr(outPut[i], nchar(outPut[i])-1, nchar(outPut[i])), "}]")) { endLine <-i }
    }

    result <- outPut[startLine]

    #Concatenate the JSON lines
    for (i in seq(startLine+1, endLine)) {
        result <- paste(result, outPut[i], sep='')
    }
    
    #Prepare result as a good JSON format
    result <- gsub('\'', '"', result)
    result <- gsub('None', '"NULL"', result)

    return ( fromJSON(result) )
}

#' Function for see the list of the attributes of the class
#'
#' This function will print the attributes of the class
#' 
#' @param class the name of the class you want
#' @return print the attributes of the class
#' @export
#' @rdname getAttributes-function
#' @examples 
#' getAttributes("RAPDB")
getAttributes <- function(class){
    gene <- new(class)
    getAttributesNames(gene)
}

#' Function to create the vector of the attributes you want from a class
#'
#' this function will give you the vector to use selectProperties
#' 
#' @param class the name of the class you want
#' @param attributesVector the attributes you want to extract from the class
#' @return print the attributes of the class
#' @export
#' @rdname createAttributesVector-function
#' @examples 
#' createAttributesVector("RAPDB",c("id"))
createAttributesVector <- function(class, attributesVector){
    result <- purrr::map(attributesVector,function(x, class){
        paste(class, ".", attributesVector, sep = "")
    },class)
    return(result)
}