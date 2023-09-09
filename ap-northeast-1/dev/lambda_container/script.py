import json

def lambda_handler(event, context):
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "body": json.dumps({
            "A": "hoge",
            "B": "fuga",
            "C": "piyo"
        })
    }