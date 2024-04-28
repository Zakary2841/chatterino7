; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Chatterino7"
#define MyAppVersion "7.5.1"
#define MyAppPublisher "7TV"
#define MyAppURL "https://www.chatterino.com"
#define MyAppExeName "chatterino.exe"

; used in build-installer.ps1
; if set, must end in a backslash
#ifndef WORKING_DIR
#define WORKING_DIR ""
#endif

; Set to the build part of the VCRT version
#ifndef SHIPPED_VCRT_BUILD
#define SHIPPED_VCRT_BUILD 0
#endif
; Set to the string representation of the VCRT version
#ifndef SHIPPED_VCRT_VERSION
#define SHIPPED_VCRT_VERSION ?
#endif

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{F5FE6614-04D4-4D32-8600-0ABA0AC113A4}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
VersionInfoVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
ArchitecturesInstallIn64BitMode=x64
;Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=out
; This is defined by the build-installer.ps1 script,
; but kept optional for regular use.
#ifdef INSTALLER_BASE_NAME
OutputBaseFilename={#INSTALLER_BASE_NAME}
#else
OutputBaseFilename=Chatterino7.Installer
#endif
Compression=lzma
SolidCompression=yes
WizardStyle=modern
UsePreviousTasks=no
UninstallDisplayIcon={app}\{#MyAppExeName}
RestartIfNeededByRun=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

#ifdef IS_NIGHTLY
[Messages]
SetupAppTitle=Setup (Nightly)
SetupWindowTitle=Setup - %1 (Nightly)
#endif

[Tasks]
; Only show this option if the VCRT can be updated.
Name: "vcredist"; Description: "Install the required {#SHIPPED_VCRT_VERSION} ({code:VCRTDescription})"; Check: NeedsNewVCRT();
; GroupDescription: "{cm:AdditionalIcons}"; 
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; Flags: unchecked
Name: "freshinstall"; Description: "Fresh install (delete old settings/logs)"; Flags: unchecked

[Files]
Source: "{#WORKING_DIR}Chatterino2\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#WORKING_DIR}vc_redist.x64.exe"; DestDir: "{tmp}"; Tasks: vcredist;
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
; VC++ redistributable
Filename: {tmp}\vc_redist.x64.exe; Parameters: "/install /passive /norestart"; StatusMsg: "Installing 64-bit Windows Universal Runtime..."; Flags: waituntilterminated; Tasks: vcredist
; Run chatterino
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[InstallDelete]
; Delete cache on install
Type: filesandordirs; Name: "{userappdata}\Chatterino2\Cache"
; Delete %appdata%\Chatterino2 on freshinstall
Type: filesandordirs; Name: "{userappdata}\Chatterino2"; Tasks: freshinstall

[UninstallDelete]
; Delete cache on uninstall
Type: filesandordirs; Name: "{userappdata}\Chatterino2\Cache"

[Code]
// Get the VCRT version as a string. Null if the version could not be found.
function GetVCRT(): Variant;
var
  VCRTVersion: String;
begin
  Result := Null;
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', VCRTVersion) then
    Result := VCRTVersion;
end;

// Gets a description about the VCRT installed vs shipped.
// This doesn't compare the versions.
function VCRTDescription(Param: String): String;
var
  VCRTVersion: Variant;
begin
  VCRTVersion := GetVCRT;
  if VarIsNull(VCRTVersion) then
    Result := 'none is installed'
  else
    Result := VCRTVersion + ' is installed';
end;

// Checks if a new VCRT is needed by comparing the builds.
function NeedsNewVCRT(): Boolean;
var
  VCRTBuild: Cardinal;
begin
  Result := True;
  if RegQueryDWordValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Bld', VCRTBuild) then
  begin
    if VCRTBuild >= {#SHIPPED_VCRT_BUILD} then
        Result := False;
  end;
end;
