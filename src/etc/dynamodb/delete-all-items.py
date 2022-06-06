from time import sleep
import boto3
import botocore

TABLE = "Person"
ID    = "PK"
RK    = "RK"

table = boto3.resource('dynamodb').Table(TABLE)
stop = False
count = 0
  
while not stop:
    scan = table.scan()
    with table.batch_writer() as batch:
        
        try:
            for item in scan['Items']:
                # print("Item ", item)
                if count % 500 == 0:
                    print(count)
                # print("Item ", item)
                key = {ID: item[ID], RK: item[RK]}
                
                batch.delete_item(Key = key)
                
                count = count + 1
            
        except Exception as e:
            print(e)
            stop = True
        
        print("Sleep")
        sleep(20)
