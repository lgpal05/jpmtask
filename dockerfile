#This is the "builder" stage
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.8 as builder
COPY ./app /app
RUN pip install fastapi uvicorn boto3 pymongo

#This is the final stage, and we copy artifacts from "builder"
FROM gcr.io/distroless/base-debian10
COPY --from=builder /app /app
ENTRYPOINT ["/app"]

#build docker image
#docker build -t jpmt_fastapi_image .

#install to AWS ECR CLI
#aws ecr get-login-password --region region | docker login --username AWS --password-stdin your-account-id.dkr.ecr.region.amazonaws.com

#create a Repository in the ECR
#aws ecr create-repository --repository-name your-repository-name --region your-region
#docker tag your_fastapi_image:latest your-account-id.dkr.ecr.your-region.amazonaws.com/your-repository-name:latest
#docker push your-account-id.dkr.ecr.your-region.amazonaws.com/your-repository-name:latest



