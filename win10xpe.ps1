# check if running with Administrator privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (! $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  (get-host).UI.RawUI.Foregroundcolor="DarkRed"
  write-host "`nWarning: This script must be run as an Administrator.`n"
  (get-host).UI.RawUI.Foregroundcolor="White"
  exit
}

$buildDir="C:\Win10XPE_Build_Area"

# Clear display
Clear-Host

# Check if Win10XPE build area already exists
if (Test-Path -Path "$buildDir\Win10XPE") {
  Write-Warning "The Win10XPE directory exists."
  Write-Warning "All previous content will be removed." -WarningAction Inquire
  Remove-Item "$buildDir\Win10XPE" -Recurse
}

# Create directory for Win10XPE build area
New-Item -ItemType Directory -Path "$buildDir" -Force | Out-Null

# Exclude Win10XPE build area directory from Windows Defender scanning
Add-MpPreference -ExclusionPath "$buildDir"

# Download Current Win10XPE Release
Write-Host -NoNewLine "Downloading current Win10XPE release... "
$ProgressPreference = 'SilentlyContinue'
$releaseUrl = (Invoke-WebRequest https://github.com/ChrisRfr/Win10XPE/releases/latest -UseBasicParsing -MaximumRedirection 0 -ErrorAction Ignore).Headers.Location
$result = $releaseUrl -match '([^/]*)$'
$releaseTag = $matches[1]
Invoke-WebRequest -Uri "https://github.com/ChrisRfr/Win10XPE/archive/refs/tags/$releaseTag.zip" -OutFile "$buildDir\Win10XPE-$releaseTag.zip"
$ProgressPreference = 'Continue'
Write-Host "Done"

# Extract Win10XPE from Archive
Expand-Archive -path "$buildDir\Win10XPE-$releaseTag.zip" -DestinationPath "$buildDir"

# Install 7-Zip PowerShell Module
Write-Host -NoNewLine "Installing 7-Zip PowerShell module... "
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
Set-PSRepository -Name 'PSGallery' -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
if (!(Get-Module -ListAvailable -Name 7Zip4PowerShell)) {
  Install-Module -Name 7Zip4PowerShell -Force
}
Write-Host "Done"

# Extract Win10XPE
Expand-7Zip -ArchiveFileName "$buildDir\Win10XPE-$releaseTag\Win10XPE_2023-02-01.7z.001" -TargetPath "$buildDir"

## Apply fixes to Win10XPE
#$filePath = "$buildDir\Win10XPE\Projects\Win10XPE\Core.script"
#$tempFilePath = "$env:TEMP\$($filePath | Split-Path -Leaf)"
#(Get-Content -Path $filePath) -replace '10.0.19041.264', '10.0.19041.572' | Add-Content -Path $tempFilePath
#Remove-Item -Path $filePath
#Move-Item -Path $tempFilePath -Destination $filePath

# Add Custom Win10XPE Scripts
Write-Host -NoNewLine "Downloading custom Win10XPE scripts... "
New-Item -ItemType Directory -Path "$buildDir\Win10XPE\Projects\MyPlugins\Apps\Disk Encryption" | Out-Null
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri https://raw.githubusercontent.com/wdouglascampbell/win10xpe-bcrypt-script/main/bcve.script -Outfile "$buildDir\Win10XPE\Projects\MyPlugins\Apps\Disk Encryption\bcve.script"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/wdouglascampbell/win10xpe-veracrypt-script/main/VeraCrypt.script -Outfile "$buildDir\Win10XPE\Projects\MyPlugins\Apps\Disk Encryption\VeraCrypt.script"
$ProgressPreference = 'Continue'
Write-Host "Done"

# Remove Win10XPE Archive and Extracted Files
Write-Host -NoNewLine "Removing Win10XPE archive and extracted files... "
Remove-Item "$buildDir\Win10XPE-$releaseTag" -Recurse
Remove-Item "$buildDir\Win10XPE-$releaseTag.zip"
Write-Host "Done"

# Check if Win10Pro_v20H1 source files directory exists
if (-Not (Test-Path -Path "$buildDir\Win10Pro_v20H1")) {
#  # Download MediaCreationTool.bat
#  Write-Host -NoNewLine "Downloading MediaCreationTool.bat... "
#  Set-Location "$buildDir"
#  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/AveYo/MediaCreationTool.bat/main/MediaCreationTool.bat" -OutFile "$buildDir\pro iso 20H1 en-US x64 no_update def MediaCreationTool.bat"
#  Write-Host "Done"
#  Write-Host "`nThe Media Creation Tool will now be run to download the ISO image.  When it"
#  Write-Host "finishes you will need to click the Finish button to continue with the"
#  Write-Host "installation."
#  Write-Host -NoNewLine 'Press any key to begin download...';
#  $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
#
#  # Use MediaCreationTool.bat to retrieve Windows 10 20H1 ISO image
#  Write-Host -NoNewLine "`n`nDownloading Windows 10 20H1 ISO Image... "
#  Start-Process -FilePath '.\pro iso 20H1 en-US x64 no_update def MediaCreationTool.bat' -Wait
#  Remove-Item "C:\ESD" -Recurse
#  Remove-Item "$buildDir\pro iso 20H1 en-US x64 no_update def MediaCreationTool.bat"
#  Write-Host "Done"
#
#  # Extract ISO image files
#  Write-Host -NoNewLine "Extracting Files from Windows 10 20H1 ISO Image... "
#  $isoPath="$buildDir\10 20H1 Professional x64 en-US.iso"
#  $destFolder="$buildDir\Win10Pro_v20H1"
#  $driveLetter=(Mount-DiskImage -ImagePath $isoPath | Get-Volume).DriveLetter
#  New-Item -ItemType Directory -Path $destFolder | Out-Null
#  Copy-Item -Path $(($driveLetter,":\*") -join "") -Destination $destFolder -Recurse
#  Dismount-DiskImage -ImagePath $isoPath | Out-Null
#  Write-Host "Done"
#
#  # Remove ISO image
#  Remove-Item "$isoPath"
#  
#  # Export install.wim for Windows 10 Professional from install.esd
#  Write-Host -NoNewLine "Exporting install.wim from install.esd... "
#  Set-Location "$buildDir\Win10Pro_v20H1\sources"
#  Export-WindowsImage -SourceImagePath "install.esd" -SourceIndex 6 -DestinationImagePath "install.wim" -CheckIntegrity | Out-Null
#  Remove-Item "$buildDir\Win10Pro_v20H1\sources\install.esd" -Force | Out-Null
#  Write-Host "Done"
  # Extract uupdump_convert script archive
  Write-Host -NoNewLine "Extracting UUP Dump scripts from archive... "
  Expand-Archive -path "$PSScriptRoot\19041.264_amd64_en-us_professional_a52370fd_convert.zip" -DestinationPath "$PSScriptRoot\19041.264_amd64_en-us_professional_a52370fd_convert"
  Write-Host "Done"
  
  # Run UUP Dump Scripts
  Write-Host "Running UUP Dump scripts... "
  Start-Process -FilePath "$PSScriptRoot\19041.264_amd64_en-us_professional_a52370fd_convert\uup_download_windows.cmd" -Wait
  if (-Not (Test-Path -Path "$PSScriptRoot\19041.264_amd64_en-us_professional_a52370fd_convert\19041.1.191206-1406.VB_RELEASE_CLIENTPRO_OEMRET_X64FRE_EN-US.ISO" -PathType Leaf)) {
    Write-Error "There was an issue creating the Windows ISO image.  Please retry again later."
    Write-Host "Exiting..."
    Exit 1
  }
  
  # Extract ISO image files
  Write-Host -NoNewLine "Extracting Files from Windows 10 20H1 ISO Image... "
  $isoPath="$PSScriptRoot\19041.264_amd64_en-us_professional_a52370fd_convert\19041.1.191206-1406.VB_RELEASE_CLIENTPRO_OEMRET_X64FRE_EN-US.ISO"
  $destFolder="$buildDir\Win10Pro_v20H1"
  $driveLetter=(Mount-DiskImage -ImagePath $isoPath | Get-Volume).DriveLetter
  New-Item -ItemType Directory -Path $destFolder | Out-Null
  Copy-Item -Path $(($driveLetter,":\*") -join "") -Destination $destFolder -Recurse
  Dismount-DiskImage -ImagePath $isoPath | Out-Null
  Write-Host "Done"

  # Remove UUP Dump Scripts and Windows 10 20h1 ISO Image
  Remove-Item -Path "$PSScriptRoot\19041.264_amd64_en-us_professional_a52370fd_convert" -Recurse
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
