import mysql.connector
import pandas as pd
import time
import random
import string
from datetime import datetime
from mysql.connector import Error

DB_CONFIG = {
    'host': '52.72.4.132', # Use your RDS Public IP or Endpoint
    'user': 'admin',
    'password': 'root123$',
    'database': 'demodb'
}

TABLE_NAME = 'customers_transactions'
CSV_FILE = './data/customer_data.csv'


def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)


def full_load():
    """Drops the table, creates it, and loads all rows from CSV."""
    print(f"--- Starting Full Load from {CSV_FILE} ---")
    df = pd.read_csv(CSV_FILE)
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute(f"DROP TABLE IF EXISTS {TABLE_NAME}")
        cursor.execute(f"""
            CREATE TABLE {TABLE_NAME} (
                CustomerID INT,
                OrderID INT PRIMARY KEY,
                ProductInformation VARCHAR(100),
                TransactionAmount DECIMAL(10, 2),
                PurchaseDate VARCHAR(50),
                Location VARCHAR(100),
                __last_sync_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        """)
        
        sql = f"""INSERT INTO {TABLE_NAME} 
                  (CustomerID, OrderID, ProductInformation, TransactionAmount, PurchaseDate, Location) 
                  VALUES (%s, %s, %s, %s, %s, %s)"""
        
        data = [tuple(x) for x in df.values]
        cursor.executemany(sql, data)
        
        conn.commit()
        print(f"Successfully loaded {cursor.rowcount} rows.")
        
    except Error as e:
        print(f"Error during Full Load: {e}")
    finally:
        cursor.close()
        conn.close()


def cdc_load(duration_minutes=5):
    """Simulates ongoing Inserts, Updates, and Deletes."""
    print(f"--- Starting CDC Simulation for {duration_minutes} minutes ---")
    conn = get_db_connection()
    cursor = conn.cursor()
    
    end_time = time.time() + (duration_minutes * 60)
    products = ['Product A', 'Product B', 'Product C', 'Product D']
    locations = ['New York', 'London', 'Tokyo', 'Paris', 'Berlin']

    try:
        while time.time() < end_time:
            action = random.choice(['INSERT', 'UPDATE', 'DELETE'])
            
            if action == 'INSERT':
                new_cust = random.randint(1000, 9999)
                new_order = random.randint(1000000, 9999999)
                amount = round(random.uniform(10.0, 1000.0), 2)
                date_str = datetime.now().strftime("%m/%d/%Y")
                
                sql = f"INSERT INTO {TABLE_NAME} (CustomerID, OrderID, ProductInformation, TransactionAmount, PurchaseDate, Location) VALUES (%s, %s, %s, %s, %s, %s)"
                cursor.execute(sql, (new_cust, new_order, random.choice(products), amount, date_str, random.choice(locations)))
                print(f"[CDC INSERT] New Order Created: {new_order}")

            elif action == 'UPDATE':
                cursor.execute(f"SELECT OrderID FROM {TABLE_NAME} ORDER BY RAND() LIMIT 1")
                res = cursor.fetchone()
                if res:
                    target_order = res[0]
                    new_amount = round(random.uniform(10.0, 1000.0), 2)
                    cursor.execute(f"UPDATE {TABLE_NAME} SET TransactionAmount = %s WHERE OrderID = %s", (new_amount, target_order))
                    print(f"[CDC UPDATE] Order {target_order} updated to ${new_amount}")

            elif action == 'DELETE':
                cursor.execute(f"SELECT OrderID FROM {TABLE_NAME} ORDER BY RAND() LIMIT 1")
                res = cursor.fetchone()
                if res:
                    target_order = res[0]
                    cursor.execute(f"DELETE FROM {TABLE_NAME} WHERE OrderID = %s", (target_order,))
                    print(f"[CDC DELETE] Order {target_order} removed")

            conn.commit()
            time.sleep(random.uniform(1, 4))

    except Error as e:
        print(f"Error during CDC: {e}")
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    print("Welcome to RDS CDC Simulator")
    print("1. Full Load (Reset table and load CSV)")
    print("2. CDC Load (Simulate live changes)")
    choice = input("Select option (1/2): ")

    if choice == '1':
        full_load()
    elif choice == '2':
        mins = int(input("Enter duration in minutes: "))
        cdc_load(mins)
    else:
        print("Invalid choice.")