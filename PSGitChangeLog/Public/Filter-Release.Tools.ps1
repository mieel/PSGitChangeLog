Function Get-FilteredRelease {
    <#
        .EXAMPLE
            $Releases = Get-GitTagList -TagPrefix WebApp
            Get-FilteredRelease -Major 6 -Releases $Releases
    #>
    Param (
        $Major
        ,
        $Minor
        ,
        $Latest
        ,
        [Parameter(Mandatory)]
        $Releases
    )
    $CurrentMajor = $Releases.Major | Select-Object -first 1
    $CurrentMinor = ($Releases | Where-Object { $_.Major -eq $Major } ).Minor | Select-Object -first 1
    If ($Latest) {
        Write-Information "Getting Releases of Latest $Latest, current Major:$CurrentMajor, Minor:$CurrentMinor"
        If ($Latest -eq 'Build') {
            $Releases = $Releases | Select-Object -first 1
        } ElseIf ($Latest -eq 'Major') {

            Write-Information "$latest $major"
            $Releases = $Releases | Where-Object { $_.Major -eq $CurrentMajor }
        } ElseIf ($Latest -eq 'Minor') {
            Write-Information "$latest $Major.$Minor"
            $Releases = $Releases | Where-Object { $_.Major -eq $CurrentMajor -and $_.Minor -eq $CurrentMinor }
        }
    }
    If ($Major) {
        $Releases = $Releases | Where-Object { $_.Major -eq $Major }
    }
    If ($Minor) {
        $Releases = $Releases | Where-Object { $_.Major -eq $Major -and $_.Minor -eq $Minor }
    }
    Write-Output $Releases
}