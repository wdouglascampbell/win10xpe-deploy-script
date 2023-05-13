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
if (Test-Path -Path $buildDir) {
  Write-Warning "The build area for Win10XPE exists."
  Write-Warning "All previous content will be removed." -WarningAction Inquire
  Remove-Item "$buildDir" -Recurse
}

# Create directory for Win10XPE build area
New-Item -ItemType Directory -Path "$buildDir" | Out-Null

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

# Remove Extracted Win10XPE Archive
Write-Host -NoNewLine "Removing extracted Win10XPE archive... "
Remove-Item "$buildDir\Win10XPE-$releaseTag" -Recurse
Write-Host "Done"

# Done
Write-Host "Win10XPE installation is complete."
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');