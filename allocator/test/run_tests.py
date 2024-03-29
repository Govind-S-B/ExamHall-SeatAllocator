import os
import subprocess

# Replace <directory_path> with the actual directory path
directory_path = "Sample data"
sample_data = os.listdir(directory_path)
# Replace <allocator_path> with the actual path to the allocator.exe file
allocator_path = r"bin\allocator.exe"

for file_name in sample_data:
    # Replace <directory_path> with the actual directory path
    file_path = os.path.join(directory_path, file_name)
    report_path = os.path.join("reports", file_name)
    subprocess.call([allocator_path, file_path, report_path, "-r", "5"])
