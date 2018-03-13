import helper
from bs4 import BeautifulSoup

def get_header(db, test_id):

    dict = {}
    #database descriptor querry
    database_descriptor = BeautifulSoup(open("database-description.xml").read(), "xml").findAll("database",{"type":"text/html","dbname":db})
    if not database_descriptor:
        raise ValueError('Database Not Found')
    for database in database_descriptor:
        if database["method"]=="POST":
            link = database.findAll("link")[0]["stern"]
            data = {'rapId': test_id}
            res = helper.connectionErrorPost(link, data)
        elif database["method"]=="GET":
            link = database.findAll("link")[0]["stern"] + test_id + database.findAll("link")[0]["aft"]
            res = helper.connectionError(link)
        
        # Headers declaration
        headers = []
        for header in database.findAll("header"):
            headers.append(header.text)

        # Connection handling
        ret = BeautifulSoup(res.content, "lxml")
        data = ret.findAll(database.findAll("data_struct")[0]["indicator"], {database.findAll("data_struct")[0]["identifier"] : database.findAll("data_struct")[0]["identification_string"]})[0]
        # Header detection
        for header in data.findAll('th'):
            header = header.text.replace('\r', '')
            header = header.replace('\n', '')
            header = header.replace('\t', '')
            headers.append(header)
        dict[database["dbname"]]=headers

    return dict

for header in get_header("plntfdb", '321718')["plntfdb"]:
    print('<header type="">'+header+'</header>')