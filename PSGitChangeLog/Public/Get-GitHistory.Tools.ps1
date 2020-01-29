Function Get-GitHistory {
    <#
        .SYNOPSIS
            Converts gitlog output into structured format
        .DESCRIPTION
            Gets Commit data from gitlog and gets Tags.
            Orders Commit by their tag and outputs in a list of objects or a nested json document (use -OutputAs Json)
            You can also specify to only output history from the latest major/minor/build.
        .EXAMPLE
            Get-GitHistory -TagPrefix WebApp -OutputAs Json
        .EXAMPLE
            $json = Get-GitHistory -OutputAs Json
        .EXAMPLE
            $json = Get-GitHistory -OutputAs Json -Latest Major
            $json = Get-GitHistory -OutputAs Json -Latest Minor
            $json = Get-GitHistory -OutputAs Json -Latest Build
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
        [ValidateSet("psobject", "json")]
        [string]
        $OutputAs = 'psobject'
        ,
        [ValidateSet("Major", "Minor", "Build")]
        [String]
        $Latest
        # Specify to retrieve the latest Major, Minor, Build
        ,
        [switch]
        $toChangelog
        ,
        [switch]
        $GitVersionContiniousDeploymentMode
        ,
        [int]
        $FetchDepth = 500
    )
    # Settings
    Begin {
        # Ensuring Encoding
        $env:LC_ALL = 'C.UTF-8'
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $CurrentBranch = $env:Build_SourceBranchName
        $config = Import-PowerShellDataFile -Path $PSScriptRoot/../PSGitChangeLog.Config.psd1
        $Omit = $config.Omit
    }
    Process {
        If (!$ProjectName) {
            $ProjectName = (Split-Path -Leaf (git remote get-url $RemoteName)).Replace('.git', '')
        }
        If ($WorkDir) { Set-Location $WorkDir }

        # Instantiate GitLog as an Object so that we can work with it
        $gitlog = (git log -$FetchDepth --format="%ai`t%H`t%an`t%s")

        $gitHist = $gitlog | ConvertFrom-Csv -Delimiter "`t" -Header ("Date", "CommitId", "Author", "Subject")

        $ExtraParams = @{ }
        If ($GitVersionContiniousDeploymentMode) {
            $ExtraParam.Add('GitVersionContiniousDeploymentMode', $GitVersionContiniousDeploymentMode)
        }
        $Releases = Get-GitTagList -TagPrefix $TagPrefix @ExtraParams

        $TagValue = 'Unreleased'

        $Logs = ForEach ($Commit in $gitHist) {
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

            $ConventialCommitLog = Get-ConventialCommit -CommitMessage $Commit.Subject
            Write-Debug $ConventialCommitLog

            $IntentCode = $ConventialCommitLog.IntentCode
            $Message = $ConventialCommitLog.Message

            If ( $null -eq $IntentCode) {
                $IntentCode = 'Other'
            }

            If ($Message -lt $RequiredCommitMessageLength) {
                Write-Information "Commit message: $message is considered too short ($RequiredCommitMessageLength). Ommitting from changelog..."
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
                Intent           = $ConventialCommitLog.IntentDescription
                Audience         = $ConventialCommitLog.IntentAudience
                Message          = $Message
                IssueKey         = $IssueKey
                CommitId         = $Commit.CommitId
                Order            = $ConventialCommitLog.Order
            }

            Write-Output $log
        } #ForEach

        Switch ($OutputAs) {
            'json' {
                Write-Output $logs | ConvertTo-Json -Depth 5
            } Default {
                Write-Output $logs
            }
        }
    }
}

