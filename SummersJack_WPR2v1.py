from csv import DictReader
from mysql.connector import connect

# Set the root password for your local MySQL server here. When you turn in your
# file, make sure you set it back to '<PASSWORD>'!
PASSWORD = 'Js#424242'

# Create a connection to the database
cnx = connect(user='root', password=PASSWORD, database='wpr2v1')
cursor = cnx.cursor()

# Clear the existing records
cursor.execute('DELETE FROM registration;')
cursor.execute('DELETE FROM conference;')
cursor.execute('DELETE FROM attendee;')
cnx.commit()

# Here's the insertion command we will run for each record
INSERT = '''INSERT INTO attendee (emailAddress, lastName, firstName, creditCard)
VALUES (%(email)s, %(name_last)s, %(name_first)s, %(cardnum)s)'''

# Read the CSV file into a list of records (dictionaries)
CSV = 'recordsv1.csv'
with open(CSV) as f:
    records = DictReader(f)
    for record in records: # Loop through the records
       
        #### YOUR CODE HERE ####

        # 1. Split the "name" field in the record into two pieces (first and
        #    last names). Save each part of the name back into the record 
        #    with a new field name.
        #    record['name_first'] = ????
        #    record['name_last'] = ????
        temp = record['name'].split(" ")
        record['name_first'] = temp[0]
        record['name_last'] = temp[1]
    
        # 2. If the credit card info is blank (an empty string), change it to
        #    None so that the value in MySQL will be NULL.
        #    record['cardnum'] = ????
        if record['cardnum'] == "":
            record['cardnum'] = None

        # Run the SQL command with the given record
        cursor.execute(INSERT, record)

cnx.commit() # Finalize the transaction

### CHECKS ###
fail = False

cursor.execute('SELECT * FROM attendee;')
results = cursor.fetchall()
if len(results) == 0:
    print('Failed insertion check; found no records!')
    fail = True

cursor.execute('SELECT * FROM attendee WHERE firstName IS NULL;')
results = cursor.fetchall()
if len(results) > 0:
    print('Failed name check; found record with no first name!')
    print('   ' + str(results[0]))
    fail = True

cursor.execute('SELECT * FROM attendee WHERE creditCard = "";')
results = cursor.fetchall()
if len(results) > 0:
    print('Failed card check; found record with empty string credit card!')
    print('   ' + str(results[0]))
    fail = True

cnx.close()  # Close the connection

if not fail:
    print("Checks pass")