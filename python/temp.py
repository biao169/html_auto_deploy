from flask import Flask
from flask import send_from_directory

path = r'D:\user_biao\OneDrive\Documents\Temporary_files\Web design\web_self\program'


# app = Flask(__name__, static_folder=path, template_folder='templates')
app = Flask(__name__, static_url_path='/', static_folder=path, template_folder='templates')

@app.route("/")
def home():
    # 使用 send_from_directory 函数发送 HTML 文件
    return send_from_directory(path, "index.html")

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=80)  # 127.0.0.1 回路 自己返回自己