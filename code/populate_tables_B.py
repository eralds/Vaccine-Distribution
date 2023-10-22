'''
Part of project for CS-A1155 - Databases for Data Science
Benjamin Herman, Quoc Quang Ngo, Thinh Nguyen, Erald Shahinas
'''

import os
import json
import re
import pandas as pd
from sqlalchemy import create_engine, text

'''
Note: the following copyright applies only to the function: 
run_sql_from_file(sql_file, psql_conn).
Portions of the code have been modified slightly from the original.

---------------------------------------------------------------------
Reading & Querying Data sets using dataframes
Revised JAN '21
Sami El-Mahgary /Aalto University
Copyright (c) <2021> <Sami El-Mahgary>
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
--------------------------------------------------------------------
'''


def run_sql_from_file(sql_file, psql_conn):
    '''
	read a SQL file with multiple stmts and process it
	adapted from an idea by JF Santos
	Note: not really needed when using dataframes.
    '''
    sql_command = ''
    ret_ = True
    for line in sql_file:
        # if line.startswith('VALUES'):
        # Ignore commented lines
        if not line.startswith('--') and line.strip('\n'):
            # Append line to the command string, prefix with space
            sql_command += ' ' + line.strip('\n')
            # sql_command = ' ' + sql_command + line.strip('\n')
        # If the command string ends with ';', it is a full statement
        if sql_command.endswith(';'):
            # Try to execute statement and commit it
            try:
                # print("running " + sql_command+".")
                psql_conn.execute(text(sql_command))
                # psql_conn.commit()
                # Assert in case of error
            except:
                print('Error at command:' + sql_command + ".")
                # ret_ = False # This statement does nothing since
                # there is the statement ret_ = True in the finally part

                # Finally, clear command string
            finally:
                sql_command = ''
                ret_ = True
    return ret_


'''
Copyrighted material ends here.
'''

# cred_file = 'credentials_local.json'
cred_file = 'credentials.json'
# use 'credentials.json' to connect to the remote database

# Load a dictionary of credentials
with open(cred_file) as fp:
    creds = json.load(fp)

db_url = 'postgresql+psycopg2://' + \
         '{user}:{password}@{host}/{database}?port={port}'. \
             format(**creds)

r = re.compile('.*-.*-.*')
engine = create_engine(db_url)
with engine.connect() as psql_conn:
    with open('project_create_tables_script.sql') as fp:
        run_sql_from_file(fp, psql_conn)

    data_path = os.path.join('..', 'data', 'vaccine-distribution-data.xlsx')

    df = pd.read_excel(data_path, 'VaccineType')
    df.rename({'ID': 'id', 'tempMin': 'tempmin',
               'tempMax': 'tempmax'}, axis=1, inplace=True)
    df.to_sql('vaccinetype', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'Manufacturer')
    df.rename({'ID': 'id', 'vaccine': 'vaccineid'}, axis=1, inplace=True)
    df.to_sql('manufacturer', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'VaccinationStations')
    df.to_sql('vaccinationstations', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'StaffMembers')
    df.rename({'social security number': 'ssno', 'date of birth': 'dateofbirth',
               'vaccination status': 'vaccinationstatus'
               }, axis=1, inplace=True)
    df['vaccinationstatus'] = df.vaccinationstatus.astype(pd.BooleanDtype())
    df.to_sql('staffmembers', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'VaccineBatch')
    df.rename({'batchID': 'batchid', 'amount': 'numvaccines',
               'type': 'vaccineid', 'manufDate': 'dateproduced',
               'expiration': 'expirationdate'}, axis=1, inplace=True)
    df.to_sql('vaccinebatch', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'Transportation log')
    df.rename({'batchID': 'batchid', 'arrival': 'arrivaldestination',
               'departure ': 'departuredestination',
               'dateArr': 'arrivaldate', 'dateDep': 'departuredate',
               }, axis=1, inplace=True)
    df.to_sql('transportationlog', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'Shifts')
    df.to_sql('shifts', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'Vaccinations')
    df.rename({'date': 'vaccinationdate', 'batchID': 'batchid',
               'location ': 'location'}, axis=1, inplace=True)
    df.to_sql('vaccinations', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'Patients')
    df.rename({'ssNo': 'ssno', 'date of birth': 'dateofbirth'},
              axis=1, inplace=True)
    df.to_sql('patients', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'VaccinePatients')
    df.rename({'date': 'vaccinationdate', 'patientSsNo': 'patientssno'},
              axis=1, inplace=True)
    df.to_sql('vaccinepatients', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'Symptoms')
    df['criticality'] = df.criticality.astype(pd.BooleanDtype())
    df.to_sql('symptoms', psql_conn, if_exists='append', index=False)

    df = pd.read_excel(data_path, 'Diagnosis')
    for index, value in df['date'].items():
        try:
            datetime_value = pd.to_datetime(value, format='%Y-%m-%d')
            df.loc[index, 'date'] = datetime_value.strftime('%Y-%m-%d')
        except Exception:
            if len(str(value)) == 5:
                converted_date = pd.to_datetime(int(value), origin='1899-12-30', unit='D').strftime('%Y-%m-%d')
                df.loc[index, 'date'] = converted_date
            elif r.match(value) is not None:
                x = value.split("-")
                if int(x[1]) < 12:
                    new_month = int(x[1]) + 1
                    x[1] = str("{:02d}".format(new_month))
                else:
                    new_year = int(x[0]) + 1
                    x[0] = str(new_year)
                    x[1] = "01"
                x[2] = "01"
                value = '-'.join(x)
                df.loc[index, 'date'] = value
    df.rename({'date': 'reportdate'}, axis=1, inplace=True)
    df.to_sql('diagnosis', psql_conn, if_exists='replace', index=False)
    psql_conn.commit()
