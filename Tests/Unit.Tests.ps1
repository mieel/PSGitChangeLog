# $projectRoot = Resolve-Path "F:\rdcinmotiv\Plumber\Tests\.."
. $PSScriptRoot\TestHeader.Template.ps1

Describe "Test-IssueKey" -Tag Unit {
    $keys = @('ISSUE-1','ISSUE-1213','KEY-23')
    $keys | ForEach-Object {
        it "$_ in a commit message should be parsed as a key" {
            $key = Test-IssueKey("Commit message mentions $_ somwhere ")
            $key | Should -Be $_
        }
    }
    
}

Describe Get-GitHistory {
    $result = Get-GitHistory -OutputAs psobject
    it 'should return results' {
        $result | Should -Not -Be $null
    }
    it 'Results should have release' {
        $result.Release | Should -Not -Be $null
    }
    it 'Results should have intents' {
        $result.intent | Should -Not -Be $null
    }
}
