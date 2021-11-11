import pyodbc
server = 'xxx'
database = 'xxx'
username = 'xxx'
password = 'xxx'
driver= '{ODBC Driver 17 for SQL Server}'
with pyodbc.connect('DRIVER='+driver+';SERVER='+server+';PORT=1433;DATABASE='+database+';UID='+username+';PWD='+ password) as conn:
        with conn.cursor() as cursor:
                cursor.execute("SELECT @@version")
                row = cursor.fetchone()
                while row:
                        print (str(row[0]))
                        row = cursor.fetchone()
