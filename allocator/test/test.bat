set ORIGINAL_DIR=%CD%

cd output/reports
py ../../bin/create_dbs.py
cd ../pdfs
py ../../bin/create_pdfs.py

chdir /d %ORIGINAL_DIR%

