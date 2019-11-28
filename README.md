# PSGitChangeLog
Powershell Module to convert a Git log to a readable format (md or html)

# How it works
**Intents** are defined in the `/PSGitChangelog.Config.psd1` Configuration file, each Intent can have more than one Code.
UPDATE: this module is now (or tries to) compliant to the [Convential Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.
Whenever a Commit Message mentions that Code, it will be classed as that Intent: e.g Bugfix, New Feature, Configuration...
see file: `/PSGitChangelog.Config.psd1` (you can customize it)
Each Intent also has an order in which it would appear on the Changelog. For example if you would want Bug fixes to rank higher than Configuration changes, you can do that by specifying the `order` property.

# Example
A raw git log would look something like this:
```2019-11-21 22:17:53 +0100	2766127adc09112a02c8bdec83c42cb77d2ffe1b	michiel thai	💚 use Force when installing modules
2019-11-21 22:14:47 +0100	235db4f0505beb00dff89dcc1c6a9d24b9c8bc41	mieel	Update README.md
2019-11-21 22:14:29 +0100	03cd764e76c73d43ccad3c106e594e2d14dc101c	mieel	Update README.md
2019-11-21 22:07:36 +0100	3d1c105f098160c554fe78b35339f5f623b1f536	mieel	💚 create local git tag so that it shows on the changelog
2019-11-21 22:01:44 +0100	e8b4a5af08fdc0c9e3103aac82e37e8417f3b1e3	mieel	💚 use UTF8 encoding
2019-11-21 21:59:38 +0100	818d1a43633b856c43f9bb30b61d5830eae2f1a9	mieel	💚 use UTF8 encoding
...
2019-11-21 21:32:17 +0100	4e15ef11479edb20afbeee75181d91bc9df0948a	mieel	💚 ensure Pester
2019-11-21 21:29:28 +0100	2c5f3e11d2e5f20a8578625ebba1939cf3b4a658	michiel thai	💚 fix publish script
2019-11-21 21:25:44 +0100	6e42dfef64db57183da5a84662ba47f94af4267b	michiel thai	Merge branch 'master' of https://github.com/mieel/PSGitChangeLog
2019-11-21 21:25:31 +0100	4c339bd23195a4b31fe29bfc4a9fdd0ba96e610e	michiel thai	🎨 add Validate set
2019-11-21 21:25:12 +0100	27b5b78c3c0e1d9a2b593e9eb521bbb209b0a539	michiel thai	✅ Add Unit Tests
2019-11-21 21:13:33 +0100	e011416da243debf20a2e78c8df752841f18e4e3	mieel	Update azure-pipelines.yml for Azure Pipelines
2019-11-21 21:11:31 +0100	380a222a0e12c7269c9b65bab0662875d36a3961	mieel	💚 Add -force to install-module
2019-11-21 21:10:06 +0100	0a9e561e16a2d81d8758f66593b2087b9ac39b4b	mieel	Update azure-pipelines.yml for Azure Pipelines
2019-11-21 21:09:20 +0100	97ed74d44822fc77741c57038edb9cfe928c052b	mieel	Update azure-pipelines.yml for Azure Pipelines
2019-11-21 21:06:24 +0100	92536069fd3cd2548caf9bfb222cbe2d9c6184c4	mieel	Update azure-pipelines.yml for Azure Pipelines
2019-11-21 21:05:13 +0100	3eefee79a3898dcc239a9ce075710464eb15097d	mieel	Update azure-pipelines.yml for Azure Pipelines
2019-11-21 21:04:02 +0100	0fe4a1e8c7f6c80d075caff8ed5f9dc512f1264f	michiel thai	Move intentcodes to config, add Audience
2019-11-21 21:03:34 +0100	681293c7e0ca5a81a141ffdef7a2221ea0bd108a	michiel thai	🐛 Fix where empty TagPrefix would be a component
2019-11-21 21:02:39 +0100	fd12e6718484af5e8ee0892f3308031c93418097	michiel thai	👌 Move Parameters to config file RE:
2019-11-21 21:02:25 +0100	8f9265829e576128b88f80525b6334f9bd538a04	michiel thai	👌 Move Parameters to config file
2019-11-21 20:09:46 +0100	ba0c52f9228bc67082e29bb9f18d54906c85b468	michiel thai	Merge remote-tracking branch 'origin/master'
2019-11-21 20:09:27 +0100	ea3270dbce2661212db71e907d427941cf575291	michiel thai	👌 Add support for tags with no tagprefix
2019-11-21 19:29:39 +0100	d1fc8f82647e7c6b9f5a93c243bf502c9c00d352	mieel	Update azure-pipelines.yml for Azure Pipelines
2019-11-21 19:27:10 +0100	d5372e7332d0e2fdbfdfa4fc22c5d0afaa465bc1	mieel	Add Testresults, New SemVerId
2019-11-21 19:19:06 +0100	1c9d5ac74c2b57cb160246eb949d18afad3aa01c	michiel thai	Merge branch 'master' of https://github.com/mieel/PSGitChangeLog
2019-11-21 19:18:31 +0100	0ae30e60bc474d49c78adf6ebfd56cffa1dec56b	michiel thai	✨ Add Publish to PSGallery script
2019-11-20 13:05:37 +0100	7c859910e6d0877e6c0547fea6516ae14abef97e	michiel thai	👷‍♂️ Publish script to PSGAllery
2019-11-21 19:16:03 +0100	f8c1a2b9655caa4ee07ed3554baeb872d24d3028	mieel	Add PSSA
2019-11-20 13:19:39 +0100	caedb4128e5dd352edf922b8c0bc1272f11184bf	mieel	Update azure-pipelines.yml for Azure Pipelines
2019-11-20 13:06:58 +0100	77619566d02351c5420207161209f0b65c339d26	mieel	Update azure-pipelines.yml for Azure Pipelines
2019-11-20 12:55:18 +0100	21839c59b12af202a04bd72c2c68d17173707d9b	mieel	Update azure-pipelines.yml for Azure Pipelines
2019-11-20 12:52:21 +0100	2ae39ba372abf60f43661f7717ca2c96c512b395	mieel	Set up CI with Azure Pipelines
2019-11-20 12:07:21 +0100	8322d1c376d3dfb4bc3f3817a8100aeb2298b1fa	michiel thai	✅ Add Project Tests
2019-11-20 09:56:05 +0100	055c97cadbe559aaeab241cfa0e054a843947982	mieel	Create build.yml
2019-11-20 09:54:27 +0100	8173f535a0a2a0dce382bd6a462b48b080bcb4bb	michiel thai	👌 Add support for lightweight tags
2019-11-20 09:25:27 +0100	e134e7ab36f899f02f31bf7be5e86ac90ab99ac9	michiel thai	⚙ Add psm1, psd1 file
2019-11-19 20:08:18 +0100	cd1e997abe21e919387878bee3dd0435ec465894	mieel	Create Get-GitHistory.Tools.ps1
2019-11-19 19:54:31 +0100	4ef77cc35e82c4692fb687048d789db48b9d5aa9	mieel	Create Get-GitTagList.Tools.ps1
2019-11-19 19:52:42 +0100	858dbdf357dd5fb2479f900e8b304160e1ea3563	mieel	Initial commit
```
Using this module you can get a MD output:

### 0.0.4 [👨‍💻](https://github.com/mieel/PSGitChangeLog/commit/818d1a43633b856c43f9bb30b61d5830eae2f1a9)  11/21/2019 20:59:38 
#### Configuration, Testing
 - 💚 use UTF8 encoding - @[818d1a43](https://github.com/mieel/PSGitChangeLog/commit/818d1a43)
 
### 0.0.3 [👨‍💻](https://github.com/mieel/PSGitChangeLog/commit/67ca43a32bdbb0e045d938ba8c27f1aea512517f)  11/21/2019 20:55:24 
#### Other
 - Merge branch 'master' of https://github.com/mieel/PSGitChangeLog - @[1c9d5ac7](https://github.com/mieel/PSGitChangeLog/commit/1c9d5ac7)
 - Add Testresults, New SemVerId - @[d5372e73](https://github.com/mieel/PSGitChangeLog/commit/d5372e73)
 - Merge remote-tracking branch 'origin/master' - @[ba0c52f9](https://github.com/mieel/PSGitChangeLog/commit/ba0c52f9)
 - Create build.yml - @[055c97ca](https://github.com/mieel/PSGitChangeLog/commit/055c97ca)
 - Set up CI with Azure Pipelines - @[2ae39ba3](https://github.com/mieel/PSGitChangeLog/commit/2ae39ba3)
 - Add PSSA - @[f8c1a2b9](https://github.com/mieel/PSGitChangeLog/commit/f8c1a2b9)
 - Merge branch 'master' of https://github.com/mieel/PSGitChangeLog - @[6e42dfef](https://github.com/mieel/PSGitChangeLog/commit/6e42dfef)
 - add Github release step - @[359ffc48](https://github.com/mieel/PSGitChangeLog/commit/359ffc48)
 - Move intentcodes to config, add Audience - @[0fe4a1e8](https://github.com/mieel/PSGitChangeLog/commit/0fe4a1e8)
 
#### New features, Improvements
 - ✨ Add Publish to PSGallery script - @[0ae30e60](https://github.com/mieel/PSGitChangeLog/commit/0ae30e60)
 - 👌 Add support for tags with no tagprefix - @[ea3270db](https://github.com/mieel/PSGitChangeLog/commit/ea3270db)
 - 👌 Move Parameters to config file - @[8f926582](https://github.com/mieel/PSGitChangeLog/commit/8f926582)
 
#### Configuration, Testing
 - ✅ Add Project Tests - @[8322d1c3](https://github.com/mieel/PSGitChangeLog/commit/8322d1c3)
 - 👷‍♂️ Publish script to PSGAllery - @[7c859910](https://github.com/mieel/PSGitChangeLog/commit/7c859910)
 - 💚 fix publish script - @[2c5f3e11](https://github.com/mieel/PSGitChangeLog/commit/2c5f3e11)
 - 💚 ensure Pester - @[4e15ef11](https://github.com/mieel/PSGitChangeLog/commit/4e15ef11)
 - ✅ Add Unit Tests - @[27b5b78c](https://github.com/mieel/PSGitChangeLog/commit/27b5b78c)
 - 💚 Add -force to install-module - @[380a222a](https://github.com/mieel/PSGitChangeLog/commit/380a222a)
 
#### Code Optimization, Refactoring
 - 🎨 add Validate set - @[4c339bd2](https://github.com/mieel/PSGitChangeLog/commit/4c339bd2)
 
#### Bugs, Problems
 - 🐛 Fix where empty TagPrefix would be a component - @[681293c7](https://github.com/mieel/PSGitChangeLog/commit/681293c7)
 
### 0.0.2 [👨‍💻](https://github.com/mieel/PSGitChangeLog/commit/8173f535a0a2a0dce382bd6a462b48b080bcb4bb)  11/20/2019 08:54:27 
#### New features, Improvements
 - 👌 Add support for lightweight tags - @[8173f535](https://github.com/mieel/PSGitChangeLog/commit/8173f535)
 
### 0.0.1 [👨‍💻](https://github.com/mieel/PSGitChangeLog/commit/e134e7ab36f899f02f31bf7be5e86ac90ab99ac9)  11/20/2019 08:25:27 
#### Other
 - Create Get-GitTagList.Tools.ps1 - @[4ef77cc3](https://github.com/mieel/PSGitChangeLog/commit/4ef77cc3)
 - Initial commit - @[858dbdf3](https://github.com/mieel/PSGitChangeLog/commit/858dbdf3)
 - Create Get-GitHistory.Tools.ps1 - @[cd1e997a](https://github.com/mieel/PSGitChangeLog/commit/cd1e997a)
 
#### Configuration, Testing
 - ⚙ Add psm1, psd1 file - @[e134e7ab](https://github.com/mieel/PSGitChangeLog/commit/e134e7ab)

Or Json

```
{
    "Project":  "PSGitChangeLog",
    "Releases":  [
                     {
                         "Release":  "Unreleased",
                         "ReleaseDate":  "",
                         "Component":  "",
                         "Version":  "",
                         "ReleaseCommit":  "",
                         "Commits":  [
                                         {
                                             "ReleaseVersionid":  null,
                                             "ReleaseCommit":  null,
                                             "ReleaseDate":  null,
                                             "IntentCode":  "💚",
                                             "Intent":  "Configuration, Testing",
                                             "Audience":  "internal",
                                             "Message":  "💚 create local git tag so that it shows on the changelog",
                                             "IssueKey":  "",
                                             "CommitId":  "3d1c105f098160c554fe78b35339f5f623b1f536"
                                         },
                                         ...
                                     ]
                     },
                     {
                         "Release":  "0.0.4",
                         "ReleaseDate":  "\/Date(1574369978000)\/",
                         "Component":  "",
                         "Version":  "0.0.4",
                         "ReleaseCommit":  "818d1a43633b856c43f9bb30b61d5830eae2f1a9",
                         "Commits":  {
                                         "ReleaseVersionid":  {
                                                                  "Major":  0,
                                                                  "Minor":  0,
                                                                  "Build":  4,
                                                                  "Revision":  -1,
                                                                  "MajorRevision":  -1,
                                                                  "MinorRevision":  -1
                                                              },
                                         "ReleaseCommit":  "818d1a43633b856c43f9bb30b61d5830eae2f1a9",
                                         "ReleaseDate":  "\/Date(1574369978000)\/",
                                         "IntentCode":  "💚",
                                         "Intent":  "Configuration, Testing",
                                         "Audience":  "internal",
                                         "Message":  "💚 use UTF8 encoding",
                                         "IssueKey":  {

                                                      },
                                         "CommitId":  "818d1a43633b856c43f9bb30b61d5830eae2f1a9"
                                     }
                     },
                    ...
                 ]
}
```

# How to use
Install from the PSGallery  
`Install-Module PSGitChangeLog`  

If you want a Markdown document  
`Get-GitChangelog -OutputAs md`  

If you want a html document  
`Get-GitChangelog -OutputAs html`

If you want a json/psobject object, so that you can apply your own formatting  
`Get-GitChangelog -OutputAs json`  
`Get-GitChangelog -OutputAs psobject`

Only output latest x version  
`Get-GitChangelog -OutputAs md -Latest Major`  (Outputs all minor/builds of the current Major release)  
`Get-GitChangelog -OutputAs md -Latest Minor`  (Outputs all builds of the currenct Minor release)  
`Get-GitChangelog -OutputAs md -Latest Build`  (Outputs the latest build release)

Get all Tag/Releases
`Get-GitTagList`

# Use it in CI
```
# PowerShell Task
Install-Module PSGitChangeLog -Scope CurrentUser -Force
Import-Module PSGitChangeLog
Get-GitChangelog -OutputAs md | Set-Content Changelog.md -Encoding utf8
```
When you create a Github Release, you can use this .md document as the ChangeLog:
https://github.com/mieel/PSGitChangeLog/releases
