Function Test-IssueKey {
    <#
        .SYNOPSIS
            Parses a string to detect (JIRA) issue keys and returns the key
        .EXAMPLE
            Test-IssueLinkKey('safdsf BISS-123 asdfasdf')
            Test-IssueLinkKey('safdsf BISS123 asdfasdf')
    #>
    Param (
        $String
    )
    $regex = '((?!([A-Z0-9a-z]{1,10})-?$)[A-Z]{1}[A-Z0-9]+-\d+)'
    If ($string -match $regex) {
        Return $matches.GetEnumerator() | Select-Object -ExpandProperty Value -Unique
    }
}