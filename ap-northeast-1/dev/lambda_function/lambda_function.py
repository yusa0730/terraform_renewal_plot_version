import json
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('dev-example-table')

def lambda_handler(event, context):
    headers = {
        'Content-Type': 'application/json'
    }
    try:
        if event['httpMethod'] == 'DELETE':
            id = event['pathParameters']['id']
            table.delete_item(
                Key={
                    'id': id
                }
            )
            body = f'Deleted item {id}'
            statusCode = 200

        elif event['httpMethod'] == 'GET':
            if 'pathParameters' in event and event['pathParameters'] is not None and 'id' in event['pathParameters']:
                id = event['pathParameters']['id']
                response = table.get_item(
                    Key={
                        'id': id
                    }
                )
                body = response['Item']
                statusCode = 200
            else:
                response = table.scan()
                body = response['Items']
                statusCode = 200

        elif event['httpMethod'] == 'PUT':
            requestJSON = json.loads(event['body'])
            table.put_item(
                Item={
                    'id': requestJSON['id'],
                    'FirstName': requestJSON['FirstName'],
                    'LastName': requestJSON['LastName']
                }
            )
            body = f'Put item {requestJSON["id"]}'
            statusCode = 200

        else:
            body = 'Unsupported method'
            statusCode = 400

    except ClientError as e:
        body = e.response['Error']['Message']
        statusCode = 400

    return {
        'statusCode': statusCode,
        'body': json.dumps(body),
        'headers': headers
    }