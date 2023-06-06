!include LogicLib.nsh

; The name of the installer
Name "EHSA Installer"

; Set the output file name
OutFile "ehsa_installer.exe"

; The default installation directory
InstallDir "$PROGRAMFILES\EHSA"

; Create the installation directory
Section
  SetOutPath $INSTDIR
SectionEnd

; Add the files and directories to the installer
Section
  SetOutPath $INSTDIR
  File /r "EHSA_V3\*.*"
SectionEnd

; Create a shortcut for ehsa_frontend.exe on the desktop
Section
  SetOutPath "$DESKTOP"
  CreateShortCut "$DESKTOP\EHSA.lnk" "$INSTDIR\bin\ehsa_frontend.exe"
SectionEnd

; Call the CheckVCRedist function
Function .onInit
  Call CheckVCRedist
FunctionEnd

; Install VC++ Redist
Function InstallVCRedist
  ; Download the VC++ Redist installer
  NSISdl::download "https://aka.ms/vs/17/release/vc_redist.x64.exe" "$TEMP\vc_redist.x64.exe"
  ; Run the installer
  ExecWait "$TEMP\vcredist_x86.exe /q"
  ; Check if the installation was successful
  ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" "Installed"
  ; If the installation was not successful, prompt the user to try again
  ${If} $0 == ""
    MessageBox MB_RETRYCANCEL "VC++ Redist installation failed. Do you want to try again?" IDRETRY retry 
    retry:
        Call InstallVCRedist
  ${EndIf}
FunctionEnd

Function CheckVCRedist
  ; Check if the registry key exists
  ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" "Installed"
  ; If the key does not exist, prompt the user to install VC++ Redist
  ${If} $0 == ""
    MessageBox MB_YESNO "This application requires VC++ Redist. Do you want to install it now?" IDYES install_vc_redist
    install_vc_redist:
        Call InstallVCRedist
  ${EndIf}
FunctionEnd