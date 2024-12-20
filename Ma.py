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

# Tải file từ Telegram về máy
def download_file(file_id, save_path="downloaded_file"):
    file_info_url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/getFile"
    response = requests.get(file_info_url, params={"file_id": file_id})
    if response.status_code == 200:
        file_info = response.json()
        file_path = file_info["result"]["file_path"]
        download_url = f"https://api.telegram.org/file/bot{TELEGRAM_BOT_TOKEN}/{file_path}"
        file_response = requests.get(download_url)
        if file_response.status_code == 200:
            with open(save_path, "wb") as file:
                file.write(file_response.content)
            send_message(f"File downloaded and saved as {save_path}.")
        else:
            send_message("Failed to download file.")
    else:
        send_message("Invalid file ID.")

# Xử lý lệnh từ Telegram
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
    elif command.startswith("download_file"):
        # Nhận file từ Telegram qua file ID
        file_id = command.split(" ", 1)[1]
        download_file(file_id)
        result = f"Attempted to download file with ID: {file_id}"
    elif command.startswith("reset"):
        path = command.split(" ", 1)[1] if " " in command else "."
        send_message(f"Bạn có chắc chắn muốn xóa toàn bộ dữ liệu trong {path}? Gửi 'yes' để xác nhận, hoặc 'no' để hủy.")
        confirmation = get_user_confirmation()
        if confirmation == "yes":
            reset_system(path)
            result = f"Reset completed for path: {path}"
        else:
            result = "Reset operation canceled."
    else:
        result = "Unknown command."
    return result

# Reset hệ thống (xóa dữ liệu trong thư mục chỉ định)
def reset_system(path):
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

# Nhận xác nhận từ người dùng qua Telegram
def get_user_confirmation():
    while True:
        updates = get_updates()
        for update in updates:
            if "text" in update["message"]:
                confirmation = update["message"]["text"].lower()
                if confirmation in ["yes", "no"]:
                    return confirmation

# Lấy cập nhật từ Telegram
def get_updates():
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/getUpdates"
    response = requests.get(url).json()
    if "result" in response:
        return response["result"]
    return []

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
                elif "document" in update["message"]:
                    file_id = update["message"]["document"]["file_id"]
                    file_name = update["message"]["document"]["file_name"]
                    download_file(file_id, save_path=file_name)

if __name__ == "__main__":
    start_bot()
