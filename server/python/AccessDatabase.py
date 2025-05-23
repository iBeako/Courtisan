from fastapi import FastAPI, HTTPException, WebSocket, Depends
import cx_Oracle
from sshtunnel import SSHTunnelForwarder
from contextlib import contextmanager
from datetime import datetime
import os

app = FastAPI()

# Configuration SSH pour la VM distante avec clé privée
SSH_HOST = '192.168.100.119'
SSH_PORT = 22
SSH_USERNAME = 'ubuntu'  # Remplacez par votre nom d'utilisateur SSH
SSH_PKEY = "/app/private.pem"  # Assurez-vous que le fichier private.pem est copié dans le container
SSH_CONFIG_FILE = os.path.expanduser("/app/.ssh/config")

# Configuration de la base Oracle
DB_USER = 'COURTISANSJEU'
DB_PASSWORD = 'el3ebyidneghRoyalCardsDB'
DB_REMOTE_HOST = '172.18.0.2'
DB_REMOTE_PORT = 1521
DB_SERVICE_NAME = 'FREEPDB1'  # à adapter selon votre service Oracle

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
        INSERT INTO users (username, email, pseudo, password_hash, salt, is_active, total_games_played, pic_profile)
        VALUES (:username, :email, :pseudo,:password_hash, :salt, :is_active, :total_games_played, :pic_profile)
    """
    cursor.execute(
        query,
        username=data.get('username'),
        email=data.get('email'),
        pseudo=data.get('pseudo'),
        password_hash=data.get('password'),
        salt=data.get('salt'),
        is_active=data.get('is_active'),
        total_games_played=data.get('total_games_played'),
        pic_profile=data.get('pic_profile')
    )
    connection.commit()
    result = cursor.rowcount > 0
    cursor.close()
    if result:
        return {"status": "success", "message": "Account created."}
    else:
        return {"status": "error", "message": "Failed to create account."}

def get_account(login: str, connection, mode: int):
    cursor = connection.cursor()
    if mode == 0:
        query = "SELECT pseudo, password_hash, salt, pic_profile, username FROM users WHERE email = :email AND is_active = 0"
        cursor.execute(query, email=login)
    else:
        query = "SELECT pseudo, password_hash, salt, pic_profile, username FROM users WHERE username = :username AND is_active = 0"
        cursor.execute(query, username=login)
    result = cursor.fetchone()
    cursor.close()
    if result:
        return {"status": "success","pseudo": result[0], "password": result[1], "salt": result[2], "pic_profile": result[3],"username":result[4]}
    else:
        query = "SELECT pseudo, password_hash, salt, pic_profile FROM users WHERE email = :email"
        cursor.execute(query, email=login)
        second_result = cursor.fetchone()
        if second_result:
            return {"status": "error", "message": "Already connected."}
        else:
            return {"status": "error", "message": "Account not found."}



async def handle_create_account(websocket, data, connection):
    result = insert_account(data, connection)
    await websocket.send_json(result)

async def handle_connexion(websocket, data, connection):
    if "email" in data:
        result = get_account(data.get("email"), connection, 0)
    else:
        result = get_account(data.get("username"), connection, 1)
    await websocket.send_json(result)

async def handle_change_user_status(websocket, data, connection):
    username = data.get("username")
    is_active = data.get("is_active")
    cursor = connection.cursor()
    cursor.execute(
        "UPDATE users SET is_active = :is_active WHERE username = :username",
        is_active=is_active,
        username=username
    )
    connection.commit()
    cursor.close()
    if is_active:
        await websocket.send_json({"status": "success", "message": f" {username} is now active."})
        print("{username} active")
    else:
        await websocket.send_json({"status": "success", "message": f" {username} is now inactive."})
        print("{username}  inactive")

async def handle_change_profil(websocket, data, connection):
    username = data.get("username")
    pic = data.get("pic_profile")
    pseudo = data.get("pseudo")
    if username:
        if pic and pseudo:
            cursor = connection.cursor()
            cursor.execute("UPDATE users SET pic_profile = :pic_profile, pseudo =:pseudo WHERE username = :username", pic_profile=pic, pseudo=pseudo, username=username)
            connection.commit()
            cursor.close()
            await websocket.send_json({"status": "success", "message": "Profil updated.","username":data.get("username"),"pic_profile": data.get("pic_profile"),"pseudo": data.get("pseudo")})
        elif pic:
            cursor = connection.cursor()
            cursor.execute("UPDATE users SET pic_profile = :pic_profile WHERE username = :username", pic_profile=pic, username=username)
            connection.commit()
            cursor.close()
            await websocket.send_json({"status": "success", "message": "Profil picture updated.","pic_profile": data.get("pic_profile")})
        elif pseudo:
            cursor = connection.cursor()
            cursor.execute("UPDATE users SET pseudo = :pseudo WHERE username = :username", pseudo=pseudo, username=username)
            connection.commit()
            cursor.close()
            await websocket.send_json({"status": "success", "message": "Pseudo updated.","pseudo": data.get("pseudo")})
        else:
            await websocket.send_json({"status": "error", "message": "No data to update."})
    else:
        await websocket.send_json({"status": "error", "message": "Username not provided."})

async def handle_find_lobby(websocket, connection):
    cursor = connection.cursor()
    cursor.execute("""
        SELECT 
            g.game_id,
            g.num_players,
            g.name,
            g.password,
            COUNT(gp.user_id) AS current_players
        FROM games g
        LEFT JOIN game_players gp ON g.game_id = gp.game_id
        WHERE g.status = 'active'
        GROUP BY g.game_id, g.num_players, g.name, g.password
    """)
    rows = cursor.fetchall()
    cursor.close()

    # Convert result to list of dictionaries
    columns = ["game_id", "num_players", "name", "password", "current_players"]
    lobbies = [dict(zip(columns, row)) for row in rows]

    await websocket.send_json({"status": "success", "lobbies": lobbies})

async def handle_create_lobby(websocket, data, connection):
    username = data.get("username")
    name = data.get("name")
    num_players = data.get("number_of_player")
    have_password = data.get("have_password")
    password = data.get("password") if have_password == 0 else None
    date_str = datetime.now().strftime("%Y-%m-%d")

    cursor = connection.cursor()
    cursor.execute("""
        INSERT INTO games (num_players, password, game_date, status, name)
        VALUES (:num_players, :password, to_date(:game_date, 'YYYY-MM-DD'), 'active', :name)
    """, num_players=num_players, password=password, game_date=date_str, name=name)
    connection.commit()
    cursor.execute("SELECT game_id FROM games WHERE name = :name AND game_date = to_date(:game_date, 'YYYY-MM-DD')", name=name, game_date=date_str)
    game_id = cursor.fetchone()[0]
    cursor.execute("SELECT user_id FROM users WHERE username = :uname", uname=username)
    user_id  = cursor.fetchone()[0]
    cursor.execute("INSERT INTO game_players (user_id,game_id) VALUES (:pid, :gid)",pid=user_id, gid=game_id)
    connection.commit()
    cursor.close()
    await websocket.send_json({"status": "success", "game_id": game_id})

async def handle_join_lobby(websocket, data, connection):
    id_lobby = data.get("id_lobby")
    password = data.get("password")
    username = data.get("username")

    cursor = connection.cursor()
    cursor.execute("SELECT password, num_players FROM games WHERE game_id = :id AND status = 'active'", id=id_lobby)
    game = cursor.fetchone()
    if not game:
        await websocket.send_json({"status": "error", "message": "Game not found or not open."})
        return
    if game[0] and game[0] != password:
        await websocket.send_json({"status": "error", "message": "Incorrect password."})
        return
    cursor.execute("SELECT COUNT(*) FROM game_players WHERE game_id = :id", id=id_lobby)
    count = cursor.fetchone()[0]
    if count >= game[1]:
        await websocket.send_json({"status": "error", "message": "Lobby is full."})
        return
    cursor.execute("""
        SELECT COUNT(*) FROM game_players
        WHERE game_id = :gid AND user_id = (SELECT user_id FROM users WHERE username = :uname)
        """, gid=id_lobby, uname=username)
    already_in_lobby = cursor.fetchone()[0]
    if already_in_lobby > 0:
        await websocket.send_json({"status": "error", "message": "User already in lobby."})
        cursor.close()
        return
    cursor.execute("""
        INSERT INTO game_players (user_id,game_id)
        VALUES ((SELECT user_id FROM users WHERE username = :uname),:gid)
        """,uname=username, gid=id_lobby)
    connection.commit()
    if count + 1 == game[1]:
        cursor.execute("UPDATE games SET status = 'closed' WHERE game_id = :id", id=id_lobby)
        connection.commit()
    cursor.close()
    print("joined the lobby")
    await websocket.send_json({"status": "success", "id_lobby":id_lobby,"message": "Joined lobby."})

async def handle_start_lobby(websocket, data, connection):
    id_lobby = data.get("id_lobby")
    cursor = connection.cursor()
    cursor.execute("UPDATE games SET status = 'closed' WHERE game_id = :id AND status != 'closed'", id=id_lobby)
    connection.commit()
    cursor.close()
    await websocket.send_json({"status": "success","id_lobby":id_lobby, "message": "Game started."})

async def handle_quit_lobby(websocket, data, connection):
    id_lobby = data.get("id_lobby")
    username = data.get("username")
    cursor = connection.cursor()
    cursor.execute("""
        DELETE FROM game_players 
        WHERE game_id = :gid 
        AND user_id IN (SELECT user_id FROM users WHERE username = :username)
    """, gid=id_lobby, username=username)
    connection.commit()
    cursor = connection.cursor()
    cursor.execute("SELECT num_players FROM games WHERE game_id = :id", id=id_lobby)
    num_players_max = cursor.fetchone()
    cursor.execute("SELECT COUNT(*) FROM game_players WHERE game_id = :id", id=id_lobby)
    count = cursor.fetchone()[0]
    if count + 1 == num_players_max:
        cursor.execute("UPDATE games SET status = 'active' WHERE game_id = :id", id=id_lobby)
        connection.commit()
    cursor.close()
    await websocket.send_json({"status": "success","id_lobby":id_lobby, "message": "Player removed from lobby."})

async def handle_destroy_lobby(websocket, data, connection):
    id_lobby = data.get("id_lobby")
    cursor = connection.cursor()
    cursor.execute("DELETE FROM games WHERE game_id = :gid", gid=id_lobby)
    connection.commit()
    cursor.close()
    await websocket.send_json({"status": "success", "id_lobby":id_lobby,"message": "game removed."})

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    connection, tunnel = get_db_connection()

    try:
        while True:
            data = await websocket.receive_json()
            message_type = data.get("message_type")
            print(data)
            try:
                if message_type == "createAccount":
                    await handle_create_account(websocket, data, connection)
                    print("Account created.")
                elif message_type == "connexion":
                    await handle_connexion(websocket, data, connection)
                    print("asked for connection info")
                elif message_type == "change_status":
                    print("message received")
                    await handle_change_user_status(websocket, data, connection)
                    print("User status changed.")
                elif message_type == "change_profil":
                    await handle_change_profil(websocket, data, connection)
                    print("Profil picture changed.")
                elif message_type == "find_lobby":
                    await handle_find_lobby(websocket, connection)
                    print("Lobbies found.")
                elif message_type == "create_lobby":
                    await handle_create_lobby(websocket, data, connection)
                    print("Lobby created.")
                elif message_type == "join_lobby":
                    await handle_join_lobby(websocket, data, connection)
                    print("Joined lobby.")
                elif message_type == "start_lobby":
                    await handle_start_lobby(websocket, data, connection)
                    print("Lobby started.")
                elif message_type == "quit_lobby":
                    await handle_quit_lobby(websocket, data, connection)
                    print("Player quit lobby.")
                elif message_type == "destroy_lobby":
                    await handle_destroy_lobby(websocket, data, connection)
                    print("lobby destroyed.")
                else:
                    await websocket.send_json({"status": "error", "message": "Unknown message_type."})
            except Exception as e:
                await websocket.send_json({"status": "error", "message": str(e)})
    except Exception as e:
        await websocket.send_json({"status": "error", "message": str(e)})

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
