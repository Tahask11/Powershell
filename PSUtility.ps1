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
