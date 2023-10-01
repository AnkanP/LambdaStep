import json
import boto3
import s3module

def lambda_handler(event, context):
    #state_input = event.get("configData")
   # BUCKET = event.get("bucket")
   # OBJ_KEY = event.get("objkey")
    
    #print(s3module.read_file_from_s3(BUCKET,OBJ_KEY))

    output = {
        "partition_sql": "partition",
        "merge_sql":      "merge"
    }


    return output