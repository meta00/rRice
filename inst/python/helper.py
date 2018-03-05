"""Helper module
Handle supportive function such as connection handling, path checking and error handling
"""

import os
import requests
import sys
import re
import pandas as pd
from bs4 import BeautifulSoup

def existFile(pathToFile):
    """
    :param pathToFile: entire path to the file
    :return: return True if the file already exist, else return False
    """
    return (os.path.isfile(pathToFile))


def formatPathToFile(nameFile):
    """
    :param nameFile: name of the file with its extension
    :return: return the entire path to the file
    """

    # remove char until '/'
    pathToFile = os.path.dirname(__file__)
    #while not (pathToFile.endswith('/')):
    #    pathToFile = pathToFile[0:-1]

    pathToFile += '/resources/'+nameFile
    return pathToFile


def loadFileURL(nameFile, url):
    """
    Download the file located in the rapdb download page

    :param nameFile: name of the file (the all path to the file if you want to save the file in another folder)
    :param url: url where is located the file

    """

    # Fetch the file by the url and decompress it
    r = requests.get(url)

    # Create the file .txt
    with open(nameFile, "wb") as f:
        f.write(r.content)
        print("File created")
        f.close()

def connectionError(link, data=""):

    """
    Return requests.get(link) with post request and test website issues

    :param link: URL
    :param data: data to give to the form
    :return: requests.get(link)
    """
    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.0; WOW64; rv:24.0) Gecko/20100101 Firefox/24.0'}
        if data!= "":
            res = requests.post(link, data=data, headers=headers)
        else:
            res = requests.get(link, allow_redirects=False)
        if res.status_code != 200:
            raise Exception('Server Error: ' + str(res.status_code))
            # sys.exit(1)
        return res

    except requests.exceptions.RequestException:
        raise Exception("Internet Connection error")
        # sys.exit(1)