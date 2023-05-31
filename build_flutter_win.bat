rmdir /s /q EHSA_V3\data && del /q EHSA_V3\ehsa_frontend.exe del /q EHSA_V3\flutter_windows.dll
cd ehsa_frontend && flutter build windows && cd ../ && move ehsa_frontend\build\windows\runner\Release\data EHSA_V3 && move ehsa_frontend\build\windows\runner\Release\ehsa_frontend.exe EHSA_V3 && move ehsa_frontend\build\windows\runner\Release\flutter_windows.exe EHSA_V3
