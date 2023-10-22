"""
Reads a sql script and writes it to another file inserting
the outputs of statements executed in Postgres where marked
in the original script.  Markers are placed as comments
in the original file as
-- %OUTPUT:<format> <label>%
where format can at this time be only 'table'.  label is used
to label the output.  As an example, if the original file has
contents:

<sql statements A>
-- %OUTPUT:table 3.1%
<sql statements B>

the output file will have contents

<sql statements A>
*/ OUTPUT 3.1

<output from last statement in A>
*/
<sql statements B>

Part of project for CS-A1155 - Databases for Data Science
Benjamin Herman, Quoc Quang Ngo, Thinh Nguyen, Erald Shahinas
"""

import re
import json

import psycopg2
import sqlparse
import pandas as pd

input_file = 'part2_queries_1-4.sql'
output_file = 'part2_queries_1-4_out.sql'

# cred_file = 'credentials_local.json'
cred_file = 'credentials.json'
# use 'credentials.json' to connect to the remote database

# Load a dictionary of credentials
with open(cred_file) as fp:
    creds = json.load(fp)

with psycopg2.connect(**creds) as conn, conn.cursor() as cursor:
    with open(input_file) as fp:
        sql = fp.read()

    segments = re.split(
        r'-- *%OUTPUT:([^\s%]*) +([^%]*) *%', sql
    )

    output_segments = list()

    for k in range(len(segments) // 3 + 1):
        code = segments[3*k]
        statement_list = sqlparse.split(code)
        for statement in statement_list:
            try:
                cursor.execute(statement)
            except Exception as e:
                print('Error executing statement:')
                print('')
                print(statement)
                raise e

        output_segments.append(code)
        if 3 * k == len(segments) - 1:
            break

        output_format = segments[3*k + 1]
        tag = segments[3*k + 2]

        out = cursor.fetchall()
        if output_format == 'table':
            column_names = [desc[0] for desc in cursor.description]
            df = pd.DataFrame.from_records(out, columns=column_names)
            output_string = df.to_string()
        else:
            raise Exception('Unrecognized output format')

        output_segments.append('/* OUTPUT %s\n\n' % tag)
        output_segments.append(output_string)
        output_segments.append('\n*/')

with open(output_file, 'w') as fp:
    fp.write(''.join(output_segments))
