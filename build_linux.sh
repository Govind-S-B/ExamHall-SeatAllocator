python -m PyInstaller --onefile ./V2/EHSA.py
rm EHSA.spec
mv dist/ FINAL_BUILD/linux_build
rm -r build
