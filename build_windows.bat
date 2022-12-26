:: RUN (in root directory)

:: pyinstaller --onefile json_generator.py
:: pyinstaller --onefile -w ./report_script/report_generator.py

:: FETCH FILES FROM dist folder

:: COPY TO FINAL_BUILD , FINAL EXE FILES

:: DELETE build files generated

:: Note : Build will only work with , compiled base system configuration
:: my system is x64 , Windows . So the build i make will only work with compatible system of my same configuration

python -m PyInstaller --onefile ./V2/EHSA.py

del EHSA.spec

copy dist FINAL_BUILD/windows/

rmdir /s /q "./build"
rmdir /s /q "./dist"
