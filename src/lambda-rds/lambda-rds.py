import sys
import logging
import psycopg2
import json
import os

# rds settings
#user_name = os.environ['USER_NAME']
#password = os.environ['PASSWORD']
#rds_proxy_host = os.environ['RDS_PROXY_HOST']
#db_name = os.environ['DB_NAME']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def connect():
    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        #params = config()

        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        #conn = psycopg2.connect(**params)
        conn = psycopg2.connect("dbname=postgres user=postgres password=postgres host=localhost port=5432")
        logger.info("SUCCESS: Connection to RDS for Postgres instance succeeded")
        # create a cursor
        cur = conn.cursor()
        
	# execute a statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')

        # display the PostgreSQL database server version
        db_version = cur.fetchone()
        print(db_version)
       
	# close the communication with the PostgreSQL
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    #finally:
    #    if conn is not None:
    #        conn.close()
    #        print('Database connection closed.')
    return conn


def lambda_handler(event, context):
    """
    This function creates a new RDS database table and writes records to it
    """
    message = event['Records'][0]['body']
    data = json.loads(message)
    CustID = data['CustID']
    Name = data['Name']
    #CustID = 3
    #Name   = "Crawlerp"

    item_count = 0
    sql_string = f"insert into Customer (CustID, Name) values({CustID}, '{Name}')"
    conn = connect()

    with conn.cursor() as cur:
        cur.execute("create table if not exists Customer ( CustID  int NOT NULL, Name varchar(255) NOT NULL, PRIMARY KEY (CustID))")
        cur.execute(sql_string)
        conn.commit()
        cur.execute("select * from Customer")
        logger.info("The following items have been added to the database:")
        for row in cur:
            item_count += 1
            logger.info(row)
    conn.commit()

    return "Added %d items to RDS for MySQL table" %(item_count)
