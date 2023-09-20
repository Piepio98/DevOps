import boto3
import os

AWS_REGION = os.environ['AWS_REGION']
INSTANCE_ID = os.environ['INSTANCE_ID']

ec2 = boto3.client('ec2', region_name=AWS_REGION)

def lambda_handler(event, context):

    response = ec2.start_instances(
        InstanceIds=[INSTANCE_ID]
    )
    print('EC2 instance with ID {} was started. Response: {}'.format(INSTANCE_ID, response))