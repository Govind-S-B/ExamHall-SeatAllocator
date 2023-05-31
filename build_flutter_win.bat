rmdir /s /q EHSA_V3\data && del /q EHSA_V3\ehsa_frontend.exe
cd ehsa_frontend && flutter build windows && cd ../ && move ehsa_frontend\build\windows\runner\Release\data EHSA_V3 && move ehsa_frontend\build\windows\runner\Release\ehsa_frontend.exe EHSA_V3
