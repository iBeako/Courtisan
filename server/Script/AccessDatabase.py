from flask import Flask, request
from flask_socketio import SocketIO
import cx_Oracle

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

# Oracle DB connection
DB_USER = 'your_username'
DB_PASSWORD = 'your_password'
DB_DSN = 'your_db_host/your_service_name'

def get_db_connection():
    return cx_Oracle.connect(DB_USER, DB_PASSWORD, DB_DSN)

@socketio.on('insert_database')
def handle_insert_database(data):
    try:
        connection = get_db_connection()
        cursor = connection.cursor()
        
        # Example: Insert into a users table
        query = "INSERT INTO users (username, email, password_hash, is_active, total_games_played) VALUES (:username, :email, :password_hash, :is_active, :total_games_played)"
        cursor.execute(query, username=data['login'], email=data['email'],password_hash=data['password'], is_active=data['is_active'], total_games_played=data['total_games_played'])
        connection.commit()
        
        cursor.close()
        connection.close()
        
        socketio.emit('database_response', {"status": "success", "message": "Account created."})
    except Exception as e:
        socketio.emit('database_response', {"status": "error", "message": str(e)})


@socketio.on('get_database')
def handle_get_database(data):
    try:
        connection = get_db_connection()
        cursor = connection.cursor()
        
        # Example: Fetch user details
        query = "SELECT username, password FROM users WHERE email = :email"
        cursor.execute(query, email=data['email'])
        
        result = cursor.fetchone()
        cursor.close()
        connection.close()
        
        if result:
            socketio.emit('database_response', {"login": result[0], "password": result[1]})
        else:
            socketio.emit('database_response', {"message": "User not found."})
            
    except Exception as e:
        socketio.emit('database_response', {"status": "error", "message": str(e)})


if __name__ == '__main__':
    socketio.run(app, host='127.0.0.1', port=10000)

