import os
import requests

# Cấu hình bot Telegram
TELEGRAM_BOT_TOKEN = "your_bot_token"  # Thay bằng token bot của bạn
TELEGRAM_CHAT_ID = "your_chat_id"      # Thay bằng Chat ID của bạn

# Trạng thái chấp nhận lệnh nguy hiểm
ALLOW_DANGEROUS_COMMANDS = True

# Gửi tin nhắn đến Telegram
def send_message(message):
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    data = {"chat_id": TELEGRAM_CHAT_ID, "text": message}
    response = requests.post(url, data=data)
    if response.status_code != 200:
        print(f"Error sending message: {response.text}")

# Lấy cập nhật từ Telegram
def get_updates(offset=None):
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/getUpdates"
    params = {"offset": offset} if offset else {}
    response = requests.get(url, params=params).json()
    if "result" in response:
        return response["result"]
    return []

# Xóa toàn bộ tin nhắn cũ
def clear_updates():
    updates = get_updates()
    if updates:
        last_update_id = updates[-1]["update_id"]
        get_updates(offset=last_update_id + 1)

# Xử lý lệnh từ Telegram
def execute_command(command):
    global ALLOW_DANGEROUS_COMMANDS
    if command.startswith("list_files"):
        path = command.split(" ", 1)[1] if " " in command else "."
        if os.path.exists(path):
            files = os.listdir(path)
            result = "\n".join(files) if files else "No files found."
        else:
            result = f"Path not found: {path}"
    elif command.startswith("delete_file"):
        # Lệnh: delete_file <đường_dẫn_file>
        file_path = command.split(" ", 1)[1]
        if os.path.exists(file_path):
            send_message(f"Bạn có chắc chắn muốn xóa file {file_path}? Gửi 'yes' để xác nhận, hoặc 'no' để hủy.")
            confirmation = get_user_confirmation()
            if confirmation == "yes":
                try:
                    os.remove(file_path)
                    result = f"File {file_path} has been deleted successfully."
                except Exception as e:
                    result = f"Error deleting file {file_path}: {str(e)}"
            else:
                result = "File deletion canceled."
        else:
            result = f"File not found: {file_path}"
    elif command == "shutdown":
        if not ALLOW_DANGEROUS_COMMANDS:
            result = "Shutdown command is disabled by user."
        else:
            send_message("Bạn có chắc chắn muốn tắt máy không? Gửi 'yes' để xác nhận, hoặc 'no' để hủy.")
            confirmation = get_user_confirmation()
            if confirmation == "yes":
                os.system("shutdown /s /t 0")
                result = "Shutting down the computer..."
            else:
                ALLOW_DANGEROUS_COMMANDS = False
                result = "Shutdown command disabled permanently."
    elif command == "restart":
        if not ALLOW_DANGEROUS_COMMANDS:
            result = "Restart command is disabled by user."
        else:
            send_message("Bạn có chắc chắn muốn khởi động lại máy không? Gửi 'yes' để xác nhận, hoặc 'no' để hủy.")
            confirmation = get_user_confirmation()
            if confirmation == "yes":
                os.system("shutdown /r /t 0")
                result = "Restarting the computer..."
            else:
                ALLOW_DANGEROUS_COMMANDS = False
                result = "Restart command disabled permanently."
    else:
        result = "Unknown command."
    return result

# Nhận xác nhận từ người dùng qua Telegram
def get_user_confirmation():
    while True:
        updates = get_updates()
        for update in updates:
            if "text" in update["message"]:
                confirmation = update["message"]["text"].lower()
                if confirmation in ["yes", "no"]:
                    return confirmation

# Vòng lặp chính của bot
def start_bot():
    last_update_id = None
    send_message("Bot started. Send commands to control your computer.")

    # Xóa toàn bộ tin nhắn cũ
    clear_updates()

    while True:
        updates = get_updates(last_update_id)
        for update in updates:
            last_update_id = update["update_id"]
            if "message" in update and "text" in update["message"]:
                command = update["message"]["text"]
                result = execute_command(command)
                send_message(result)

if __name__ == "__main__":
    start_bot()
