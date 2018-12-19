#!/usr/bin/python2.4
#
import psycopg2
try:
    db = psycopg2.connect("dbname='nextsoftiot' user='next_user' host='10.5.50.226' password='next_pass'")
except:
    exit(1)

exit(0)
