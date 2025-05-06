<#
.SYNOPSIS
    Backs up the Windows Firewall policy.
.DESCRIPTION
    This script exports the current Windows Firewall policy to a specified backup location.
    It creates a uniquely named backup file using a timestamp.
.NOTES
    Version: 1.0
    Author: CyberKevSec
    Creation Date: 2025-05-06
    Purpose: To automate the backup of Windows Firewall rules.
    Ensure you have administrative privileges to run this script and write to the backup path.
#>

# --- Configuration ---
# Specify the directory where you want to store the firewall backups. 
# This location will automatically get created if it doesnt exist.

$BackupPath = "C:\FirewallBackups" # Example: "D:\Backups\Firewall"

# --- Script Body ---

# Check if the backup directory exists. If not, create it.
if (-not (Test-Path -Path $BackupPath -PathType Container)) {
    try {
        New-Item -ItemType Directory -Path $BackupPath -Force -ErrorAction Stop
        Write-Host "Successfully created backup directory: $BackupPath"
    }
    catch {
        Write-Error "Failed to create backup directory: $BackupPath. Please create it manually and ensure you have write permissions. Error: $($_.Exception.Message)"
        exit 1 # Exit the script if directory creation fails
    }
}

# Create a filename with the current date and time to ensure uniqueness.
$DateTime = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupFile = Join-Path -Path $BackupPath -ChildPath "FirewallPolicy_Backup_$($DateTime).wfw"

# Command to export the firewall policy.
# 'netsh advfirewall export' is the command-line tool used for this.
$ExportCommand = "netsh advfirewall export `"$($BackupFile)`""

Write-Host "Starting Windows Firewall policy backup..."
Write-Host "Backup file will be saved to: $($BackupFile)"

try {
    # Execute the export command.
    # We use Invoke-Expression to run the command string.
    # ErrorAction Stop will turn script-terminating errors for this command.
    Invoke-Expression -Command $ExportCommand -ErrorAction Stop

    # Check if the backup file was created successfully.
    if (Test-Path -Path $BackupFile -PathType Leaf) {
        Write-Host "Firewall policy successfully backed up to: $($BackupFile)"
        Write-Host "Backup size: $((Get-Item $BackupFile).Length / 1KB) KB"
    }
    else {
        Write-Error "Firewall policy backup failed. The backup file was not created."
    }
}
catch {
    # Catch any errors during the export process.
    Write-Error "An error occurred during firewall policy backup: $($_.Exception.Message)"
    # You might want to add more detailed error logging here, e.g., to a log file.
}

Write-Host "Firewall backup script finished."

# --- End of Script ---
