python -m PyInstaller --onefile ./V2/EHSA.py
rm EHSA.spec
mkdir FINAL_BUILD/linux_build
mv dist/* FINAL_BUILD/linux_build
rm -r dist
rm -r build
