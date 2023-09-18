import boto3
from datetime import datetime
from datetime import timedelta
from datetime import date
import io



def replace_text(v_filenm,v_new_filenm,v_search_text,v_replace_text):
    with open(v_filenm, 'r') as file:
        data = file.read()
        data = data.replace(v_search_text, v_replace_text)

    with open(v_new_filenm, 'w') as file:
        file.write(data)    
    
    return True


def read_file_from_s3(s3_bucket,obj_key):
    client = boto3.client('s3')
    bytes_buffer = io.BytesIO()
    client.download_fileobj(Bucket=s3_bucket, Key=obj_key, Fileobj=bytes_buffer)
    byte_value = bytes_buffer.getvalue()
    str_value = byte_value.decode() #python3, default decoding is utf-8

    return str_value



