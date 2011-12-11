; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "ADCH++"
!define PRODUCT_PUBLISHER "Jacek Sieka"
!define PRODUCT_WEB_SITE "http://adchpp.sourceforge.net"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\adchppd.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

Function GetAdchppdVersion
	Exch $0
	GetDllVersion "$INSTDIR\$0" $R0 $R1
	IntOp $R2 $R0 >> 16
	IntOp $R2 $R2 & 0x0000FFFF
	IntOp $R3 $R0 & 0x0000FFFF
	IntOp $R4 $R1 >> 16
	IntOp $R4 $R4 & 0x0000FFFF
	StrCpy $1 "$R2.$R3.$R4"
	Exch $1
FunctionEnd

SetCompressor lzma

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "adchppd.ico"
!define MUI_UNICON "adchppd.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\readme.txt"
!define MUI_FINISHPAGE_RUN "$INSTDIR\adchppd.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; Reserve files
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

; MUI end ------

Name "${PRODUCT_NAME}"
OutFile "ADCHPP-xxx.exe"
InstallDir "$PROGRAMFILES\ADCH++"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  File "aboost_date_time.dll"
  File "aboost_system.dll"
  File "adchpp.dll"
  File "adchppd.exe"
  File "alua.dll"
  File "Bloom.dll"
  File "changelog.txt"
  File "libgcc_s_dw2-1.dll"
  File "libstdc++-6.dll"
  File "License.txt"
  File "luadchpp.dll"
  File "pyadchpp.py"
  File "Script.dll"
  File "readme.txt"
  File "FirstReg.cmd"
  File "Generate_certs.cmd"
  CreateShortCut "$DESKTOP\ADCH++.lnk" "$INSTDIR\adchppd.exe"
  CreateDirectory "$SMPROGRAMS\ADCH++"
  CreateShortCut "$SMPROGRAMS\ADCH++\ADCH++ Help.lnk" "$INSTDIR\readme.txt"
  CreateShortCut "$SMPROGRAMS\ADCH++\Install ADCH++ as windows service.lnk" "$INSTDIR\adchppd.exe" "-i adchppd"
  CreateShortCut "$SMPROGRAMS\ADCH++\Remove ADCH++ windows service.lnk" "$INSTDIR\adchppd.exe" "-u adchppd"
  SetOutPath "$INSTDIR\Scripts"
  File "Scripts\access.lua"
  File "Scripts\access.bans.lua"
  File "Scripts\access.bot.lua"
  IfFileExists $INSTDIR\Scripts\access.limits.lua 0 +2
    Rename $INSTDIR\Scripts\access.limits.lua $INSTDIR\Scripts\access.limits.lua.old
  File "Scripts\access.guard.lua"
  File "Scripts\access.op.lua"
  File "Scripts\autil.lua"
  File "Scripts\aio.lua"
  File "Scripts\example.lua"
  File "Scripts\history.lua"
  File "Scripts\json.lua"
  File "Scripts\motd.lua"
  CreateDirectory $INSTDIR\Scripts\FL_Database
  SetOutPath "$INSTDIR\Docs"
  File "Docs\*.conf"
  File "Docs\*.html"
  File "Docs\*.txt"
  SetOutPath "$INSTDIR\Docs\images"
  File "Docs\images\*.png"
  SetOutPath "$INSTDIR\Docs\images\icons"
  File "Docs\images\icons\*.png"
  SetOverwrite off
  SetOutPath "$INSTDIR\config"
  File "config\motd.txt"
  File "config\adchpp.xml"
  File "config\Script.xml"
SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\ADCH++\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\ADCH++\ADCH++.lnk" "$INSTDIR\adchppd.exe"
  CreateShortCut "$SMPROGRAMS\ADCH++\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Service
  MessageBox MB_ICONQUESTION|MB_YESNO "Do you wish to install ADCH++ as a service?" IDYES Service IDNO End
  Service: Exec '"$INSTDIR\adchppd.exe" -i adchppd'
  End:
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninst.exe"
  
  ; Get adchppd version we just installed and store in $1
  Push "adchppd.exe"
  Call "GetAdchppdVersion"
  Pop $1
  
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\adchppd.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name) $1"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\adchppd.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "$1"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Section -un.Service
     Exec 'sc delete adchppd'
    
SectionEnd

Section -un.remSettings
  MessageBox MB_ICONQUESTION|MB_YESNO "Do you wish to remove all the ADCH++ configuration files, statistics, logs and accounts?" IDYES Remove IDNO NoRemove
  Remove: 
  Delete "$INSTDIR\config\users.txt"
  Delete "$INSTDIR\config\history.txt"
  Delete "$INSTDIR\config\settings.txt"
  Delete "$INSTDIR\config\motd.txt"
  Delete "$INSTDIR\config\bans.txt"
  Delete "$INSTDIR\config\en_settings.txt"
  Delete "$INSTDIR\config\fl_settings.txt"
  Delete "$INSTDIR\config\li_settings.txt"
  Delete "$INSTDIR\config\users.txt.tmp"
  Delete "$INSTDIR\config\history.txt.tmp"
  Delete "$INSTDIR\config\settings.txt.tmp"
  Delete "$INSTDIR\config\motd.txt.tmp"
  Delete "$INSTDIR\config\bans.txt.tmp"
  Delete "$INSTDIR\config\en_settings.txt.tmp"
  Delete "$INSTDIR\config\fl_settings.txt.tmp"
  Delete "$INSTDIR\config\li_settings.txt.tmp"
  Delete "$INSTDIR\config\Script.xml"
  Delete "$INSTDIR\config\adchpp.xml"
  Delete "$INSTDIR\config\logs\*.log"
  Delete "$INSTDIR\Scripts\FL_Database\commandstats.txt"
  Delete "$INSTDIR\Scripts\FL_Database\entitystats.txt"
  Delete "$INSTDIR\Scripts\FL_Database\kickstats.txt"
  Delete "$INSTDIR\Scripts\FL_Database\limitstats.txt"
  Delete "$INSTDIR\Scripts\FL_Database\tmpbanstats.txt"
  Delete "$INSTDIR\Scripts\FL_Database\commandstats.txt.tmp"
  Delete "$INSTDIR\Scripts\FL_Database\entitystats.txt.tmp"
  Delete "$INSTDIR\Scripts\FL_Database\kickstats.txt.tmp"
  Delete "$INSTDIR\Scripts\FL_Database\limitstats.txt.tmp"
  Delete "$INSTDIR\Scripts\FL_Database\tmpbanstats.txt.tmp"
  NoRemove:
SectionEnd

Section Uninstall
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\aboost_date_time.dll"
  Delete "$INSTDIR\aboost_system.dll"
  Delete "$INSTDIR\adchpp.dll"
  Delete "$INSTDIR\adchppd.exe"
  Delete "$INSTDIR\alua.dll"
  Delete "$INSTDIR\Bloom.dll"
  Delete "$INSTDIR\changelog.txt"
  Delete "$INSTDIR\libgcc_s_dw2-1.dll"
  Delete "$INSTDIR\libstdc++-6.dll"
  Delete "$INSTDIR\License.txt"
  Delete "$INSTDIR\luadchpp.dll"
  Delete "$INSTDIR\pyadchpp.py"
  Delete "$INSTDIR\Script.dll"
  Delete "$INSTDIR\readme.txt"
  Delete "$INSTDIR\FirstReg.cmd"
  Delete "$INSTDIR\Generate_certs.cmd"
  Delete "$INSTDIR\Scripts\access.lua"
  Delete "$INSTDIR\Scripts\access.bans.lua"
  Delete "$INSTDIR\Scripts\access.bot.lua"
  Delete "$INSTDIR\Scripts\access.guard.lua"
  Delete "$INSTDIR\Scripts\access.limits.lua"
  Delete "$INSTDIR\Scripts\access.limits.lua.old"
  Delete "$INSTDIR\Scripts\access.op.lua"
  Delete "$INSTDIR\Scripts\aio.lua"
  Delete "$INSTDIR\Scripts\autil.lua"
  Delete "$INSTDIR\Scripts\example.lua"
  Delete "$INSTDIR\Scripts\history.lua"
  Delete "$INSTDIR\Scripts\json.lua"
  Delete "$INSTDIR\Scripts\motd.lua"
  Delete "$INSTDIR\Docs\images\icons\*.*"
  Delete "$INSTDIR\Docs\images\*.*"
  Delete "$INSTDIR\Docs\*.*"
  Delete "$INSTDIR\uninst.exe"

  Delete "$SMPROGRAMS\ADCH++\Uninstall.lnk"
  Delete "$SMPROGRAMS\ADCH++\ADCH++.lnk"
  Delete "$SMPROGRAMS\ADCH++\Website.lnk"
  Delete "$SMPROGRAMS\ADCH++\ADCH++ Help.lnk"
  Delete "$SMPROGRAMS\ADCH++\Remove ADCH++ windows service.lnk"
  Delete "$SMPROGRAMS\ADCH++\Install ADCH++ as windows service.lnk"
  Delete "$DESKTOP\ADCH++.lnk"

  RMDir "$SMPROGRAMS\ADCH++"
  RMDir "$INSTDIR\Scripts\FL_Database"
  RMDir "$INSTDIR\Scripts"
  RMDir "$INSTDIR\config\logs"
  RMDir "$INSTDIR\config"
  RMDir "$INSTDIR\Docs\images\icons"
  RMDir "$INSTDIR\Docs\images"
  RMDir "$INSTDIR\Docs"
  RMDir "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
