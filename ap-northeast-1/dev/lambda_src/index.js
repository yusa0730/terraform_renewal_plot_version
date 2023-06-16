const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  let response = {};
  let statusCode = 200;

  try {
    const httpMethod = event.httpMethod;
    const params = {
      TableName: 'dev-example-table',
    };
    if (httpMethod === 'GET' && !event.id) {
      const result = await dynamoDB.scan(params).promise();
      response = result;
    } else if (httpMethod === 'GET') {
      const id = event.id;
      params.Key = {
        'id': id
      };

      const result = await dynamoDB.get(params).promise();
      console.log(result);
      response = result;
    } else if (httpMethod === 'POST') {
      const id = event.id;
      const FirstName = event.FirstName;
      const LastName = event.LastName;
      params.Item = {
        'id': id,
        'FirstName': FirstName,
        'LastName': LastName,
      };
      params.ConditionExpression ='attribute_not_exists(id)';
      console.log(params);

      await dynamoDB.put(params).promise();
      statusCode = 201;
      response = params;
    } else if (httpMethod == 'DELETE') {
      const id = event.id;
      params.Key = {
        'id': id
      }

      await dynamoDB.delete(params).promise();
      statusCode = 204;
      response = params;
    } else {
      statusCode = 400;
      response = { message: 'Bad Request' };
    }

    const lambdaResponse = {
      statusCode: statusCode,
      headers: {
        'Content-Type': 'application/json'
      },
      result: response
    }
    return lambdaResponse;
  } catch (err) {
    statusCode = 500;
    response = { message: 'Internal Server Error' };
    console.error(err);
  }
};