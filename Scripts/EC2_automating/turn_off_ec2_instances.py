import boto3
import os

AWS_REGION = os.environ['AWS_REGION']
TAG_VALUE = os.environ['TAG_VALUE']

ec2 = boto3.client('ec2', region_name=AWS_REGION)

def get_instance_ids_by_tag(tag_key, tag_value):
    ec2_client = boto3.client('ec2')
    response = ec2_client.describe_instances(
        Filters=[
            {
                'Name': f'tag:{tag_key}',
                'Values': [tag_value]
            }
        ]
    )

    ec2_instances = response['Reservations']
    
    if not ec2_instances:
        return None

    instance_ids_list = []

    for instance in ec2_instances:
        instance_id = instance['Instances'][0]['InstanceId']
        instance_ids.append(instance_id)

    return instance_ids_list


def lambda_handler(event, context):
    tag_key = 'aws:autoscaling:groupName'
    tag_value = TAG_VALUE

    instance_ids_list = get_instance_ids_by_tag(tag_key, tag_value)

    if instance_ids_list:
        print(f"Instance IDs for '{tag_key}:{tag_value}': {instance_ids_list}")
        ec2.stop_instances(InstanceIds=instance_ids_list)
        print('Stopped instances: ' + str(instance_ids_list))
    else:
        print(f"No instance found with this tag: '{tag_key}:{tag_value}'")
