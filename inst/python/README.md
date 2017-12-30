# Python query engine for rRice R package

## Function

```py
query(db, qfields=[])
```

Return a array of JSON Object corresponding to the query.

Take 2 argument:

1. db: Database name, any database name that is exist in the database description file. Throw an exception if no db found under the name.
1. qfields: list of argument for said database. The order of these argument follow the order of fields listed in the database description file.

## Structure of Database description

```xml
<database dbname="name of the database" type="Type of the response" method="GET or POST">
    <link stern="the link section before the query" aft="section behind the query"/>
    <headers>
        <header type="">Column number 1</header>
        <header type="">Column number 2</header>
        etc.
    </headers>
    <fields>
        <field>Query argument number 1</field>
    </fields>
    <data_struct indicator="indicator of return data segment" identifier="the attribute to identify data section" identification_string="value of said identifier" line_separator="indicator of a line of data" cell_separator="indicator of a cell of data"/>
    <prettify>Regular expression of unwanted character</prettify>
</database>
```

## Example

### Example of system called query (Oryzabase)

```bash
python "run.py" oryzabase Os03g0149100
```

### Example of query (Oryzabase)

```py
query.query("oryzabase", ["Os03g0149100"])
```

### Example of JSON response (Oryzabase)

```json
{'CGSNL Gene Symbol': 'CRL1', 'Gene symbol synonym(s)': 'crl1 crl1* ARL1 ARL1/CRL1 OsLBD3-2 LBD3-2', 'CGSNL Gene Name': 'CROWN ROOTLESS 1', 'Gene name synonym(s)': 'crown rootless-1 CROWN ROOTLESS1 Crown rootless1 ADVENTITIOUS ROOTLESS1 ADVENTITIOUS ROOTLESS 1 lateral organ boundaries domain 3-2', 'Chr. No.': '3', 'Trait Class': ' Vegetative organ - Root', 'Gene Ontology': 'GO:0009888 - tissue developmentGO:0009887 - organ morphogenesis', 'Trait Ontology': 'TO:0000227 - root lengthTO:0000084 - root number', 'Plant Ontology': 'PO:0009005 - root ', 'RAP ID': 'Os03g0149100Oryzabase(IRGSP 1.0/Build5)Rap(IRGSP 1.0/Build5)', 'Mutant Image': ''}
```

### Example of database description

```xml
<database dbname="oryzabase" type="text/html" method="POST">
    <link stern="https://shigen.nig.ac.jp/rice/oryzabase/gene/advanced/list"/>
    <headers>
        <header type="">CGSNL Gene Symbol</header>
        <header type="">Gene symbol synonym(s)</header>
        <header type="">CGSNL Gene Name</header>
        <header type="">Gene name synonym(s)</header>
        <header type="">Chr. No.</header>
        <header type="">Trait Class</header>
        <header type="">Gene Ontology</header>
        <header type="">Trait Ontology</header>
        <header type="">Plant Ontology</header>
        <header type="">RAP ID</header>
        <header type="">Mutant Image</header>
    </headers>
    <fields>
        <field>rapId</field>
    </fields>
    <data_struct indicator="table" identifier="class" identification_string="table_summery_list table_nowrapTh max_width_element" line_separator="tr" cell_separator="td"/>
    <prettify>\n>LOC_.*\n|\n|\r|\t</prettify>
</database>
```

## List of supported database

* Oryzabase
* RapDB
* Gramene
* ic4r
* plntfdb
* SNP-Seek
* funricegene
* MSU
* RiceNetDb

## List of exception

* Server Exception

    Throw when server response code is not 200.

    Throw with the corresponding server response code.
* Internet Connection Exceptioin

    Throw requests.exceptions.RequestException

    *requests* module exception.
* Timeout Exception

    Throw requests.exceptions.Timeout

    *requests* module exception.
* Database Exception

    Throw when database description is not found.