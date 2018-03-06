import helper
from bs4 import BeautifulSoup
import json
import re
import pandas as pd
import csv

def query(db, qfields=[], outputFormat="dict", outputFile=None):

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
    fields = database_descriptor[0].findAll("field")

    if database_descriptor[0]["method"] == "POST":
        i = 0
        for field in fields:
            data = {field.text: qfields[i]}
            i += 1
        res = helper.connectionError(link, data)
    elif database_descriptor[0]["method"] == "GET":
        query_string = ""
        if database_descriptor[0]["type"] != "text/csv":
            i = 0
            for field in fields:
                # Detect controller field (always first field)
                if "lowercase" in field:
                    print(qfields[i].lower())
                if field.text == "":
                    query_string += qfields[i] + "?"
                # All other fields are query fields
                else:
                    query_string += field.text + field["op"] + qfields[i] + "&"
                i += 1
            query_string = query_string[:-1]
            link += query_string + \
                database_descriptor[0].findAll("link")[0]["aft"]
            print(link)
        res = helper.connectionError(link)

    # Handle HTML based query
    if(database_descriptor[0]["type"] == "text/html"):
        # Handling Connection
        ret = BeautifulSoup(res.content, "lxml")

        data = ret.findAll(database_descriptor[0].findAll("data_struct")[0]["indicator"],
                           {database_descriptor[0].findAll("data_struct")[0]["identifier"]:
                            database_descriptor[0].findAll("data_struct")[0]["identification_string"]})
        result = []
        if data != []:
            regex = re.compile(database_descriptor[0].findAll(
                "prettify")[0].text, re.IGNORECASE)
            replaceBy = database_descriptor[0].findAll(
                "prettify")[0]['replaceBy']
            for dataLine in data[0].findAll(database_descriptor[0].findAll("data_struct")[0]["line_separator"]):
                dict = {}
                i = 0
                for dataCell in dataLine.findAll(database_descriptor[0].findAll("data_struct")[0]["cell_separator"]):
                    dataFormat = regex.sub(replaceBy, dataCell.text)
                    dict[headers[i]] = dataFormat
                    i += 1
                if dict == {}:
                    continue
                dict.pop("", None)
                result.append(dict)

    # Handle JSON based query
    elif(database_descriptor[0]["type"] == "text/JSON"):
        # Return as a List of Dictionary
        result = json.loads(res.content.decode("UTF-8"))
    # Handle csv based DB
    if(database_descriptor[0]["type"] == "text/csv"):
        ret = csv.reader(res.content.decode(database_descriptor[0]["encoding"]).splitlines(
        ), delimiter=list(database_descriptor[0]["deli"])[0], quoting=csv.QUOTE_NONE)
        result = []
        for row in ret:
            i = 0
            dict = {}
            for header in headers:
                dict[header] = row[i]
                i += 1
            f = 0
            for field in fields:
                if (dict[field] == qfields[f]) & (qfields[f] != ""):
                    result.append(dict)
                f += 1
    
    # Handle different Output format
    df = pd.DataFrame(result)
    if(outputFormat == "dict"):
        return result
    elif(outputFormat == "pandas"):
        return df
    elif(outputFormat == "json"):
        if (outputFile != None):
            print("Query exported to ", outputFile)
        return df.to_json(outputFile)
    elif(outputFile == None):
        print("Please specify a destination")
        return
    if(outputFormat == "csv"):
        df.to_csv(outputFile)
        print("Query exported to ", outputFile)
        return
    if(outputFormat == "excel"):
        df.to_excel(outputFile)
        print("Query exported to ", outputFile)
        return