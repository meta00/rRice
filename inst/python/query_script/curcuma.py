import sqlite3
import csv
import os
import time
from multiprocessing import Pool
from multiprocessing.dummy import Pool as ThreadPool 

import sys
sys.path.append('..')
import query

# Configuration:
# data_set = ['Control-1-NT_25628_clustered_genes_annotations.tab', 'Curcuma-longa-N0-L_25630_clustered_genes_annotations.tab','Curcuma-longa-N350-H_25629_clustered_genes_annotations.tab']
data_set = ['Control-1-NT_25628_clustered_genes_annotations.tab']
db_file_path = '..\\data\\eggnog.db\\eggnog.db'
pool = ThreadPool(4)

# Print iterations progress
# def printProgressBar (iteration, total, prefix = '', suffix = '', decimals = 1, length = 100, fill = '█', elasped_time = None):
#     """
#     Call in a loop to create terminal progress bar
#     @params:
#         iteration   - Required  : current iteration (Int)
#         total       - Required  : total iterations (Int)
#         prefix      - Optional  : prefix string (Str)
#         suffix      - Optional  : suffix string (Str)
#         decimals    - Optional  : positive number of decimals in percent complete (Int)
#         length      - Optional  : character length of bar (Int)
#         fill        - Optional  : bar fill character (Str)
#     """
#     percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
#     filledLength = int(length * iteration // total)
#     bar = fill * filledLength + '-' * (length - filledLength)
#     now = time.time() - elasped_time
#     if elasped_time != None: 
#         now_str = "Elasped time: %02d:%02d:%02d" % (now // 3600, (now % 3600 // 60), (now % 60 // 1))
#         print('\r%s |%s| %s%% %s, %s' % (prefix, bar, percent, suffix, now_str), end = '\r')
#     else:
#         now_str = ""
#         print('\r%s |%s| %s%% %s' % (prefix, bar, percent, suffix), end = '\r')
#     # Print New Line on Complete
#     if iteration == total: 
#         print()

def get_multiple_id(db, ids, field):
    ret = []
    for key in ids:
        if key == "" : return
        try:
            ret.append(query.query(db, [key])[0][field])
        except:
            print(key)
            continue
    return ret

def get_row(row):
    conn = sqlite3.connect(db_file_path)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    
    if row['eggNOG_OG'] != '':
        t = (row["eggNOG_OG"],)
        c.execute("select description from og where og=?",t) 
        ret = c.fetchone()
        if ret != None: 
            row['eggNOG_description'] = ret['description']
        else: 
            row['eggNOG_description'] = None
    
    row['KEGG_ko'] = row['KEGG_ko'].split('|')
    row['KEGG_module'] = row['KEGG_module'].split('|')
    row['KEGG_pathway'] = row['KEGG_pathway'].split('|')
    
    row['kegg_ko_definition'] = get_multiple_id('kegg', row['KEGG_ko'], 'Definition')
    row['kegg_module_definition'] = get_multiple_id('kegg', row['KEGG_module'], 'Definition')
    row['KEGG_pathway_description'] = get_multiple_id('kegg', row['KEGG_pathway'], 'Definition')

def curcuma(set):
    print("Processing file", set,"\n")
    list = []
    tab_file_path = '..\\data\\curcuma\\' + set
    with open(tab_file_path, newline = '') as tabfile:
        dictReader = csv.DictReader(tabfile, delimiter = '\t')
        for each in dictReader:
            list.append(each)
    start = time.time()
    pool.map(get_row, list)
    # for each in list:
    #     get_row(each)
    print("Total time:", time.time() - start)
    # pool.close() 
    # pool.join() 
    
    output_file_path = '../data/curcuma/output/' + set
    with open(output_file_path, 'w+') as tabfile:
        # headers = ['#gene','eggNOG_OG','eggNOG_description','kegg_ko_definition','kegg_module_definition','KEGG_pathway_description']
        
        headers = ['#gene','eggNOG_OG','eggNOG_description','kegg_ko_definition','kegg_module_definition']
        dictWriter = csv.DictWriter(tabfile, delimiter = '\t', fieldnames = headers)
        dictWriter.writeheader()
        for each in list:
            dictWriter.writerow({header:each[header] for header in headers})
    
    print("\n")

for set in data_set:
    curcuma(set)