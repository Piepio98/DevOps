import boto3
import os

AWS_REGION = os.environ['AWS_REGION']
INSTANCE_ID = os.environ['INSTANCE_ID']

ec2 = boto3.client('ec2', region_name=AWS_REGION)

def lambda_handler(event, context):

    response = ec2.stop_instances(
        InstanceIds=[INSTANCE_ID]
    )
    print('EC2 instance with ID {} was stopped. Response: {}'.format(INSTANCE_ID, response))