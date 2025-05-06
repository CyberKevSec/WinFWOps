#Requires -Version 5.0
#Requires -Modules NetSecurity
#Requires -RunAsAdministrator

# --- Step 1: Delete all existing outbound firewall rules ---
Write-Host "Attempting to remove all existing outbound firewall rules..."
$existingOutboundRules = Get-NetFirewallRule -Direction Outbound -ErrorAction SilentlyContinue
if ($existingOutboundRules) {
    $existingOutboundRules | Remove-NetFirewallRule -Confirm:$false -ErrorAction Continue
    Write-Host "All existing outbound firewall rules have been removed."
} else {
    Write-Host "No existing outbound firewall rules found to remove."
}

# --- Step 2: Set the default outbound action to Block for all profiles ---
Write-Host "Setting default outbound connection to 'Block' for Domain, Private, and Public profiles..."
Set-NetFirewallProfile -Profile Domain, Private, Public -DefaultOutboundAction Block -Confirm:$false -ErrorAction Stop
Write-Host "Default outbound action set to 'Block'."

# --- Step 3: Create rule to allow outbound HTTPS traffic on TCP port 443 ---
Write-Host "Creating rule to allow outbound TCP port 443 (HTTPS)..."
New-NetFirewallRule -DisplayName "Allow Outbound HTTPS (TCP 443)" -Direction Outbound -Action Allow -Protocol TCP -RemotePort 443 -Enabled True -Confirm:$false -ErrorAction Stop
Write-Host "Rule for outbound TCP port 443 created."

# --- Step 4: Create rule to allow outbound DNS traffic on UDP port 53 ---
Write-Host "Creating rule to allow outbound UDP port 53 (DNS)..."
New-NetFirewallRule -DisplayName "Allow Outbound DNS (UDP 53)" -Direction Outbound -Action Allow -Protocol UDP -RemotePort 53 -Enabled True -Confirm:$false -ErrorAction Stop
Write-Host "Rule for outbound UDP port 53 created."

# --- Step 5: Create rules to allow Windows Update services ---
Write-Host "Creating rules to allow Windows Update services..."

# Rule for Windows Update Service (wuauserv) via svchost.exe
New-NetFirewallRule -DisplayName "Allow Outbound Windows Update (svchost - wuauserv)" -Direction Outbound -Action Allow -Program "%SystemRoot%\System32\svchost.exe" -Service "wuauserv" -Protocol TCP -RemotePort 80,443 -Enabled True -Confirm:$false -ErrorAction Stop
New-NetFirewallRule -DisplayName "Allow Outbound Windows Update (svchost - wuauserv - UDP)" -Direction Outbound -Action Allow -Program "%SystemRoot%\System32\svchost.exe" -Service "wuauserv" -Protocol UDP -RemotePort 80,443 -Enabled True -Confirm:$false -ErrorAction Stop # Though less common, including for completeness

# Rule for Background Intelligent Transfer Service (BITS) via svchost.exe
New-NetFirewallRule -DisplayName "Allow Outbound BITS (svchost - BITS)" -Direction Outbound -Action Allow -Program "%SystemRoot%\System32\svchost.exe" -Service "BITS" -Protocol TCP -RemotePort 80,443 -Enabled True -Confirm:$false -ErrorAction Stop
New-NetFirewallRule -DisplayName "Allow Outbound BITS (svchost - BITS - UDP)" -Direction Outbound -Action Allow -Program "%SystemRoot%\System32\svchost.exe" -Service "BITS" -Protocol UDP -RemotePort 80,443 -Enabled True -Confirm:$false -ErrorAction Stop # Though less common, including for completeness

# Rule for Delivery Optimization Service (DoSvc) via svchost.exe
New-NetFirewallRule -DisplayName "Allow Outbound Delivery Optimization (svchost - DoSvc)" -Direction Outbound -Action Allow -Program "%SystemRoot%\System32\svchost.exe" -Service "DoSvc" -Protocol TCP -RemotePort 80,443 -Enabled True -Confirm:$false -ErrorAction Stop
New-NetFirewallRule -DisplayName "Allow Outbound Delivery Optimization (svchost - DoSvc - UDP)" -Direction Outbound -Action Allow -Program "%SystemRoot%\System32\svchost.exe" -Service "DoSvc" -Protocol UDP -RemotePort 80,443 -Enabled True -Confirm:$false -ErrorAction Stop # Though less common, including for completeness

# Rule for Windows Update Client (wuauclt.exe - though often svchost is primary, some operations might still use this)
# Note: wuauclt.exe is less central in modern Windows versions but including for broader compatibility.
# Modern Windows Update primarily uses services hosted in svchost.exe.
# Consider this rule optional if strictly limiting svchost-based rules.
# New-NetFirewallRule -DisplayName "Allow Outbound Windows Update Client (wuauclt)" -Direction Outbound -Action Allow -Program "%SystemRoot%\System32\wuauclt.exe" -Protocol TCP -RemotePort 80,443 -Enabled True -Confirm:$false -ErrorAction Stop

Write-Host "Rules for Windows Update services created."
Write-Host "Firewall automation script execution completed."
Write-Host "Please verify your firewall configuration and test network connectivity for essential applications."
