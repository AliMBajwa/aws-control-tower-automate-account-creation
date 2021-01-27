import boto3
import json
import logging
import os

def check_existing_user(accountName, table):
    resp = table.get_item(
            Key={
                'AccountName' : accountName
            }

        )

    if 'Item' in resp:
        return True
    else:
        return False
    

def lambda_handler(event, context):

    LOGGER = logging.getLogger()
    LOGGER.setLevel(logging.INFO)
    
    table_name = os.environ.get("TABLE_NAME")
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    LOGGER.info(event)
    body = json.loads(event['body'])
    LOGGER.info(body)
    
    if 'email' in body:
        email = body['email']
        fname = body['fname']
        lname = body['lname']
        accountName = fname+lname
    else:
        LOGGER.info('recieved incorrect parameters from Gateway API')
        return
    
    if check_existing_user(accountName, table) == False:
        new_item = {
            'AccountName': accountName,
            'SSOUserEmail': email,
            'AccountEmail': email,
            'SSOUserFirstName': fname,
            'SSOUserLastName': lname,
            'OrgUnit': 'Custom',
            'Status': 'VALID',
            'AccountId': '',
            'Message': ''
        }
        
        table.put_item(Item=new_item)
        LOGGER.info('added user: '+ email)
        
    else:
        LOGGER.info('A request was made by a user that already exists in the database.')
        
    message = {
        'message': 'Execution started successfully!'
    }
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json','Access-Control-Allow-Origin':'*','Access-Control-Allow-Credentials': 'true'},
        'body': json.dumps(message)
    }
