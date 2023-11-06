import json

def lambda_handler(event, context):
    for record in event['Records']:
        print(record)
        if record['eventName'] == 'MODIFY' or record['eventName'] == 'REMOVE':
            dynamodb = record['dynamodb']
            new_image = dynamodb.get('NewImage', {})
            old_image = dynamodb.get('OldImage', {})
            
            if old_image.get('status') == 'DELETE':
                # Custom logic for handling DELETE events
                # You can access other attributes as needed
                print(f"Processing DELETE event for Item with ID: {old_image.get('id')}")
                
                # Implement your custom logic here

    return {
        'statusCode': 200,
        'body': json.dumps('Lambda function executed successfully')
    }
