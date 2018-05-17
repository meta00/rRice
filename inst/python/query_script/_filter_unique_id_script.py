
# coding: utf-8

# In[1]:

# Import requirements:
 
import os
import sys
sys.path.append('inst/python')
import helper
import query
import csv
from multiprocessing import Pool
from multiprocessing.dummy import Pool as ThreadPool 


# In[]:

# Configuration:
num_of_thread = 2
path = 'data/filtered/'
# set = ['G1_clustered_genes_annotations.tab','G2_clustered_genes_annotations.tab','G5_clustered_genes_annotations.tab','G6_clustered_genes_annotations.tab']
set = ['G1_clustered_genes_annotations.tab']

# In[2]:

# Support functions:
def get_kegg_id(key):
    try:
       return {'KEGG_id': key, 'Definition':query.query('kegg', [key])[0]['Definition']}
    except:
            print(key)
            return None   

# In[3]:


# Get a list of unique gene
unique_gene_list = []
for data in set:
    with open(path + data, newline='') as input_file:
        dictReader = csv.DictReader(input_file, delimiter = "\t")
        for line in dictReader:
            for kegg_id in line['KEGG_ko'].split('|'):
                if not(kegg_id in unique_gene_list): unique_gene_list.append(kegg_id)
            for kegg_id in line['KEGG_module'].split('|'):
                if not(kegg_id in unique_gene_list): unique_gene_list.append(kegg_id)
            for kegg_id in line['KEGG_pathway'].split('|'):
                if not(kegg_id in unique_gene_list): unique_gene_list.append(kegg_id)


# In[]:


# Query from unique list
# Using multiple (4) threads
pool = ThreadPool(num_of_thread)
unique_return = pool.map(get_kegg_id, unique_gene_list)

# In[4]:


path = 'data/filtered/'
if not os.path.exists(path+'kegg/'):
    os.makedirs(path+'kegg/')
with open(path+'kegg/kegg_raw.tab', 'w',newline = '') as output_file:
    headers = ['KEGG_id', 'Definition']
    dictWriter = csv.DictWriter(output_file, delimiter = '\t')
    dictWriter.writeheader()
    dictWriter.writerows(unique_return)