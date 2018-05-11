
# coding: utf-8

# In[1]:


import sys
sys.path.append('inst/python')
import helper
import query
import csv


# In[2]:


path = 'inst/python/data/'
set = ['G1_clustered_genes_annotations.tab','G2_clustered_genes_annotations.tab','G5_clustered_genes_annotations.tab','G6_clustered_genes_annotations.tab']
filtered_set = []
for data in set:
    gene_list = []
    with open(path + data, newline='') as input_file:
        dictReader = csv.DictReader(input_file, delimiter = "\t")
        for line in dictReader:
            gene_list.append(line)
    filtered_list = list(filter(lambda gene: 750<int(gene['#gene'].split('_')[3]), gene_list))
    print('%d: removed %d genes which length < 750 from %d genes' % (len(filtered_list), len(gene_list)-len(filtered_list), len(gene_list)))
    filtered_set.append(filtered_list)

# In[3]:




# In[4]:


for i in range(3):
    if not os.path.exists(path+'filtered/'):
        os.makedirs(path+'filtered/')
    with open(path+'filtered/'+set[i], 'w',newline = '') as filtered:
        dictWriter = csv.DictWriter(filtered, delimiter = '\t', fieldnames=filtered_set[i][0].keys())
        dictWriter.writeheader()
        dictWriter.writerows(filtered_set[i])

