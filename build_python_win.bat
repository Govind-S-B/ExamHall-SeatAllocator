python -m PyInstaller --onefile pdf_generator/pdf_generator.py
del pdf_generator.spec
robocopy dist EHSA_V3 /IS
rmdir /s /q "build"
rmdir /s /q "dist"