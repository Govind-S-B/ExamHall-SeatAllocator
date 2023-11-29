set ORIGINAL_DIR=%CD%

cd output
py ../bin/create_dbs.py
py ../bin/debug_halls.py

chdir /d %ORIGINAL_DIR%

