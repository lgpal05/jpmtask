# jpmtask



**# Apply the configuration using the command --> kubectl apply -f deployment.yaml**

#Apply the service configuration using the command --> kubectl apply -f service.yaml

#build docker image
#docker build -t jpmt_fastapi_image .

#install to AWS ECR CLI
#aws ecr get-login-password --region region | docker login --username AWS --password-stdin your-account-id.dkr.ecr.region.amazonaws.com

#create a Repository in the ECR
#aws ecr create-repository --repository-name your-repository-name --region your-region
#docker tag your_fastapi_image:latest your-account-id.dkr.ecr.your-region.amazonaws.com/your-repository-name:latest
#docker push your-account-id.dkr.ecr.your-region.amazonaws.com/your-repository-name:latest



