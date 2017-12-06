#!/usr/bin/env python3

import query

print("Oryzabase Query: ")
for iter in query.query("oryzabase", ["Os03g0149100"]):
    print(iter)
print("\nRapDB Query")
for iter in query.query("rapdb", ["Os01g0102700"]):
    print(iter)
print("\nGramene Query")
for iter in query.query("Gramene", ["Os03g0149100"]):
    print(iter)
print("\nic4r Query")
for iter in query.query("ic4r", ["Os03g0149100"]):
    print(iter)
print("\nplntfdb Query")
for iter in query.query("plntfdb", ["321718"]):
    print(iter)
print("\nSNP-Seek Query")
for iter in query.query("snpseek", ["chr01", "1", "43270923", "rap"]):
    print(iter)
print("\nfunricegene Query")
for iter in query.query("funricegene_genekeywords", ["","LOC_Os07g39750"]):
    print(iter)
print("\nfunricegene Query")
for iter in query.query("funricegene_geneinfo", ["","LOC_Os07g39750"]):
    print(iter)
print("\nfunricegene Query")
for iter in query.query("funricegene_faminfo", ["","LOC_Os07g39750"]):
    print(iter)
print("\nMSU Query")
for iter in query.query("msu", ["LOC_Os10g01006"]):
    print(iter)