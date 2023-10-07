import sys
import logging
import psycopg2
import json
import os
from datetime import date, timedelta

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
        print("SUCCESS: Connection to RDS for Postgres instance succeeded")
        # create a cursor
        cur = conn.cursor()
        
	# execute a statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')

        # display the PostgreSQL database server version
        db_version = cur.fetchone()
        print(db_version)
       
	# close the cursor
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    #finally:
    #    if conn is not None:
    #        conn.close()
    #        print('Database connection closed.')
    return conn


def main():
    """
    This function creates a new RDS database table and writes records to it
    """
    
    item_count = 0
    sql_string = "select jobstatus,lastexecutiondate from jobcontrol where jobname = 'JOB1' order by lastexecutiondate desc limit 1"
    conn = connect()

    with conn.cursor() as cur:
        cur.execute(sql_string)
        json_data_idlist = []
        json_data_namelist = []
        jobstatus =  None
        lastexecutiondate = None
        for (jobstatus,lastexecutiondate) in cur:
            #json_data_idlist.append(jobstatus)
            jobstatus = jobstatus
            lastexecutiondate = lastexecutiondate
            #json_data_namelist.append(lastexecutiondate)
            

    conn.commit()
    cur.close()
    #print(jobstatus)
    #print(lastexecutiondate)

    start_date = lastexecutiondate
    CURR_DATE = date.today()  # date formatted as a string

    delta = CURR_DATE - start_date   # returns timedelta

    for i in range(delta.days + 1):
        day = start_date + timedelta(days=i)
        print(day)

    #print(json.dumps(json_data_idlist))
    #print(json.dumps(json_data_namelist))



if __name__ == "__main__":
    main()