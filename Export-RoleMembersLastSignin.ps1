<# 
.SYNOPSIS
  Export Entra ID (Azure AD) directory role members (users only) with DisplayName, Email, UPN, and Last Sign-In.

.NOTES
  - Works in Windows PowerShell 5.1.
  - Uses Invoke-MgGraphRequest to reliably select signInActivity.
  - Use -ExpandGroups to expand group-assigned roles into individual users.

# Users only (skip groups/SPs):
.\Export-RoleMembersLastSignIn.ps1 -OutFile "M365PrivilegedRoles.csv"

# Expand group-assigned role members to individual users:
.\Export-RoleMembersLastSignIn.ps1 -ExpandGroups -OutFile "M365PrivilegedRoles.csv"

#>

param(
  [switch] $ExpandGroups,
  [string] $OutFile = ".\RoleMembersWithLastSignIn.csv",
  [int]    $PauseMs = 150   # small pause to be gentle with Graph
)
function Ensure-Modules {
    param(
        [string[]] $Modules = @("ImportExcel", "Microsoft.Graph")
    )

    foreach ($m in $Modules) {
        Write-Host "Checking module: $m ..." -ForegroundColor Cyan
        $installed = Get-Module -ListAvailable -Name $m

        if (-not $installed) {
            Write-Warning "$m not found. Installing..."
            try {
                Install-Module -Name $m -Scope AllUsers -Force -AllowClobber -ErrorAction Stop
                Write-Host "$m installed successfully." -ForegroundColor Green
            }
            catch {
                $msg = $_.Exception.Message
                Write-Error ("Failed to install {0}: {1}" -f $m, $msg)
                continue
            }
        }
        else {
            Write-Host "$m already installed." -ForegroundColor Green
        }

        try {
            Import-Module $m -ErrorAction Stop
            Write-Host "$m imported successfully." -ForegroundColor Green
        }
        catch {
            $msg = $_.Exception.Message
            Write-Error ("Failed to import {0}: {1}" -f $m, $msg)
        }
    }
}

Ensure-Modules

# Connect
$scopes = @("Directory.Read.All","AuditLog.Read.All")
Connect-MgGraph -Scopes $scopes -NoWelcome | Out-Null

# Helper: GET /v1.0/users/{id}?$select=...
function Get-GraphUserLite {
  param([Parameter(Mandatory)][string] $UserId)

  $select = "id,displayName,userPrincipalName,mail,signInActivity"
  $uri    = "/v1.0/users/$UserId`?`$select=$select"

  # Basic retry on transient errors / throttling
  for ($i=0; $i -lt 3; $i++) {
    try {
      $resp = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
      return $resp
    } catch {
      if ($_.Exception.Message -match 'TooManyRequests|throttle|temporar') {
        Start-Sleep -Seconds (2 * ($i + 1))
        continue
      } else {
        Write-Warning ("User lookup failed for {0}: {1}" -f $UserId, $_.Exception.Message)
        return $null
      }
    }
  }
  return $null
}

# Helper: expand users from a group (no recursion by default)
function Get-UsersFromGroup {
  param([string] $GroupId)
  $users = @()
  $members = Get-MgGroupMember -GroupId $GroupId -All -ErrorAction SilentlyContinue
  foreach ($m in $members) {
    $t = $m.AdditionalProperties.'@odata.type'
    if ($t -eq "#microsoft.graph.user") { $users += $m }
    # To recurse into nested groups, call Get-UsersFromGroup again here.
  }
  return $users
}

# Get active roles
$roles = Get-MgDirectoryRole -All
if (-not $roles) {
  Write-Warning "No active directory roles found."
  return
}

$rows = New-Object System.Collections.Generic.List[object]

foreach ($role in $roles) {
  Write-Host "Processing role: $($role.DisplayName)" -ForegroundColor Yellow

  $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id -All -ErrorAction SilentlyContinue
  if (-not $members) { continue }

  foreach ($m in $members) {
    $type = $m.AdditionalProperties.'@odata.type'

    if ($type -eq "#microsoft.graph.user") {
      $u = Get-GraphUserLite -UserId $m.Id
      Start-Sleep -Milliseconds $PauseMs

      $disp = $null; $upn = $null; $mail = $null; $lastInt = $null; $lastNonInt = $null
      if ($u) {
        $disp = $u.displayName
        $upn  = $u.userPrincipalName
        $mail = $u.mail
        if ($u.signInActivity) {
          $lastInt    = $u.signInActivity.lastSignInDateTime
          $lastNonInt = $u.signInActivity.lastNonInteractiveSignInDateTime
        }
      }

      $rows.Add([pscustomobject]@{
        RoleName                 = $role.DisplayName
        UserDisplayName          = $disp
        UserEmail                = $mail
        UserPrincipalName        = $upn
        LastInteractiveSignIn    = $lastInt
        LastNonInteractiveSignIn = $lastNonInt
      })
    }
    elseif ($type -eq "#microsoft.graph.group" -and $ExpandGroups) {
      $groupUsers = Get-UsersFromGroup -GroupId $m.Id
      foreach ($gu in $groupUsers) {
        $u = Get-GraphUserLite -UserId $gu.Id
        Start-Sleep -Milliseconds $PauseMs

        $disp = $null; $upn = $null; $mail = $null; $lastInt = $null; $lastNonInt = $null
        if ($u) {
          $disp = $u.displayName
          $upn  = $u.userPrincipalName
          $mail = $u.mail
          if ($u.signInActivity) {
            $lastInt    = $u.signInActivity.lastSignInDateTime
            $lastNonInt = $u.signInActivity.lastNonInteractiveSignInDateTime
          }
        }

        $rows.Add([pscustomobject]@{
          RoleName                 = $role.DisplayName
          UserDisplayName          = $disp
          UserEmail                = $mail
          UserPrincipalName        = $upn
          LastInteractiveSignIn    = $lastInt
          LastNonInteractiveSignIn = $lastNonInt
        })
      }
    }
    else {
      # skip groups/SPs unless -ExpandGroups, to keep the CSV focused on actual users w/ email
      continue
    }
  }
}

# Export tidy user-focused CSV
$rows |
  Sort-Object RoleName, UserDisplayName, UserPrincipalName |
  Export-Csv -Path $OutFile -NoTypeInformation -Encoding UTF8

Write-Host "Done. Exported to $OutFile" -ForegroundColor Green
