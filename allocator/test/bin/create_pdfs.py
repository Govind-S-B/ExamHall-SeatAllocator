
import os
import subprocess

# Replace <directory_path> with the actual directory path
directory_path = r"..\reports"
dbs = os.listdir(directory_path)
# Replace <allocator_path> with the actual path to the allocator.exe file
pdf_generator_path = r"..\..\bin\pdf_generator.py"

for file_name in dbs:
    # Replace <directory_path> with the actual directory path
    file_path = os.path.join(directory_path, file_name)
    subprocess.call(["py", pdf_generator_path, file_path])
