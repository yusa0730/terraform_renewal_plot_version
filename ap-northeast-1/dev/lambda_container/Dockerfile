## Use AWS Lambda Python 3.10 image
FROM public.ecr.aws/lambda/python:3.10

# Install Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Python script
COPY script.py ./

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD ["script.lambda_handler"]
