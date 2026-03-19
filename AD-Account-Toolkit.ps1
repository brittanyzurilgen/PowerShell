# Check if Active Directory module is available
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Active Directory module is not installed or available." -ForegroundColor Red
    Write-Host "Please run this script on a system with RSAT / AD tools installed." -ForegroundColor Yellow
    exit
}

Import-Module ActiveDirectory

function Show-Menu {
    Clear-Host
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host " Active Directory Account Audit Toolkit" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "1. Show locked accounts"
    Write-Host "2. Unlock a specific user account"
    Write-Host "3. Show expired accounts"
    Write-Host "4. Show inactive accounts (30+ days)"
    Write-Host "5. Exit"
    Write-Host ""
}

function Show-LockedAccounts {
    Write-Host "`nRetrieving locked accounts..." -ForegroundColor Yellow

    try {
        $lockedUsers = Search-ADAccount -LockedOut | Select-Object Name, SamAccountName

        if ($lockedUsers) {
            $lockedUsers | Format-Table -AutoSize
        }
        else {
            Write-Host "No locked accounts were found." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error retrieving locked accounts: $($_.Exception.Message)" -ForegroundColor Red
    }

    Pause
}

function Unlock-UserAccountTool {
    $username = Read-Host "`nEnter the SamAccountName of the user to unlock"

    try {
        $user = Get-ADUser -Identity $username -ErrorAction Stop

        Unlock-ADAccount -Identity $username -ErrorAction Stop
        Write-Host "Account '$username' has been unlocked successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Unable to unlock account '$username'. Please verify the username." -ForegroundColor Red
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    Pause
}

function Show-ExpiredAccounts {
    Write-Host "`nRetrieving expired accounts..." -ForegroundColor Yellow

    try {
        $expiredUsers = Search-ADAccount -AccountExpired | Select-Object Name, SamAccountName

        if ($expiredUsers) {
            $expiredUsers | Format-Table -AutoSize
        }
        else {
            Write-Host "No expired accounts were found." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error retrieving expired accounts: $($_.Exception.Message)" -ForegroundColor Red
    }

    Pause
}

function Show-InactiveAccounts {
    Write-Host "`nRetrieving inactive accounts older than 30 days..." -ForegroundColor Yellow

    try {
        $inactiveUsers = Search-ADAccount -AccountInactive -TimeSpan 30.00:00:00 -UsersOnly |
            Select-Object Name, SamAccountName

        if ($inactiveUsers) {
            $inactiveUsers | Format-Table -AutoSize
        }
        else {
            Write-Host "No inactive accounts older than 30 days were found." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error retrieving inactive accounts: $($_.Exception.Message)" -ForegroundColor Red
    }

    Pause
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-5)"

    switch ($choice) {
        "1" { Show-LockedAccounts }
        "2" { Unlock-UserAccountTool }
        "3" { Show-ExpiredAccounts }
        "4" { Show-InactiveAccounts }
        "5" {
            Write-Host "`nExiting script. Goodbye!" -ForegroundColor Cyan
        }
        default {
            Write-Host "`nInvalid selection. Please enter a number from 1 to 5." -ForegroundColor Red
            Pause
        }
    }
}
while ($choice -ne "5")
