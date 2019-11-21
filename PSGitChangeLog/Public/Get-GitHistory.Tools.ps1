Function Get-GitHistory {
    <#
        .SYNOPSIS
            Converts gitlog output into structured format
        .DESCRIPTION
            Gets Commit data from gitlog and gets Tags.
            Orders Commit by their tag and outputs in a list of objects or a nested json document (use -asJson)
            You can also specify to only output history from the latest major/minor/build.
        .EXAMPLE
            Get-GitHistory -TagPrefix WebApp -asJson
        .EXAMPLE
            $json = Get-GitHistory -asJson
        .EXAMPLE
            $json = Get-GitHistory -asJson -Latest Major
            $json = Get-GitHistory -asJson -Latest Minor
            $json = Get-GitHistory -asJson -Latest Build
    #>
    [cmdletbinding()]

    param(
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
        [ValidateSet("psobject", "json","md","html")]
        [string] 
        $OutputAs
        ,
        [String]
        $Latest = ''
        # Specify to retrieve the latest Major, Minor, Build
        ,
        [switch]
        $toChangelog
    )
    # Settings
    Begin {
        # Ensuring Encoding
        $env:LC_ALL = 'C.UTF-8'
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

        $CurrentBranch = $env:Build_SourceBranchName

        $config = Import-PowerShellDataFile -Path  $PSScriptRoot/../PSGitChangeLog.Config.psd1
        $Intents = $config.Intents
        
        $Omit = $config.Omit
    }
    Process {
        If (!$ProjectName) {
            $ProjectName = (Split-Path -Leaf (git remote get-url $RemoteName)).Replace('.git', '')
        }
        If ($WorkDir) { Set-Location $WorkDir }

        # Instantiate GitLog as an Object so that we can work with it
        If ($Latest) {
            $gitlog = (git log $CurrentBranch -500 --format="%ai`t%H`t%an`t%ae`t%s" )
        } Else {
            $gitlog = (git log --format="%ai`t%H`t%an`t%ae`t%s" )
        }
        $gitHist = $gitlog | ConvertFrom-Csv -Delimiter "`t" -Header ("Date", "CommitId", "Author", "Email", "Subject")

        $Releases = Get-GitTagList -TagPrefix $TagPrefix
        # Normalizing log entries
        $logs = @()

        $TagValue = 'Unreleased'

        $logs = ForEach ($Commit in $gitHist) {
            #Set the current Version/Tag in the history
            $tag = $Releases | Where-Object { $_.Commit -eq $Commit.commitid } | Select-Object -last 1
            if ($tag) {
                $TagValue = $tag.Tag
                $TagSemVerId = $tag.SemVerId
                $TagCommit = $tag.Commit
                $TagDate = $tag.Date
            }

            #Skip output if match with Omit
            If ($Omit | Where-Object { $Commit.Subject -match $_ }) { Continue }

            $IntentCode = $Intents.Code | Where-Object { $Commit.Subject -match $_ } | Select-Object -First 1
            If ( $null -eq $IntentCode) {
                $IntentCode = 'Other'
            }
            $Intent = $Intents | Where-Object { $_.Code -contains $IntentCode }            
            If ($Audience -eq 'Public' -and $Intent.DefaultAudience -eq 'internal') {
                Continue
            }
            If ($Commit.Subject.Length -lt $RequiredCommitMessageLength) {
                Write-Host "Commit message: $message is considered too short ($RequiredCommitMessageLength). Ommitting from changelog..."
                Continue
            }
            $IssueKey = Test-IssueKey($Commit.Subject)
            $log = [pscustomobject]@{
                Project          = $ProjectName
                Release          = $TagValue
                ReleaseVersionid = $TagSemVerId
                ReleaseCommit    = $TagCommit
                ReleaseDate      = $TagDate
                IntentCode       = $IntentCode
                Intent           = $Intent.Description
                Audience         = $Intent.DefaultAudience
                Message          = $Commit.Subject
                IssueKey         = $IssueKey
                CommitId         = $Commit.CommitId
                Order            = $Intents.Order
            }
            
            Write-Output $log
        } #ForEach

        If ($OutputAs -eq 'psobject') { return $logs }

        $Releasedata = @()

        If ($Latest) {
            $Major = $Releases.Major | Select-Object -first 1
            $Minor = ($Releases | Where-Object { $_.Major -eq $Major } ).Minor | Select-Object -first 1
            Write-Host "Getting Releases of Latest $Latest"
            If ($Latest -eq 'Build') {
                $Releases = $Releases | Select-Object -first 1
            } ElseIf ($Latest -eq 'Major') {
                $Major = $Releases.Major | Select-Object -first 1
                Write-Host "$latest $major"
                $Releases = $Releases | Where-Object { $_.Major -eq $Major }
            } ElseIf ($Latest -eq 'Minor') {
                Write-Host "$latest $Major.$Minor"
                $Releases = $Releases | Where-Object { $_.Major -eq $Major -and $_.Minor -eq $Minor }
            }
        }
        If ($logs | Where-Object { $_.Release -eq 'Unreleased' } ) {
            $Releasedata += [ordered]@{
                    Release       = 'Unreleased'
                    ReleaseDate   = ''
                    Component     = ''
                    Version       = ''
                    ReleaseCommit = ''
                    Commits       = $logs | Where-Object { $_.Release -eq 'Unreleased'} | SOrt-Object -Property Order | Select-Object -Property * -ExcludeProperty Project, Release, Order
                }
        }
        Write-Host $Releases.Count Releases
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

        $Data = @{
            Project  = $ProjectName
            Releases = $Releasedata
        }

        $Json = $Data | ConvertTo-Json -depth 4
        
        If ($OutputAs -eq 'json') { Return $json }

        If ($OutputAs -eq 'md'){
            $Changelog = ConvertTo-Changelog($Json) -FormatAs md
            Return $Changelog
        } elseif ($OutputAs -eq 'html') {
            $Changelog = ConvertTo-Changelog($Json) -FormatAs html
            Return $Changelog   
        }        
    }
}
