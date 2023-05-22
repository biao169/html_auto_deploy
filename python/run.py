
#!/usr/bin/env python3
import os
import sys
import signal
import time

def save_start_program_pid():
    # 在这里编写你要自动运行的代码

    # 将当前进程的 PID 写入文件
    pid = os.getpid()
    with open("/var/run/my_program.pid", "w") as f:
        f.write(str(pid))


def start_program():
    # 在这里编写你要自动运行的代码
    save_start_program_pid()
    while True:
        print("程序正在运行...")
        time.sleep(1)


def stop_program(signum, frame):
    # 在这里编写程序停止时的清理代码
    print("程序停止运行")
    sys.exit(0)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("请提供有效的命令参数（start 或 stop）")
        sys.exit(1)

    command = sys.argv[1]
    if command == "start":
        # 启动程序
        start_program()
    elif command == "stop":
        # 停止程序
        pid_file = "/var/run/my_program.pid"  # 保存进程ID的文件路径
        if os.path.exists(pid_file):
            with open(pid_file, "r") as f:
                pid = int(f.read().strip())
                os.kill(pid, signal.SIGTERM)
                os.remove(pid_file)
                print("程序已停止")
        else:
            print("找不到程序的运行进程ID")
    else:
        print("无效的命令参数（start 或 stop）")
        sys.exit(1)
    """ 
    python3 your_program.py start   # 启动程序
    python3 your_program.py stop    # 停止程序

    """