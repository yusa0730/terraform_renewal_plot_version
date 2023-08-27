## aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
## docker build -t push_notification_batch_ecr .
## docker tag push_notification_batch_ecr:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/push_notification_batch_ecr:latest
## docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/push_notification_batch_ecr:latest
FROM python:3.10-slim

WORKDIR /app

COPY test.py /app

CMD ["python", "test.py"]