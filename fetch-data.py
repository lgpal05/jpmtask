import requests
import json
import boto3

class DepthLimitDecoder(json.JSONDecoder):
    def __init__(self, *args, **kwargs):
        self.max_depth = kwargs.pop('max_depth', None)
        super(DepthLimitDecoder, self).__init__(*args, **kwargs)

    def raw_decode(self, s, idx=0):
        obj, end = super(DepthLimitDecoder, self).raw_decode(s, idx)
        self.check_depth(obj)
        return obj, end

    def check_depth(self, obj, depth=1):
        if depth > self.max_depth:
            raise ValueError(f"Maximum depth of {self.max_depth} exceeded")
        if isinstance(obj, dict):
            for key in obj:
                self.check_depth(obj[key], depth+1)
        elif isinstance(obj, list):
            for item in obj:
                self.check_depth(item, depth+1)

def upload_to_s3(data):
    bucket_name = 'vjvidtest-270523'
    key = 'movie.json'
    s3 = boto3.client('s3')
    s3.put_object(
        Body=data,
        Bucket=bucket_name,
        Key=key
    )
    print(f"Data successfully uploaded to {bucket_name}/{key}")

def fetch_and_validate():
    url = "https://github.com/prust/wikipedia-movie-data/raw/master/movies.json"
    response = requests.get(url)
    max_size = 1000 * 1024 * 1024  # 10 MB
    if len(response.content) > max_size:
        print("The JSON file is too large.")
        return
    try:
        data = json.loads(response.text, cls=DepthLimitDecoder, max_depth=10)
        print("Data validation successful!")
        upload_to_s3(response.content)
    except ValueError as e:
        print(f"Invalid JSON data: {e}")

fetch_and_validate()
