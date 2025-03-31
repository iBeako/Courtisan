from fastapi import FastAPI, HTTPException, WebSocket, Depends
import cx_Oracle
from sshtunnel import SSHTunnelForwarder
from contextlib import contextmanager
import os

app = FastAPI()

# Configuration SSH pour la VM distante avec clé privée
SSH_HOST = '192.168.100.119'
SSH_PORT = 22
SSH_USERNAME = 'ubuntu'  # Remplacez par votre nom d'utilisateur SSH
SSH_PKEY = "/app/private.pem"  # Assurez-vous que le fichier private.pem est copié dans le container
SSH_CONFIG_FILE = os.path.expanduser("/app/.ssh/config")

# Configuration de la base Oracle
DB_USER = 'sys'
DB_PASSWORD = '"C@uRT1$4n5"'
DB_REMOTE_HOST = '172.18.0.2'
DB_REMOTE_PORT = 1521
DB_SERVICE_NAME = "FREE"  # à adapter selon votre service Oracle

def get_db_connection():
    # Utilisation de la clé privée pour l'authentification SSH
    tunnel = SSHTunnelForwarder(
        (SSH_HOST, SSH_PORT),
        ssh_username=SSH_USERNAME,
        ssh_pkey=SSH_PKEY,
        ssh_config_file=SSH_CONFIG_FILE,
        remote_bind_address=(DB_REMOTE_HOST, DB_REMOTE_PORT)
    )
    tunnel.start()
    print("Tunnel SSH ouvert sur le port:", tunnel.local_bind_port)
    local_port = tunnel.local_bind_port
    dsn = f"127.0.0.1:{local_port}/{DB_SERVICE_NAME}"
    print("connexion à la base de données avec DSN:", dsn)
    connection = cx_Oracle.connect(
        DB_USER,
        DB_PASSWORD,
        dsn,
        mode=cx_Oracle.SYSDBA,
        encoding="UTF-8",
        nencoding="UTF-8"
    )
    return connection, tunnel

@contextmanager
def get_db():
    connection,tunnel = get_db_connection()
    try:
        yield connection
    finally:
        connection.close()
        tunnel.stop()

def insert_account(data: dict, connection):
    cursor = connection.cursor()
    query = """
        -- Exemple d'insertion (à décommenter et adapter si besoin)
        -- INSERT INTO users (username, email, password_hash, is_active, total_games_played)
        -- VALUES (:username, :email, :password_hash, :is_active, :total_games_played)
    """
    cursor.execute(
        query,
        username=data.get('login'),
        email=data.get('email'),
        password_hash=data.get('password'),
        is_active=data.get('is_active'),
        total_games_played=data.get('total_games_played')
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

def get_all_users(connection):
    cursor = connection.cursor()
    query = "SELECT * FROM users"
    cursor.execute(query)
    results = cursor.fetchall()
    cursor.close()
    return results

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

@app.get("/get_all_users")
async def get_all_users_endpoint(connection=Depends(get_db)):
    try:
        users = get_all_users(connection)
        return {"users": users}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.websocket("/ws")
async def websocket_endpoint(websocket, connection=Depends(get_db)):
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

# Test en ligne de commande
if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == 'test':
        try:
            with get_db() as connection:
                users = get_all_users(connection)
                print("Test réussi. Voici les utilisateurs:")
                for user in users:
                    print(user)
        except Exception as e:
            print("Test échoué:", e)
    else:
        import uvicorn
        uvicorn.run(app, host='0.0.0.0', port=12345)
