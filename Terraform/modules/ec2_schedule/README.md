# EC2 schedule
This folder contains terraform module consisting of 2 EventBridge schedulers as well as 2 Lambda functions responsible for turning EC2 instances on and off on a given schedule. All of the required IAM permissions are also given, so needed roles can be assumed. This folder also includes easy python scripts that perform the on/off switching using boto3 library.
Every lambda execution is logged in CloudWatch.


