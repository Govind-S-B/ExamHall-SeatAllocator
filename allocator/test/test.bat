set ORIGINAL_DIR=%CD%
cd output/reports
py ../../bin/run_tests.py
cd ../pdfs
chdir /d %ORIGINAL_DIR%

