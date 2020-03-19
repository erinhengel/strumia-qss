# -*- coding: utf-8 -*-

import json
import csv
import sys
import sqlite3
import os
from pprint import pprint

csv.field_size_limit(sys.maxsize)

# Open database connection and read in schema.sql file
conn = sqlite3.connect('data/strumia.db')
cursor = conn.cursor()
with open('data/schema.sql', 'r') as sql:
    cursor.executescript(sql.read())

# List of integers.
def toIntList(string):
    string = string.strip('{}').split(',')
    if string != ['']:
        return [int(x) for x in string]
    else:
        return []

# Convert to boolean.
def toBoolean(string):
    if string == 'True':
        return True
    elif string == 'False':
        return False
    else:
        return None

# Return sex.
def getSex(string):
    if string=='F':
        return 'Female'
    elif string=='M':
        return 'Male'
    else:
        return None

# Import InSpire database.
n = 0
with open('data/InSpireData.dat', encoding="ISO-8859-1") as csv_file:
    csv_reader = csv.reader(csv_file, delimiter='\t')
    for line in csv_reader:
        try:
            record = {
                'ArticleID': int(line[0]),
                'PubDate': float(line[1]),
                'arXivDate': float(line[2]),
                'AuthorN': int(line[3]),
                'RefN': int(line[4]),
                'Cite': int(line[5]),
                'PageRank': float(line[6]),
                'PageRankNoSelf': float(line[7]),
                'AuthorIDs': toIntList(line[8]),
                'RefIDs': toIntList(line[9]),
                'CiteIDs': toIntList(line[10]),
                'Title': line[11],
                'MainCat': line[12],
                'Published': toBoolean(line[13]),
                'Affiliations': line[14],
                'SubCat': line[15],
                'arXivID': line[16],
                'Journal': toIntList(line[17]),
                'Collaborations': toIntList(line[18]),
                'iCite': float(line[19])
            }

            # Insert article record.
            insert_query = "INSERT INTO Article (ArticleID, arXivID, PubDate, Title, arXivDate, AuthorN, RefN, Cite, PageRank, PageRankNoSelf, iCite) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
            cursor.execute(insert_query, (record['ArticleID'], record['arXivID'], record['PubDate'], record['Title'], record['arXivDate'], record['AuthorN'], record['RefN'], record['Cite'], record['PageRank'], record['PageRankNoSelf'], record['iCite']))

            # Insert authors.
            for author in record['AuthorIDs']:
                insert_query = "INSERT INTO AuthorCorr (ArticleID, AuthorID) VALUES (?, ?);"
                cursor.execute(insert_query, (record['ArticleID'], author))

            # Insert journals.
            for journal in record['Journal']:
                insert_query = "INSERT INTO JournalCorr (ArticleID, JournalID) VALUES (?, ?);"
                try:
                    cursor.execute(insert_query, (record['ArticleID'], journal))
                except sqlite3.IntegrityError:
                    pass

        # Count number of observations that generate errors.
        except (IndexError, ValueError):
            n += 1
print("Dropped {} observations due to index or value errors.".format(n))

# Import author data.
os.system('wolframscript -code \'ToExpression@Import["data/AuthorsMap.mx"];Export["data/author.csv", Flatten[{#[[1]], StringTrim[#[[2]]], #[[3]], #[[4]]}] & /@ AuthorsMap[[2 ;;, {1, 4, 6, 14}]], "CSV"];\'')
with open('data/author.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    for line in csv_reader:
        author = {
            'AuthorID': int(line[0]),
            'Name': line[1],
            'Country': line[2],
            'LeftHEP': line[3]
        }

        # Insert author.
        insert_query = "INSERT INTO Author (AuthorID, Name, Country, LeftHEP) VALUES (?, ?, ?, ?);"
        cursor.execute(insert_query, (author['AuthorID'], author['Name'], author['Country'], author['LeftHEP']))
os.remove('data/author.csv')

# Import alias data.
os.system('wolframscript -code \'ToExpression@Import["data/AuthorsMap.mx"];Export["data/alias.csv", Flatten[Thread[List[#[[1]], #[[2]]]] & /@ AuthorsMap[[2 ;;, {1, 3}]], 1], "CSV"];\'')
with open('data/alias.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    for line in csv_reader:
        alias = {
            'AuthorID': int(line[0]),
            'Alias': line[1]
        }

        # Insert alias.
        insert_query = "INSERT INTO Alias (AuthorID, Alias) VALUES (?, ?);"
        cursor.execute(insert_query, (alias['AuthorID'], alias['Alias']))
os.remove('data/alias.csv')

# Import author gender.
os.system('wolframscript -code \'Export["data/gender.csv", ReleaseHold[NotebookImport["data/AuthorID2Gender.nb", "Input"]][[1]], "CSV"];\'')
with open('data/gender.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    for line in csv_reader:
        author = {
            'AuthorID': int(line[0]),
            'Gender': getSex(line[1])
        }

        # Insert author.
        insert_query = "UPDATE Author SET Gender = ? WHERE AuthorID = ?;"
        cursor.execute(insert_query, (author['Gender'], author['AuthorID']))
os.remove('data/gender.csv')

# Update with changes.
with open('data/update.sql', 'r') as sql:
    cursor.executescript(sql.read())

# Commit changes and end.
conn.commit()
