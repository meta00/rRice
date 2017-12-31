import helper
from bs4 import BeautifulSoup
import json
import re
import csv


def query(db, qfields=[]):

    # database descriptor querry
    database_descriptor = BeautifulSoup(open(
        "database-description.xml").read(), "xml").findAll("database", dbname=db.lower())
    if not database_descriptor:
        raise ValueError('Database Not Found')

    # Prepare URL
    link = database_descriptor[0].findAll("link")[0]["stern"]
    # Get Headers list
    headers = []
    for header in database_descriptor[0].findAll("header"):
        headers.append(header.text)
    # Get query qfields list
    fields = []
    for field in database_descriptor[0].findAll("field"):
        fields.append(field.text)

    if database_descriptor[0]["method"] == "POST":
        i = 0
        for field in fields:
            data = {field: qfields[i]}
            i += 1
        res = helper.connectionError(link, data)
    elif database_descriptor[0]["method"] == "GET":
        query_string = ""
        if database_descriptor[0]["type"] != "text/csv":
            i = 0
            for field in fields:
                # Detect controller field (always first field)
                if field == "":
                    query_string += qfields[i] + "?"
                # All other fields are query fields
                else:
                    query_string += field + "=" + qfields[i] + "&"
                i += 1
            query_string = query_string[:-1]
            link += query_string + \
                database_descriptor[0].findAll("link")[0]["aft"]
        res = helper.connectionError(link)

    # Handle HTML based query
    if(database_descriptor[0]["type"] == "text/html"):
        # Handling Connection
        ret = BeautifulSoup(res.content, "lxml")

        data = ret.findAll(database_descriptor[0].findAll("data_struct")[0]["indicator"],
                           {database_descriptor[0].findAll("data_struct")[0]["identifier"]:
                            database_descriptor[0].findAll("data_struct")[0]["identification_string"]})
        result = []
        count = 0
        if data != []:
            regex = re.compile(database_descriptor[0].findAll(
                "prettify")[0].text, re.IGNORECASE)
            replaceBy = database_descriptor[0].findAll(
                "prettify")[0]['replaceBy']
            for dataLine in data[0].findAll(database_descriptor[0].findAll("data_struct")[0]["line_separator"]):
                dict = {}
                i = 0
                for dataCell in dataLine.findAll(database_descriptor[0].findAll("data_struct")[0]["cell_separator"]):
                    #dataNearly = re.sub(r'\xa0',' ', dataCell.text)
                    #dataFormat = regex.sub("", dataNearly)
                    dataFormat = regex.sub(replaceBy, dataCell.text)
                    dict[headers[i]] = dataFormat
                    i += 1
                if dict == {}:
                    continue
                result.append(dict)
        return result
    # Handle JSON based query
    elif(database_descriptor[0]["type"] == "text/JSON"):
        # Return as a List of Dictionary
        return json.loads(res.content.decode("UTF-8"))
    # Handle csv based DB
    if(database_descriptor[0]["type"] == "text/csv"):
        ret = csv.reader(res.content.decode(database_descriptor[0]["encoding"]).splitlines(
        ), delimiter=list(database_descriptor[0]["deli"])[0], quoting=csv.QUOTE_NONE)
        data = []
        for row in ret:
            i = 0
            dict = {}
            for header in headers:
                dict[header] = row[i]
                i += 1
            f = 0
            for field in fields:
                if (dict[field] == qfields[f]) & (qfields[f] != ""):
                    data.append(dict)
                f += 1
        return data


# def multiple_gene_query(db, geneList):
#     ret = []
#     for gene in geneList:
#         ret.append(single_gene_query(db, gene))
#     return ret
