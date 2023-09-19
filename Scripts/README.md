# Scripts
This folder contains python and bash scripts that perform different useful actions.


## copy-s3-files

This script allows user to copy files from origin s3 buckets to another s3 buckets, even located in different AWS accounts. Useful for example for archiving unused database dumps or moving them from production environment to test environment for anonymization processes. To execute it you need to provide several arguments:
* `org_id` is origin AWS account access key id for a service account with permissions to specific S3 buckets
* `org_sec` is origin AWS account secret access key for a service account with permissions to specific S3 buckets
* `org_reg` is region of origin AWS account where S3 bucket is located
* `org_bucket` is a name of origin bucket
* `file_key` is origin file key with file extension 

* `dst_id` is destination AWS account access key id for a service account with permissions to specific S3 buckets
* `dst_sec` is destination AWS account secret access key for a service account with permissions to specific S3 buckets
* `dst_reg` is region of destination AWS account where S3 bucket is located
* `dst_bucket` is a name of destination bucket

Below shown is a sample usage:

```python ./copy-s3-files.py -org_id=AKIAxxxxxxx -org_sec=abcdef123456 -org_reg=eu-central-1 -org_bucket=your-bucket-name -file_key=YourFolder/your-file.txt -dst_id=AKIAxxxxxxx -dst_sec=abcdef123456 -dst_reg=eu-central-1 -dst_bucket=your-bucket-name```
