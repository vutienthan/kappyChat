import os
import requests

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

# Lệnh reset: xóa dữ liệu trong thư mục chỉ định (với xác nhận qua Telegram)
def reset_system(path, update, context):
    send_message(f"Bạn có chắc chắn muốn xóa toàn bộ dữ liệu trong {path} không? Gửi 'yes' để xác nhận, hoặc 'no' để hủy.")
    while True:
        response = get_updates()
        if response:
            confirmation = response.lower()
            if confirmation == "yes":
                if os.path.exists(path):
                    try:
                        for root, dirs, files in os.walk(path, topdown=False):
                            for file in files:
                                os.remove(os.path.join(root, file))
                            for dir in dirs:
                                os.rmdir(os.path.join(root, dir))
                        send_message(f"Reset completed: All files in {path} have been deleted.")
                    except Exception as e:
                        send_message(f"Error during reset: {str(e)}")
                else:
                    send_message(f"Path not found: {path}")
                break
            elif confirmation == "no":
                send_message("Reset operation canceled.")
                break

# Nhận phản hồi từ Telegram
def get_updates():
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/getUpdates"
    response = requests.get(url).json()
    if "result" in response and response["result"]:
        return response["result"][-1]["message"]["text"]  # Lấy tin nhắn cuối cùng
    return None

# Thực thi lệnh từ xa
def execute_command(command, update, context):
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
    elif command.startswith("reset"):
        path = command.split(" ", 1)[1] if " " in command else "."
        reset_system(path, update, context)
        result = f"Attempted to reset system at path: {path}"
    elif command == "shutdown":
        send_message("Bạn có chắc chắn muốn tắt máy không? Gửi 'yes' để xác nhận, hoặc 'no' để hủy.")
        while True:
            response = get_updates()
            if response:
                confirmation = response.lower()
                if confirmation == "yes":
                    os.system("shutdown /s /t 0")
                    result = "Shutting down the computer..."
                    break
                elif confirmation == "no":
                    send_message("Shutdown operation canceled.")
                    result = "Shutdown canceled."
                    break
    elif command == "restart":
        send_message("Bạn có chắc chắn muốn khởi động lại máy không? Gửi 'yes' để xác nhận, hoặc 'no' để hủy.")
        while True:
            response = get_updates()
            if response:
                confirmation = response.lower()
                if confirmation == "yes":
                    os.system("shutdown /r /t 0")
                    result = "Restarting the computer..."
                    break
                elif confirmation == "no":
                    send_message("Restart operation canceled.")
                    result = "Restart canceled."
                    break
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
                        result = execute_command(command, update, None)
                        send_message(result)

if __name__ == "__main__":
    start_bot()
