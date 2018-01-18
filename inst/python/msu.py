#!/usr/bin/env python3

import helper
from bs4 import BeautifulSoup
import json

def msu(id):

    link = "http://rice.plantbiology.msu.edu/cgi-bin/sequence_display.cgi?orf="+id
    html_page = helper.connectionError(link)
    soup = BeautifulSoup(html_page.content, "lxml")

    headers = ["Genomic Sequence", "CDS", "Protein"]
    dict = {}
    i = 0
    for search in soup.findAll('pre'):
        dataFormat = search.text.replace('>'+id, '')
        dataFormat = dataFormat.replace('\n', '')
        dict[headers[i]] = dataFormat
        i = i + 1

    return dict

def msu_orf(id):
    
    link = "http://rice.plantbiology.msu.edu/cgi-bin/ORF_infopage.cgi"
    data = {"db":"osa1r5", "orf":"LOC_Os01g62290.1"}
    html_page = helper.connectionErrorPost(link, data)
    soup = BeautifulSoup(html_page.content, "lxml")
    print(soup)

    headers = []
    dict = {}
    # i = 0
    # for search in soup.findAll('pre'):
    #     dataFormat = search.text.replace('>'+id, '')
    #     dataFormat = dataFormat.replace('\n', '')
    #     dict[headers[i]] = dataFormat
    #     i = i + 1

    return dict

print(msu_orf("LOC_Os01g62290.1"))