import boto3
from fastapi import FastAPI
from typing import List
from pymongo import MongoClient
import certifi
import json

app = FastAPI()

# Create a Secrets Manager client
session = boto3.session.Session()
client = session.client(
    service_name='secretsmanager',
    region_name='us-east-2'  # specify your AWS region
)

# Replace 'your_secret_name' with the name of the secret in AWS Secrets Manager
get_secret_value_response = client.get_secret_value(SecretId='docdb_secret')
credentials = json.loads(get_secret_value_response['SecretString'])

# Extract the username and password
username = credentials['username']
password = credentials['password']

# You would need to replace 'your-cluster-endpoint' with your DocumentDB Cluster Endpoint.
mongo_uri = f"mongodb://{username}:{password}@your-cluster-endpoint:27017/?ssl=true&ssl_ca_certs=/etc/ssl/certs/rds-combined-ca-bundle.pem"
mongo_client = MongoClient(mongo_uri)

db = mongo_client.your_database # Use your database here
collection = db.your_collection # Use your collection here

@app.get("/movies")
def read_movies(year: int = None, name: str = None, cast_member: str = None, genre: str = None):
    query = {}
    if year:
        query['year'] = year
    if name:
        query['name'] = name
    if cast_member:
        query['cast_members'] = cast_member
    if genre:
        query['genre'] = genre

    movies = list(collection.find(query))

    # Clear _id field which is not serializable in HTTP responses
    for movie in movies:
        movie.pop("_id", None)

    return {"movies": movies}
