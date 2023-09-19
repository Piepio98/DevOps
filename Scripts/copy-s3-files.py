import boto3
from boto3 import *
import argparse
import os


class CopyS3FilesConfig:

    def __init__(self):

        parser = argparse.ArgumentParser()
        parser.add_argument('-org_id', '--origin_access_key_id', required=True,
                            help=f"Origin account access key id")
        parser.add_argument('-org_sec', '--origin_secret_access_key', required=True,
                            help=f"Origin account secret access key")
        parser.add_argument('-org_reg', '--origin_region', required=True,
                             help=f"Origin account region")
        parser.add_argument('-org_bucket', '--origin_bucket', required=True,
                            help=f"Origin account S3 bucket name")
        parser.add_argument('-file_key', '--file_key', required=True,
                            help=f"Origin file key with file extension")
        
        parser.add_argument('-dst_id', '--dest_access_key_id', required=True,
                            help=f"Destination account access key id")
        parser.add_argument('-dst_sec', '--dest_secret_access_key', required=True,
                            help=f"Destinatoin account secret access key")
        parser.add_argument('-dst_reg', '--dest_region', required=True,
                            help=f"Destination account region")                  
        parser.add_argument('-dst_bucket', '--dest_bucket', required=True,
                            help=f"Destination account S3 bucket name")
        args = parser.parse_args()

        self.origin_access_key_id = args.origin_access_key_id
        self.origin_secret_access_key = args.origin_secret_access_key
        self.origin_region = args.origin_region
        self.origin_bucket = args.origin_bucket
        self.file_key = args.file_key

        self.dest_access_key_id = args.dest_access_key_id
        self.dest_secret_access_key = args.dest_secret_access_key
        self.dest_region = args.dest_region
        self.dest_bucket = args.dest_bucket


        self.file_name_list = self.file_key.split("/")
        self.file_name = self.file_name_list[-1]
        self.file_path = str('./'+self.file_name)


def setup_s3_session(access_key_id: str, secret_access_key: str, region_name: str, bucket_name: str,):
    try:
        print('Connecting to S3...')
        session = boto3.Session(
          aws_access_key_id = access_key_id,
          aws_secret_access_key = secret_access_key,
          region_name = region_name
        )
        s3_resource = session.resource('s3')
        bucket = s3_resource.Bucket(bucket_name)
        print('Connected.')
        return bucket

    except Exception as e:
        print(f'Error while connecting to S3, error: {e} ')
        exit(1)


def download_file(origin_client: resource('s3').Bucket, file_key: str, file_path: str):
    try:
        print('Downloading file...')
        origin_client.download_file(file_key, file_path)
        print('File downloaded.')

    except Exception as e:
        print(f'Error while downloading file, error: {e} ')
        exit(1)


def upload_file(dest_client: resource('s3').Bucket, file_key: str, file_path: str):
    try:
        print('Uploading file...')
        dest_client.upload_file(file_path, file_key)
        print('File uploaded.')

    except Exception as e:
        print(f'Error while uploading file, error: {e} ')
        exit(1)


def main():
    config = CopyS3FilesConfig()

    origin_client = setup_s3_session(
        config.origin_access_key_id,
        config.origin_secret_access_key,
        config.origin_region,
        config.origin_bucket
    )

    dest_client = setup_s3_session(
        config.dest_access_key_id,
        config.dest_secret_access_key,
        config.dest_region,
        config.dest_bucket
    )

    download_file(origin_client, config.file_key, config.file_path)
    upload_file(dest_client, config.file_key, config.file_path)

    os.remove(config.file_path)


if __name__ == '__main__':
    main()
