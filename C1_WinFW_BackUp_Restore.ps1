#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Restores Windows Defender Firewall policy from a backup file.
.DESCRIPTION
    This script automates the process of importing a Windows Defender Firewall
    policy from a specified .wfw backup file. It requires administrative
    privileges to run.
.PARAMETER BackupFilePath
    The full path to the .wfw firewall policy backup file.
.EXAMPLE
    .\Restore-FirewallPolicy.ps1 -BackupFilePath "C:\FirewallBackup\MyFirewallPolicy.wfw"
    This command will attempt to restore the firewall policy from the specified file.
.NOTES
    Author: CyberKevSec
    Date: 2025-05-06
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$BackupFilePath
)

# Check for administrative privileges (already handled by #Requires -RunAsAdministrator but good for explicit check if needed)
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges are required to restore the firewall policy. Please run the script as an Administrator."
    exit 1
}

# Check if the backup file exists
if (-NOT (Test-Path -Path $BackupFilePath -PathType Leaf)) {
    Write-Error "The specified backup file does not exist: $BackupFilePath"
    exit 1
}

# Confirm with the user before proceeding
$confirmation = Read-Host "Are you sure you want to restore the Windows Defender Firewall policy from '$BackupFilePath'? This will overwrite all current firewall policies. (Y/N)"
if ($confirmation -ne 'Y') {
    Write-Host "Firewall policy restoration cancelled by the user."
    exit 0
}

Write-Host "Attempting to restore Windows Defender Firewall policy from: $BackupFilePath"

# Construct the netsh command
$command = "netsh advfirewall import `"$BackupFilePath`""

# Execute the command
try {
    Write-Host "Executing command: $command"
    Invoke-Expression $command
    Write-Host "Windows Defender Firewall policy has been successfully restored."
    Write-Host "It's recommended to verify the firewall configuration in 'Windows Defender Firewall with Advanced Security'."
}
catch {
    Write-Error "An error occurred while restoring the firewall policy: $($_.Exception.Message)"
    Write-Error "Please ensure the backup file is valid and you have the necessary permissions."
    exit 1
}

exit 0
