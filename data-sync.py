import boto3
import json
import os
from pymongo import MongoClient

def lambda_handler(event, context):
    s3 = boto3.client('s3')

    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    response = s3.get_object(Bucket=bucket, Key=key)
    file_content = response['Body'].read().decode('utf-8')

    data = json.loads(file_content)

    secret_name = os.environ['SECRET_NAME']
    endpoint_url = os.environ['ENDPOINT_URL']

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=session.region_name
    )
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    secret = get_secret_value_response['SecretString']

    username = json.loads(secret)['username']
    password = json.loads(secret)['password']

    client = MongoClient(f'mongodb://{username}:{password}@{endpoint_url}:27017')
    db = client['yourDatabaseName']  # Set your database name
    collection = db['yourCollectionName']  # Set your collection name

    collection.delete_many({})  # Clear out existing data
    collection.insert_one(data)  # Insert new data into DocumentDB
