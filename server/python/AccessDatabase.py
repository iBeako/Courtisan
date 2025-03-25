from fastapi import FastAPI, WebSocket

app = FastAPI()

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_json()  # Receive JSON message
            print(f"Received: {data}")
            response = {"message": "Received your data!", "data": data}
            await websocket.send_json(response)  # Send a response
    except Exception as e:
        print("WebSocket error:", str(e))
        await websocket.close()

""" 
from fastapi import FastAPI, HTTPException, WebSocket, Depends
import cx_Oracle
from sshtunnel import SSHTunnelForwarder  # pip install sshtunnel
from contextlib import contextmanager

app = FastAPI()

# SSH tunnel configuration for remote DB access
SSH_HOST = 'vmProjetIntegrateur9-1'
SSH_PORT = 22
# Removed SSH_USER and SSH_PASSWORD for auto SSH connection via SSH config

# Remote database configuration
DB_USER = 'sys'
DB_PASSWORD = '"C@uRT1$4n5"'
DB_REMOTE_HOST = 'vmProjetIntegrateur9-1'
DB_REMOTE_PORT = 1521  # ensure this port is correct for your Oracle DB

def get_db_connection():
    # Establish SSH tunnel to the remote VM using your SSH config
    tunnel = SSHTunnelForwarder(
        (SSH_HOST, SSH_PORT),
        use_ssh_config=True,
        remote_bind_address=(DB_REMOTE_HOST, DB_REMOTE_PORT)
    )
    tunnel.start()
    local_port = tunnel.local_bind_port
    dsn = f"127.0.0.1:{local_port}/{DB_SERVICE_NAME}"
    connection = cx_Oracle.connect(DB_USER, DB_PASSWORD, dsn,mode=cx_Oracle.SYSDBA, encoding="UTF-8", nencoding="UTF-8")
    # Attach the tunnel for later cleanup
    connection.tunnel = tunnel
    return connection

@contextmanager
def get_db():
    connection = get_db_connection()
    try:
        yield connection
    finally:
        connection.close()
        connection.tunnel.stop()

# Business logic helper functions
def insert_account(data: dict, connection):
    cursor = connection.cursor()
    query = """
        #INSERT INTO users (username, email, password_hash, is_active, total_games_played)
        #VALUES (:username, :email, :password_hash, :is_active, :total_games_played)
"""
    cursor.execute(
        query,
        username=data['login'],
        email=data['email'],
        password_hash=data['password'],
        is_active=data['is_active'],
        total_games_played=data['total_games_played']
    )
    connection.commit()
    cursor.close()
    return {"status": "success", "message": "Account created."}

def get_account(email: str, connection):
    cursor = connection.cursor()
    query = "SELECT username, password FROM users WHERE email = :email"
    cursor.execute(query, email=email)
    result = cursor.fetchone()
    cursor.close()
    if result:
        return {"login": result[0], "password": result[1]}
    else:
        return {"message": "User not found."}

# HTTP endpoints using dependency injection
@app.post("/insert_database")
async def insert_database(data: dict, connection=Depends(get_db)):
    try:
        result = insert_account(data, connection)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/get_database")
async def get_database(email: str, connection=Depends(get_db)):
    try:
        result = get_account(email, connection)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# WebSocket endpoint: since dependency injection is not automatically applied here,
# we create a new connection per operation using our context manager.
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_json()
            action = data.get("action")
            if action == "insert":
                with get_db() as connection:
                    response = insert_account(data, connection)
                await websocket.send_json(response)
            elif action == "get":
                email = data.get("email")
                with get_db() as connection:
                    response = get_account(email, connection)
                await websocket.send_json(response)
            else:
                await websocket.send_json({"message": "Unknown action"})
    except Exception as e:
        await websocket.send_json({"status": "error", "message": str(e)})
        await websocket.close()
""" 
if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=12345)
