function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Severity = 'Information',

        [Parameter()]
        [ValidateScript({
                if ( (test-path (split-Path $_ -Parent)) -and ( (split-Path $_ -Leaf) -imatch ".csv") ) {
                    $true
                }
                else {
                    throw "Log path is not valid."
                }
            })]        
        $logpath = "./LogFile_$(get-date -Format 'yyyyMMdd').csv"
    )
    
    write-host "$(get-date -f g)`t$message"
    [pscustomobject]@{
        Time     = (Get-Date -f g)
        Message  = $Message
        Severity = $Severity
    } | Export-Csv -Path $logpath -Append -NoTypeInformation
}


#=====================================================================
# Get-MyCredential
#=====================================================================
function Get-MyCredential {
    param(
        $CredPath,
        [switch]$Help
    )
    $HelpText = @"

    Get-MyCredential
    Usage:
    Get-MyCredential -CredPath `$CredPath

    If a credential is stored in $CredPath, it will be used.
    If no credential is found, Export-Credential will start and offer to
    Store a credential at the location specified.

"@
    if ($Help -or (!($CredPath))) {
        write-host $Helptext; Break 
    }
    
    if (!(Test-Path -Path $CredPath -PathType Leaf)) {
        Export-Credential (Get-Credential) $CredPath
    }

    $cred = Import-Clixml $CredPath
    $cred.Password = $cred.Password | ConvertTo-SecureString
    $Credential = New-Object System.Management.Automation.PsCredential($cred.UserName, $cred.Password)
    Return $Credential
}

#=====================================================================
# Export-Credential
# Usage: Export-Credential $CredentialObject $FileToSaveTo
#=====================================================================
function Export-Credential($cred, $path) {
    $cred = $cred | Select-Object *
    $cred.password = $cred.Password | ConvertFrom-SecureString
    $cred | Export-Clixml $path
}

