import boto3
import json
import mysql.connector

# ---- CONFIG ----
SECRET_NAME = "prod/minishop/app"
REGION_NAME = "us-east-1"

client = boto3.client("secretsmanager", region_name=REGION_NAME)

try:
    response = client.get_secret_value(SecretId=SECRET_NAME)

    # ✅ FIX: Secrets Manager key/value format returns JSON string of flat keys
    secret = json.loads(response["SecretString"])

    # ✅ USE EXACT KEYS FROM YOUR SECRET MANAGER
    DB_HOST = secret["DB_HOST"]
    DB_USER = secret["DB_USER"]
    DB_PASSWORD = secret["DB_PASSWORD"]
    DB_NAME = secret["DB_NAME"]

    conn = mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )

    cursor = conn.cursor()

    print("✅ Successfully connected to RDS MySQL using Secrets Manager")

except Exception as e:
    raise Exception(f"❌ Connection failed: {e}")