@{
    # Baseuri to view your commit details
    CommitBaseUri = "https://github.com/mieel/PSGitChangeLog/commit"
    # Baseuri to view the Issue details linked to a commit
    IssueLinkUri  = "https://github.com/mieel/PSGitChangeLog/issues"
    # Baseuri to view the download page of the package
    PackageUri    = "https://www.powershellgallery.com/packages/PSGitChangeLog"

    #Define Commit Intent Codes here
    #if a Intent Code is used anywhere in the Commit message, that commit is classed under the intent you describe in the Desciption
    #you can specify the order of Intents in the changelog
    Intents       = @(
        @{
            Code        = '🐛', '🚑', 'bf', 'bug', 'prob', 'fix'
            Description = 'Fixes'
            Audience    = 'Public'
            Order       = 2
        }, @{
            Code        = '👌', '📦', '✨', 'new:', 'impr:', 'feat:'
            Description = 'Improvements'
            Audience    = 'Public'
            Order       = 1
        }, @{
            Code        = '👷‍♂️', '⚙', '✅', 'ci', 'cfg', 'adm', '💚', 'build', 'test'
            Description = 'Configuration'
            Audience    = 'Internal'
            Order       = 4
        }, @{
            Code        = '📝', 'docs'
            Description = 'Documentation'
            Audience    = 'Internal'
            Order       = 3
        }, @{
            Code        = '✏', '♻', '🎨', 'rf', 'refactor', 'opt', 'perf'
            Description = 'Optimalisations'
            Audience    = 'Public'
            Order       = 5
        }, @{
            Code        = 'revert:'
            Description = 'Revert'
            Audience    = 'Public'
            Order       = 6
        }, @{
            Code        = 'Other'
            Description = 'Other'
            Audience    = 'Internal'
            Order       = 7
        }
    )
    # Omit Commit Messages when they contain one of these keys
    Omit          = @(
        'RE:'
        'Update azure-pipelines.yml for Azure Pipelines'
        'bump version'
        '🙊'
        'Merged in'
    )
}