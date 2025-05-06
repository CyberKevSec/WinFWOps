#Requires -RunAsAdministrator

# --- Script to manage Windows Defender Firewall rules ---
#
# This script performs two main actions:
# 1. Deletes all existing inbound firewall rules.
# 2. Creates a new inbound firewall rule to block all incoming traffic.
#
# WARNING: Running this script will significantly alter your firewall configuration.
# Blocking all incoming traffic can disrupt network connectivity for applications
# and services on this computer. Ensure you understand the implications before proceeding.

# --- Function to check for Administrator Privileges ---
function Test-IsAdmin {
    try {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        Write-Error "Error checking administrator privileges: $($_.Exception.Message)"
        return $false
    }
}

# --- Main Script Logic ---

# Check if the script is running with Administrator privileges
if (-not (Test-IsAdmin)) {
    Write-Error "This script must be run with Administrator privileges. Please re-run PowerShell as Administrator."
    # Attempt to re-launch the script as Administrator
    try {
        $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
        $newProcess.Arguments = "-File `"$($MyInvocation.MyCommand.Path)`""
        $newProcess.Verb = "runas"
        [System.Diagnostics.Process]::Start($newProcess) | Out-Null
        Write-Host "Attempting to re-launch script with Administrator privileges..."
        exit
    }
    catch {
        Write-Error "Failed to re-launch script as Administrator: $($_.Exception.Message)"
        exit 1
    }
}

Write-Host "--------------------------------------------------------------------"
Write-Host " Windows Defender Firewall Rule Automation Script for Incoming Traffic "
Write-Host "--------------------------------------------------------------------"
Write-Host ""
Write-Host "WARNING: This script will delete ALL current incoming firewall rules"
Write-Host "and then create a new rule to BLOCK ALL incoming traffic."
Write-Host "This can affect your computer's ability to receive network connections."
Write-Host ""

# --- Confirmation before proceeding ---
$confirmation = Read-Host "Are you sure you want to proceed? (Yes/No)"

if ($confirmation -ne 'Yes') {
    Write-Host "Operation cancelled by the user."
    exit
}

# --- Action 1: Delete all current incoming firewall rules ---
Write-Host ""
Write-Host "Step 1: Deleting all existing incoming firewall rules..."
try {
    # Get all inbound rules
    $inboundRules = Get-NetFirewallRule -Direction Inbound -ErrorAction Stop

    if ($inboundRules) {
        Write-Host "Found $($inboundRules.Count) incoming rules to delete."
        # Remove each rule.
        # -ErrorAction SilentlyContinue will suppress errors for rules that cannot be removed (e.g., system default, GPO managed)
        # We iterate to provide more granular feedback, though a single pipe to Remove-NetFirewallRule is also possible.
        foreach ($rule in $inboundRules) {
            try {
                Write-Host "Deleting rule: $($rule.DisplayName) ($($rule.Name))"
                $rule | Remove-NetFirewallRule -ErrorAction Stop
            }
            catch {
                Write-Warning "Could not delete rule '$($rule.DisplayName)' ($($rule.Name)). It might be a system rule or managed by Group Policy. Error: $($_.Exception.Message)"
            }
        }
        Write-Host "Finished attempting to delete incoming rules."
    } else {
        Write-Host "No existing incoming firewall rules found to delete."
    }
}
catch {
    Write-Error "An error occurred while trying to retrieve or delete firewall rules: $($_.Exception.Message)"
    # Optionally, you might want to exit here if rule deletion is critical before adding the block rule.
    # exit 1
}

# --- Action 2: Create a new rule to block all incoming traffic ---
Write-Host ""
Write-Host "Step 2: Creating a new firewall rule to block all incoming traffic..."

$ruleName = "BLOCK_ALL_IN"
$ruleDescription = "Blocks all unsolicited incoming network traffic. Created by PowerShell script on $(Get-Date)."

try {
    # Check if a rule with the same name already exists (e.g., from a previous run)
    $existingBlockRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    if ($existingBlockRule) {
        Write-Warning "A rule named '$ruleName' already exists. It will be removed and recreated."
        $existingBlockRule | Remove-NetFirewallRule -ErrorAction SilentlyContinue
    }

    New-NetFirewallRule -DisplayName $ruleName `
        -Description $ruleDescription `
        -Direction Inbound `
        -Profile Any `
        -Action Block `
        -Enabled True `
        -RemoteAddress Any `
        -LocalAddress Any `
        -Protocol Any `
        -ErrorAction Stop

    Write-Host "Successfully created firewall rule: '$ruleName'"
    Write-Host "This rule is now active and blocking all incoming traffic."
}
catch {
    Write-Error "Failed to create the 'Block All Incoming Traffic' rule: $($_.Exception.Message)"
    Write-Error "Your firewall might be in an inconsistent state. Please check Windows Defender Firewall settings."
    exit 1
}

Write-Host ""
Write-Host "--------------------------------------------------------------------"
Write-Host "Firewall automation script completed."
Write-Host "All incoming traffic is now configured to be blocked."
Write-Host "To revert, Use the backup file generated from A1_WinFW_BackUp.ps1."
Write-Host "--------------------------------------------------------------------"

# End of script
