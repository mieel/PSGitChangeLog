Function Get-GitTagList {
    <#
        .SYNOPSIS
            Gets a normalized list of Git Tags of the current Git Repo
            If a TagPrefix is provided, only matching tags are retrieved (for multi component repo's)
        .EXAMPLE
            Get-GitTagList -TagPrefix plumber -Latest
        .EXAMPLE
            Get-GitTagList
    #>
    Param (
        $TagPrefix
        ,
        [switch] $Latest
        ,
        [switch] $GitVersionContiniousDeploymentMode
    )

    $gittagdata = git for-each-ref --sort=taggerdate --format='%(if)%(*objectname)%(then)%(*objectname)%(else)%(objectname)%(end)##%(refname)##%(taggerdate:iso)' refs/tags
    If ($TagPrefix) {
        $gittagdata = $gittagdata | Where-Object { $_ -match "refs/tags/$TagPrefix-" }
    }
    $taglist = @()
    ForEach ($x in $gittagdata) {
        $commit, $tag, $date = $x -split '##'
        $tagvalue = $tag.Replace('refs/tags/', '')
        If ($date -in $null, '') {
            $date = git show -s --format=%ci $commit
        }

        $tagParts = $tagvalue -Split '-'
        ForEach ($tagPart in $tagParts) {
            If ($TagPrefix -and $tagPart -eq $TagPrefix) { continue }
            $tagPart = $tagPart.Replace('v', '')
            Try {
                # Tags needs to be a valid SemVerId
                $SemVerId = [System.Version] $tagpart
                # Tags needs to have a date
                $tagDate = [datetime]::ParseExact($date.Substring(0, 19), 'yyyy-MM-dd HH:mm:ss', $null)

                Try {
                    $Tag = if ($TagPrefix) { "$TagPrefix-$SemVerId" } Else { "$TagValue" }
                    $taglist += [pscustomobject]@{
                        Tag       = $Tag
                        Component = $Tag -split '-' | Select-Object -first 1
                        Commit    = $commit
                        Date      = $tagDate
                        SemVerId  = $SemVerId
                        Major     = $SemVerId.Major
                        Minor     = $SemVerId.Minor
                        Build     = $SemVerId.Build
                        FullTag   = $tagvalue

                    }
                } Catch {
                    Write-Verbose 'no valid tag date, ignoring'
                }
            } Catch {
                Write-Verbose "$tagpart is not a valid SemVerId, ignoring..."
            }
        }
    }
    $taglist = $taglist | Sort-Object -Property Component, SemVerId -Descending
    If ($Latest) {
        Return $taglist | Select-Object -First 1
    }

    If ($GitVersionContiniousDeploymentMode) {
        $tagsGrouped = ($list | Group-Object -Property Tag)
        ForEach ($group in $tagsGrouped) {
            Write-Verbose "$($group.Name) has latest commit:"
            $commit = $Group.Group | Sort-Object -Property Date | Select-Object -first 1
            Write-Verbose $Commit
            Write-Output $Commit
        }
        Return
    }
    Write-Output $taglist
}
