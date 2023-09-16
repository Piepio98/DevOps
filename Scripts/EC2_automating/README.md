# EC2 automating
### This section shows how to automate turning off and on EC2 instances that are located in an autoscaling group.

Turning off standalone EC2 instances is relatively easy. The problem occures when EC2 instances are within an Autoscaling Group. The issue with turning off EC2 instances within ASG is that it will automatically trigger ASG, which will terminate turned off instances and create new ones.

Overall flow of actions is as follows:
1. First lambda function executes `turn_off_autoscaling` script. It disables Autoscaling to replace the instances that will be shortly turned off. 
2. Then shortly after, the `turn_off_ec2_instances` script is executed in another lambda function. It turns off all EC2 instances within an ASG. 
3. After some time declared in EventBridge Scheduler (for example after weekend) the `turn_on_autoscaling` script is executed in a third lambda. Autoscaling then automatically replaces the instances that have "turned off" state and creates new ones (which have a different ID).

### Used environment variables in all folowing scripts:
AWS_REGION - region in which EC2 instances are located (for example eu-west-1)

TAG_VALUE - name of the autoscaling group

## turn_off_ec2_instances

This script is used in AWS Lambda function to turn off all EC2 instances that are located inside an autoscaling group. In combination with AWS EventBridge scheduler it can automatically turn off EC2 instances on desired times (for example on weekends) to save costs.

Important note is that *prior* doing this, another lambda function is needed. It will be described in `turn_off_autoscaling` section.

## turn_off_autoscaling

This script as well as the previous one is used in AWS Lambda function. It disables a crucial parameter in ASG called ReplaceUnhealthy. With this parameter turned on, ASG automatically replaces unhealthy (turned off is also inretpreted as unhealthy) instances.

## turn_on_autoscaling

This script is also used in AWS Lambda function. It enables the ReplaceUnhealthy parameter, so the Autoscaling group can automatically replace the turned off instances and create new ones.




