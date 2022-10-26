:: RUN (in root directory)

:: pyinstaller --onefile json_generator.py
:: pyinstaller --onefile -w ./report_script/report_genv2.py

:: FETCH FILES FROM dist folder

:: COPY TO FINAL_BUILD , FINAL EXE FILES

:: DELETE build files generated

:: Note : Build will only work with , compiled base system configuration
:: my system is x64 , Windows . So the build i make will only work with compatible system of my same configuration

pyinstaller --onefile json_generator.py
pyinstaller --onefile -w ./report_script/report_genv2.py

del json_generator.spec
del report_genv2.spec

copy dist FINAL_BUILD

rmdir /s /q "./build"
rmdir /s /q "./dist"