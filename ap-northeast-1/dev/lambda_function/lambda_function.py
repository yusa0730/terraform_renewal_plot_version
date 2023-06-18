import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table_name = "dev-example-table"
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    operation = event['httpMethod']

    if operation == 'GET':
        return get_item(event)
    elif operation == 'PUT':
        return put_item(event)
    elif operation == 'POST':
        return update_item(event)
    elif operation == 'DELETE':
        return delete_item(event)
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Unsupported operation')
        }

def get_item(event):
    try:
        result = table.get_item(
            Key={
                'id': event['queryStringParameters']['id']
            }
        )
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error getting item: {str(e)}')
        }
    else:
        item = result.get('Item')
        if item:
            return {
                'statusCode': 200,
                'body': json.dumps(item)
            }
        else:
            return {
                'statusCode': 404,
                'body': json.dumps('Item not found')
            }