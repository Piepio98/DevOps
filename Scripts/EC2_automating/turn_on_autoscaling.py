import boto3
import os

AWS_REGION = os.environ['AWS_REGION']
TAG_VALUE = os.environ['TAG_VALUE']

asg = boto3.client('autoscaling', region_name=AWS_REGION)

def lambda_handler(event, context):

    response = asg.resume_processes(
        AutoScalingGroupName=ASG,
        ScalingProcesses=[
            'ReplaceUnhealthy',
        ]
    )
    print('AutoScaling group was modified. ReplaceUnhealthy parameter was enabled. Response: ' + str(response))