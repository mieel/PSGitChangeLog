Function Get-GitChangeLog {
    [cmdletbinding()]
    Param (
        [Parameter(ValueFromPipeline)]
        $InputObject
        ,
        [ValidateSet("Public", "Internal")]
        [string]
        $Audience
        ,
        [string]
        $WorkDir
        ,
        [int]
        $RequiredCommitMessageLength = 5
        ,
        [string]
        $ProjectName
        ,
        [string]
        $TagPrefix
        ,
        [string]
        $RemoteName = 'origin'
        ,
        [ValidateSet("psobject", "json", "md", "html")]
        [string]
        $OutputAs = 'md'
        ,
        [ValidateSet("Major", "Minor", "Build")]
        [String]
        $Latest = ''
        # Specify to retrieve the latest Major, Minor, Build
        ,
        [int]
        $Major
        ,
        [int]
        $Minor
        ,
        [switch]
        $toChangelog
        ,
        [int]
        $FetchDepth = 500
    )
    If (!$Logs) {
        $logs = Get-GitHistory -TagPrefix $tagPrefix -FetchDepth $FetchDepth
    }
    $Releases = Get-GitTagList -TagPrefix $TagPrefix

    If ($Audience -eq 'Public' ) {
        $logs = $logs | Where-Object { $_.IntentAudience -ne 'Internal' }
    }

    $Releasedata = @()
    $filterReleaseParams =@{}
    
    If ($Latest) {
        $filterReleaseParams.Add('Latest',$Latest)
    }
    If ($Major) {
        $filterReleaseParams.Add('Major',$Major)
    }
    If ($Minor) {
        $filterReleaseParams.Add('Minor',$Minor)
    }
    If ($filterReleaseParams) {
        $Releases = Get-FilteredRelease @filterReleaseParams -Releases $Releases
    }
    # Print unreleased changes first if any
    If ($logs | Where-Object { $_.Release -eq 'Unreleased' } ) {
        $Releasedata += [ordered]@{
            Release       = 'Unreleased'
            ReleaseDate   = ''
            Component     = ''
            Version       = ''
            ReleaseCommit = git log --format="%H" -n 1
            Commits       = $logs | Where-Object { $_.Release -eq 'Unreleased' } | SOrt-Object -Property Order | Select-Object -Property * -ExcludeProperty Project, Release, Order
        }
    }

    Write-Information $Releases.Count Releases
    $Releasedata += ForEach ($Release in $Releases) {
        [ordered]@{
            Release       = $Release.Tag
            ReleaseDate   = $Release.Date
            Component     = $Release.Component
            Version       = [string]$Release.SemVerId
            ReleaseCommit = $Release.Commit
            Commits       = $logs | Where-Object { $_.Release -eq $Release.Tag } | SOrt-Object -Property Order | Select-Object -Property * -ExcludeProperty Project, Release, Order
        }
    }

    $ChangelogObject = @{
        Project  = $ProjectName
        Releases = $Releasedata
    }

    If ($OutputAs -eq 'psobject') {
        Return $ChangelogObject
    }


    If ($OutputAs -eq 'json') {
        Return ($ChangelogObject | ConvertTo-Json -depth 4)
    }
    If ($OutputAs -eq 'md') {
        $Changelog = ConvertTo-Changelog($ChangelogObject) -FormatAs md
        Return $Changelog
    } elseif ($OutputAs -eq 'html') {
        $Changelog = ConvertTo-Changelog($ChangelogObject) -FormatAs html
        Return $Changelog
    }
}
