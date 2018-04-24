#!/usr/bin/env python3

import os
import sys
import query
import click

@click.command()
@click.argument('db', nargs=1)
@click.option('-f', nargs=1, default='dict')
@click.option('-o', nargs=1, type=click.Path())
@click.option('-v','--verbose', is_flag=True)
@click.argument('qfield', nargs=-1)

def main(db, qfield, f, o, verbose):
    print(query.query(db, qfield, outputFormat=f, outputFile=o, verbose=verbose))

if __name__ == "__main__":
    main()