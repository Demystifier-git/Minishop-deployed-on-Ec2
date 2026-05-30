import boto3
import json
import mysql.connector

# ---- CONFIG ----
SECRET_NAME = "prod/minishop/app"
REGION_NAME = "us-east-1"

# ---- CONNECT TO SECRETS MANAGER ----
client = boto3.client("secretsmanager", region_name=REGION_NAME)

try:
    # Fetch secret from AWS
    response = client.get_secret_value(SecretId=SECRET_NAME)

    # Parse JSON secret
    secret = json.loads(response["SecretString"])

    DB_HOST = secret["host"]
    DB_USER = secret["username"]
    DB_PASSWORD = secret["password"]
    DB_NAME = secret["dbname"]

    # ---- CONNECT TO RDS MYSQL ----
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