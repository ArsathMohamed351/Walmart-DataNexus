import importlib
pd = importlib.import_module("pandas")
import os

mysql_connector = importlib.import_module("mysql.connector")

# -----------------------------
# MySQL Connection
# -----------------------------

connection = mysql_connector.connect(
    host="127.0.0.1",
    port=3306,
    user="root",
    password="root",
    database="walmart_db"
)

# -----------------------------
# Tables to Extract
# -----------------------------

tables = [
    "customers",
    "stores",
    "products",
    "employees",
    "orders",
    "order_items"
]

# Create output directory
os.makedirs("mysql_exports", exist_ok=True)

# -----------------------------
# Extract Each Table
# -----------------------------

for table in tables:

    print(f"Extracting: {table}")

    query = f"""
    SELECT *
    FROM `{table}`
    """

    df = pd.read_sql(query, connection)

    print(f"Rows extracted: {len(df)}")

    # Save as Parquet
    output_file = f"mysql_exports/{table}.parquet"

    df.to_parquet(
        output_file,
        index=False
    )

    print(f"Saved: {output_file}")
    print("-" * 40)

connection.close()

print("All tables exported successfully!")