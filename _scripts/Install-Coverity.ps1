Get-ChildItem -Path (Join-Path $env:DEVBOX_HOME 'Modules') -Directory | Select-Object -ExpandProperty FullName | ForEach-Object {
    Write-Host ">>> Importing PowerShell Module: $_"
    Import-Module -Name $_
} 

# if (Test-IsPacker) {
# 	Write-Host ">>> Register ActiveSetup"
# 	Register-ActiveSetup -Path $MyInvocation.MyCommand.Path -Name 'Install-nvm.ps1'
# } else { 
#     Write-Host ">>> Initializing transcript"
#     Start-Transcript -Path ([system.io.path]::ChangeExtension($MyInvocation.MyCommand.Path, ".log")) -Append -Force -IncludeInvocationHeader; 
# }

$ProgressPreference = 'SilentlyContinue'	# hide any progress output
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# extract app files
$ArtifactsPath = (Join-Path $env:DEVBOX_HOME 'Artifacts')
$InstallerPath = Join-Path $ArtifactsPath "coverity.zip"
$DestPath = Join-Path -path $env:ProgramFiles -ChildPath 'Coverity'

if ( Test-Path -PathType Leaf "$InstallerPath") {
    Write-Host ">>> Installing Coverity"

    Write-Host ">>> Extracting $InstallerPath to folder $DestPath"
    
    Expand-Archive -Path $InstallerPath -DestinationPath $DestPath -Force

    Write-Host ">>> Append coverity to system PATH"
    [Environment]::SetEnvironmentVariable("COVERITY_TOOL_HOME", $DestPath, [System.EnvironmentVariableTarget]::Machine)

    $MACHINE_PATH = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("PATH", "$MACHINE_PATH$DestPath\bin", [System.EnvironmentVariableTarget]::Machine)

    $filename = Join-Path $ArtifactsPath "license.dat"
    Move-Item $filename -Destination "$DestPath\bin" -Force

    $binpath = "$DestPath\bin"
    Write-Host ">>> run configuration tasks ..."
    & "$binpath\cov-configure.exe" -java
    & "$binpath\cov-configure.exe" -javascript
    & "$binpath\cov-configure.exe" -python
    & "$binpath\cov-configure.exe" -go
    & "$binpath\cov-configure.exe" -gcc
    & "$binpath\cov-configure.exe" -msvc
    & "$binpath\cov-configure.exe" -cs
    & "$binpath\cov-configure.exe" -vb
    & "$binpath\cov-configure.exe" -php
    & "$binpath\cov-configure.exe" -ruby
    & "$binpath\cov-configure.exe" -scala
    & "$binpath\cov-configure.exe" -kotlin

    Write-Host ">>> coverity installation ready"
}

