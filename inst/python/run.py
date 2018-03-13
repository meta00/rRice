#!/usr/bin/env python3

import os
import sys
import helper
import query
import planttfdb as planttfdb
import click

@click.command()
@click.argument('db', nargs=1)
@click.option('-f', nargs=1, default='dict')
@click.option('-o', nargs=1, type=click.Path())
@click.argument('qfield', nargs=-1)

def main(db, qfield, f, o):
    print(query.query(db, qfield, outputFormat=f, outputFile=o))


if __name__ == "__main__":
    main()