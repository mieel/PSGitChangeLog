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
        $Level
        ,
        $WorkDir
        ,
        $RequiredCommitMessageLength = 5
        ,
        $ProjectName
        ,
        $TagPrefix
        ,
        [string]
        $RemoteName = 'origin'
        ,
        [switch] $asJson
        ,
        [String]
        $Latest = ''
        # Specify to retrieve the latest Major, Minor, Build
    )
    # Settings
    Begin {
        # Ensuring Encoding
        $env:LC_ALL = 'C.UTF-8'
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

        $CurrentBranch = $env:Build_SourceBranchName

        $CommitCodes = @(
            @{
                code            = '🐛', '🚑', 'bf:', 'bug:', 'prob:'
                description     = 'Bugs, Problems'
                DefaultAudience = 'all'
                Order           = 2
            }, @{
                code            = '👌', '📦', '✨', 'new:', 'impr:'
                description     = 'New features, Improvements'
                DefaultAudience = 'all'
                Order           = 1
            }, @{
                code            = '👷‍♂️', '⚙', '✅', 'ci:', 'cfg:', 'adm:', '💚'
                description     = 'Configuration, Testing'
                DefaultAudience = 'internal'
                Order           = 4
            }, @{
                code            = '📝'
                description     = 'Documentation'
                DefaultAudience = 'internal'
                Order           = 3
            }, @{
                code            = '✏', '♻', '🎨', 'rf:', 'opt:'
                description     = 'Code Optimization, Refactoring'
                DefaultAudience = 'all'
                Order           = 5
            }, @{
                code            = 'Other'
                description     = 'Other'
                DefaultAudience = 'all'
                Order           = 6
            }
        )
        $Omit = 'RE:', 'Merged', 'azure-pipelines.yml edited online with Bitbucket'
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

        $TagValue = ''

        $logs = ForEach ($Commit in $gitHist) {
            #$commit = $gitHist | select-object -first 1

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

            $CommitCode = $CommitCodes.Code | Where-Object { $Commit.Subject -match $_ } | Select-Object -First 1
            If ( $null -eq $CommitCode) {
                $CommitCode = 'Other'
            }
            If ($Commit.Subject.Length -lt $RequiredCommitMessageLength) {
                Write-Host "Commit message: $message is considered too short ($RequiredCommitMessageLength). Ommitting from changelog..."
                Continue
            }
            $IssueKey = Test-JiraIssueKey($Commit.Subject)
            $log = [pscustomobject]@{
                Project          = $ProjectName
                Release          = $TagValue
                ReleaseVersionid = $TagSemVerId
                ReleaseCommit    = $TagCommit
                ReleaseDate      = $TagDate
                IntentCode       = $CommitCode
                Intent           = ($CommitCodes | Where-Object { $_.Code -contains $CommitCode }).Description
                Audience         = ($CommitCodes | Where-Object { $_.Code -contains $CommitCode }).DefaultAudience
                Message          = $Commit.Subject
                IssueKey         = $IssueKey
                CommitId         = $Commit.CommitId
                Order            = ($CommitCodes | Where-Object { $_.Code -contains $CommitCode }).Order
            }
            Write-Output $log
        } #ForEach

        If (!$asJSON) { return $logs }

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

        $Json = @{
            Project  = $ProjectName
            Releases = $Releasedata
        }

        $output = $Json | ConvertTo-Json -depth 4

        Return $output

    }
}
