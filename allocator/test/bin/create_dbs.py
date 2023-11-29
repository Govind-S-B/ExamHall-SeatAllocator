import os
import subprocess

# Replace <directory_path> with the actual directory path
directory_path = r"..\Sample data"
sample_data = os.listdir(directory_path)
# Replace <allocator_path> with the actual path to the allocator.exe file
allocator_path = r"..\bin\allocator.exe"

for file_name in sample_data:
    # Replace <directory_path> with the actual directory path
    file_path = os.path.join(directory_path, file_name)
    print(allocator_path, file_path, file_name, sep=';   ')
    # subprocess.call([allocator_path, file_path, file_name, "-r", "5"])
    subprocess.call([allocator_path, file_path, file_name])
