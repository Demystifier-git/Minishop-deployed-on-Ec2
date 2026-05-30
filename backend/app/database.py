import boto3
import json
import mysql.connector

SECRET_NAME = "prod/minishop/app"
REGION_NAME = "us-east-1"

client = boto3.client("secretsmanager", region_name=REGION_NAME)


def get_connection():
    response = client.get_secret_value(SecretId=SECRET_NAME)
    secret = json.loads(response["SecretString"])

    return mysql.connector.connect(
        host=secret["DB_HOST"],
        user=secret["DB_USER"],
        password=secret["DB_PASSWORD"],
        database=secret["DB_NAME"],
    )