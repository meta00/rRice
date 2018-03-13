#!/usr/bin/env python3

import importlib
import pip

def install(package):
    pip.main(['install', package])

def test():
    if (importlib.find_loader('pandas') is None) :
        install("pandas")
    if (importlib.find_loader('bs4') is None) :
        install("bs4")
    if (importlib.find_loader('requests') is None) :
        install("requests")
    if (importlib.find_loader('json') is None) :
        install("json")
    if (importlib.find_loader('gzip') is None) :
        install("gzip")
    if (importlib.find_loader('lxml') is None) :
        install("lxml")
    if (importlib.find_loader('click') is None) :
        install("click")
        
def main():
    print("test")


# Pour eviter que le script soit execute lors d'un simple import
if __name__ == "__main__":
    main()
