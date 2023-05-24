import subprocess
import os
import time

# Path to the executable file
exe_path = os.path.dirname(__file__) + "\ehsa_frontend.exe"
print(exe_path)
# Launch the executable using subprocess.Popen
process = subprocess.Popen(exe_path)

# Continue executing other code while the executable is running
while process.poll() is None:
    print(process.pid)

# The executable has been closed
print("Executable has been closed.")