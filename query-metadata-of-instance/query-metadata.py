import json
import boto3

client = boto3.client('ec2')
s3 = boto3.client('s3')

def lambda_handler(event, context):
    
    #### To query metadata of all EC2 Instances ####
    ec2metadata=client.describe_instances()
    print(ec2metadata)
    
    #### To retrieve particular data key individually #### (here retrieving the "Instance ID and Instance Type of the EC2 instance") ####
    for data in ec2metadata['Reservations']:
        for key in data['Instances']:
          print(key['InstanceId'])
          print(key['InstanceType'])
    
    #### To query metadata of an S3 bucket object ####
    objectmetadata = s3.head_object(Bucket='test-bucket', Key='test-file.txt')
    print(objectmetadata)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Lambda completed successfully!')
    }
