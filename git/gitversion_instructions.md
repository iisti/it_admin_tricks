# GitVersion Instructions

*GitVersion is a tool that generates a Semantic Version number based on your Git history. The version number generated from GitVersion can then be used for various different purposes, such as: Stamping a version number on artifacts (packages) produced during build.*

*SemVer introduces conventions about breaking changes into our version numbers so we can safely upgrade dependencies without fear of unexpected, breaking changes while still allowing us to upgrade downstream libraries to get new features and bug fixes. The convention is quite simple:*

* `{major}.{minor}.{patch}-{tag}+{buildmetadata}`
* `{major}` is only incremented if the release has breaking changes (includes bug fixes which have breaking behavioural changes
* `{minor}` is incremented if the release has new non-breaking features
* `{patch}` is incremented if the release only contains non-breaking bug fixes
* `{tag}` is optional and denotes a pre-release of the version preceding
* `{buildmetadata}` is optional and contains additional information about the version, but does not affect the semantic version preceding it.

Source: <https://gitversion.net/docs/>

## Example usage with Mainline mode

We want to use the GitVersion this way:

1. Major, minor or patch is incremented only when tag is added.
1. All other branches live short time except Main. Main will have regex of `main` and `major.minor` (e.g. `1.0`, `1.1`, `2.0`).
1. Support branch is for creating releases and then patching them. For example Main branch could have version `2.0.0`, but there are still versions `1.1.x` and `1.2.x` branches. There's more information at <https://gitversion.net/docs/learn/branching-strategies/gitflow/examples>

### Configuration in this example

* Branching strategy
  * Good and simple explanations of GitFlow, GitHub Flow and Trunk/Mainline branching strategies
    * <https://medium.com/@sreekanth.thummala/choosing-the-right-git-branching-strategy-a-comparative-analysis-f5e635443423>
  * We use Trunk / Mainline, plus we create everlasting support/release branches for maintaining multiple major/minor versions.

* GitVersion mode

  **Mainline**: *Mainline Development is enabled when using GitHubFlow or any other strategy where you  develop on main. The main rule of mainline development is that **main is always in a state that it could  be deployed to production**. This means that pull requests should not be merged until they are ready to  go out.*
  * More information <https://gitversion.net/docs/learn/branching-strategies/githubflow/>

#### Push tags

Tags are not pushed to remote by default. There are couple different ways to handle pushing tags.

1. `--follow-tags` parameter. Notice only annonated tags are pushed, `git tag -a -m "I'm an annotation" <tagname>`. Lightweight tags are not pushed.

    ~~~sh
    git push --follow-tags 
    ~~~

    * One can set global `push.followTags` configuration variable

        ~~~sh
        git config --global push.followTags true
        ~~~

1. Push tags separately

    ~~~sh
    git push --tags
    ~~~

#### GitVersion.yml

~~~yaml
mode: Mainline
branches:
  main:
    tag: ''
    increment: None
    prevent-increment-of-merged-branch-version: true
    track-merge-target: false
    regex: ^master$|^main$
    source-branches:
    - develop
    - release
    tracks-release-branches: false
    is-release-branch: false
    is-mainline: true
    pre-release-weight: 55000
  feature:
    tag: '{BranchName}'
    increment: None
    regex: ^features?[/-]|^(?i)ticket-
    source-branches:
    - develop
    - main
    - release
    - feature
    - support
    - hotfix
    pre-release-weight: 30000
  support:
    tag: ''
    increment: None
    prevent-increment-of-merged-branch-version: true
    track-merge-target: false
    regex: ^support[/-]
    source-branches:
    - main
    tracks-release-branches: false
    is-release-branch: false
    is-mainline: true
    pre-release-weight: 55000
ignore:
  sha: []
merge-message-formats: {}
~~~

### Testing with GitVersion

### Test a simple GitVersion Mainline config

1. Create a completely new repository
1. Check GitVersion version

    ~~~sh
    gitversion -version
    5.12.0
    ~~~

1. Check GitVersion default configuration `gitversion -showconfig`

    ~~~yaml
    assembly-versioning-scheme: MajorMinorPatch
    assembly-file-versioning-scheme: MajorMinorPatch
    mode: Mainline
    tag-prefix: '[vV]'
    continuous-delivery-fallback-tag: ci
    major-version-bump-message: '\+semver:\s?(breaking|major)'
    minor-version-bump-message: '\+semver:\s?(feature|minor)'
    patch-version-bump-message: '\+semver:\s?(fix|patch)'
    no-bump-message: '\+semver:\s?(none|skip)'
    legacy-semver-padding: 4
    build-metadata-padding: 4
    commits-since-version-source-padding: 4
    tag-pre-release-weight: 60000
    commit-message-incrementing: Enabled
    branches:
    main:
        mode: Mainline
        tag: ''
        increment: None
        prevent-increment-of-merged-branch-version: true
        track-merge-target: false
        regex: ^master$|^main$
        source-branches:
        - develop
        - release
        tracks-release-branches: false
        is-release-branch: false
        is-mainline: true
        pre-release-weight: 55000
    feature:
        mode: Mainline
        tag: '{BranchName}'
        increment: None
        regex: ^features?[/-]|^(?i)ticket-
        source-branches:
        - develop
        - main
        - release
        - feature
        - support
        - hotfix
        pre-release-weight: 30000
    support:
        mode: Mainline
        tag: ''
        increment: None
        prevent-increment-of-merged-branch-version: true
        track-merge-target: false
        regex: ^support[/-]
        source-branches:
        - main
        tracks-release-branches: false
        is-release-branch: false
        is-mainline: true
        pre-release-weight: 55000
    develop:
        mode: Mainline
        tag: alpha
        increment: Minor
        prevent-increment-of-merged-branch-version: false
        track-merge-target: true
        regex: ^dev(elop)?(ment)?$
        source-branches: []
        tracks-release-branches: true
        is-release-branch: false
        is-mainline: false
        pre-release-weight: 0
    release:
        mode: Mainline
        tag: beta
        increment: None
        prevent-increment-of-merged-branch-version: true
        track-merge-target: false
        regex: ^releases?[/-]
        source-branches:
        - develop
        - main
        - support
        - release
        tracks-release-branches: false
        is-release-branch: true
        is-mainline: false
        pre-release-weight: 30000
    pull-request:
        mode: Mainline
        tag: PullRequest
        increment: Inherit
        tag-number-pattern: '[/-](?<number>\d+)'
        regex: ^(pull|pull\-requests|pr)[/-]
        source-branches:
        - develop
        - main
        - release
        - feature
        - support
        - hotfix
        pre-release-weight: 30000
    hotfix:
        mode: Mainline
        tag: beta
        increment: Patch
        prevent-increment-of-merged-branch-version: false
        track-merge-target: false
        regex: ^hotfix(es)?[/-]
        source-branches:
        - release
        - main
        - support
        - hotfix
        tracks-release-branches: false
        is-release-branch: false
        is-mainline: false
        pre-release-weight: 30000
    ignore:
    sha: []
    increment: Inherit
    commit-date-format: yyyy-MM-dd
    merge-message-formats: {}
    update-build-number: true
    ~~~

1. Check output of `gitversion`

    ~~~json
    {
        "Major": 0,
        "Minor": 1,
        "Patch": 0,
        "PreReleaseTag": "",
        "PreReleaseTagWithDash": "",
        "PreReleaseLabel": "",
        "PreReleaseLabelWithDash": "",
        "PreReleaseNumber": null,
        "WeightedPreReleaseNumber": 60000,
        "BuildMetaData": 0,
        "BuildMetaDataPadded": "0000",
        "FullBuildMetaData": "0.Branch.main.Sha.0d22809fe131b793c84feb5446591a57c4644f67",
        "MajorMinorPatch": "0.1.0",
        "SemVer": "0.1.0",
        "LegacySemVer": "0.1.0",
        "LegacySemVerPadded": "0.1.0",
        "AssemblySemVer": "0.1.0.0",
        "AssemblySemFileVer": "0.1.0.0",
        "FullSemVer": "0.1.0+0",
        "InformationalVersion": "0.1.0+0.Branch.main.Sha.0d22809fe131b793c84feb5446591a57c4644f67",
        "BranchName": "main",
        "EscapedBranchName": "main",
        "Sha": "0d22809fe131b793c84feb5446591a57c4644f67",
        "ShortSha": "0d22809",
        "NuGetVersionV2": "0.1.0",
        "NuGetVersion": "0.1.0",
        "NuGetPreReleaseTagV2": "",
        "NuGetPreReleaseTag": "",
        "VersionSourceSha": "0d22809fe131b793c84feb5446591a57c4644f67",
        "CommitsSinceVersionSource": 0,
        "CommitsSinceVersionSourcePadded": "0000",
        "UncommittedChanges": 1,
        "CommitDate": "2024-05-15"
    }
    ~~~

1. Create a new branch `git checkout -b "TICKET-testing01"`
1. Check output of `gitversion`

    ~~~json
    {
        "Major": 0,
        "Minor": 1,
        "Patch": 0,
        "PreReleaseTag": "TICKET-testing01.1",
        "PreReleaseTagWithDash": "-TICKET-testing01.1",
        "PreReleaseLabel": "TICKET-testing01",
        "PreReleaseLabelWithDash": "-TICKET-testing01",
        "PreReleaseNumber": 1,
        "WeightedPreReleaseNumber": 1,
        "BuildMetaData": 0,
        "BuildMetaDataPadded": "0000",
        "FullBuildMetaData": "0.Branch.TICKET-testing01.Sha.0d22809fe131b793c84feb5446591a57c4644f67",
        "MajorMinorPatch": "0.1.0",
        "SemVer": "0.1.0-TICKET-testing01.1",
        "LegacySemVer": "0.1.0-TICKET-testing01-1",
        "LegacySemVerPadded": "0.1.0-TICKET-testing0-0001",
        "AssemblySemVer": "0.1.0.0",
        "AssemblySemFileVer": "0.1.0.0",
        "FullSemVer": "0.1.0-TICKET-testing01.1+0",
        "InformationalVersion": "0.1.0-TICKET-testing01.1+0.Branch.TICKET-testing01.Sha.0d22809fe131b793c84feb5446591a57c4644f67",
        "BranchName": "TICKET-testing01",
        "EscapedBranchName": "TICKET-testing01",
        "Sha": "0d22809fe131b793c84feb5446591a57c4644f67",
        "ShortSha": "0d22809",
        "NuGetVersionV2": "0.1.0-ticket-testing0-0001",
        "NuGetVersion": "0.1.0-ticket-testing0-0001",
        "NuGetPreReleaseTagV2": "ticket-testing0-0001",
        "NuGetPreReleaseTag": "ticket-testing0-0001",
        "VersionSourceSha": "0d22809fe131b793c84feb5446591a57c4644f67",
        "CommitsSinceVersionSource": 0,
        "CommitsSinceVersionSourcePadded": "0000",
        "UncommittedChanges": 1,
        "CommitDate": "2024-05-15"
    }
    ~~~

1. Add `GitVersion.yml`
1. Check GitVersion configuration `gitversion -showconfig`. Notice that there are differences to the defaults.

    ~~~yaml
    assembly-versioning-scheme: MajorMinorPatch
    assembly-file-versioning-scheme: MajorMinorPatch
    mode: Mainline
    tag-prefix: '[vV]'
    continuous-delivery-fallback-tag: ci
    major-version-bump-message: '\+semver:\s?(breaking|major)'
    minor-version-bump-message: '\+semver:\s?(feature|minor)'
    patch-version-bump-message: '\+semver:\s?(fix|patch)'
    no-bump-message: '\+semver:\s?(none|skip)'
    legacy-semver-padding: 4
    build-metadata-padding: 4
    commits-since-version-source-padding: 4
    tag-pre-release-weight: 60000
    commit-message-incrementing: Enabled
    branches:
    main:
        mode: Mainline
        tag: ''
        increment: None
        prevent-increment-of-merged-branch-version: true
        track-merge-target: false
        regex: ^master$|^main$
        source-branches:
        - develop
        - release
        tracks-release-branches: false
        is-release-branch: false
        is-mainline: true
        pre-release-weight: 55000
    feature:
        mode: Mainline
        tag: '{BranchName}'
        increment: None
        regex: ^features?[/-]|^(?i)ticket-
        source-branches:
        - develop
        - main
        - release
        - feature
        - support
        - hotfix
        pre-release-weight: 30000
    develop:
        mode: Mainline
        tag: alpha
        increment: Minor
        prevent-increment-of-merged-branch-version: false
        track-merge-target: true
        regex: ^dev(elop)?(ment)?$
        source-branches: []
        tracks-release-branches: true
        is-release-branch: false
        is-mainline: false
        pre-release-weight: 0
    release:
        mode: Mainline
        tag: beta
        increment: None
        prevent-increment-of-merged-branch-version: true
        track-merge-target: false
        regex: ^releases?[/-]
        source-branches:
        - develop
        - main
        - support
        - release
        tracks-release-branches: false
        is-release-branch: true
        is-mainline: false
        pre-release-weight: 30000
    pull-request:
        mode: Mainline
        tag: PullRequest
        increment: Inherit
        tag-number-pattern: '[/-](?<number>\d+)'
        regex: ^(pull|pull\-requests|pr)[/-]
        source-branches:
        - develop
        - main
        - release
        - feature
        - support
        - hotfix
        pre-release-weight: 30000
    hotfix:
        mode: Mainline
        tag: beta
        increment: Patch
        prevent-increment-of-merged-branch-version: false
        track-merge-target: false
        regex: ^hotfix(es)?[/-]
        source-branches:
        - release
        - main
        - support
        - hotfix
        tracks-release-branches: false
        is-release-branch: false
        is-mainline: false
        pre-release-weight: 30000
    support:
        mode: Mainline
        tag: ''
        increment: Patch
        prevent-increment-of-merged-branch-version: true
        track-merge-target: false
        regex: ^support[/-]
        source-branches:
        - main
        tracks-release-branches: false
        is-release-branch: false
        is-mainline: true
        pre-release-weight: 55000
    ignore:
    sha: []
    increment: Inherit
    commit-date-format: yyyy-MM-dd
    merge-message-formats: {}
    update-build-number: true
    ~~~

1. `git add GitVersion.yml && git commit -m "TICKET-1: Added initial GitVersion.yml"`
1. Check variable `InformationalVersion`. It has all the relevant information. Notice that the number between `testing01.` and `+Branch` has been incremented from 0 to 1.

    ~~~sh
    gitversion -showvariable InformationalVersion
        0.1.0-testing01.1+Branch.TICKET-testing01.Sha.dfe24421d058e9be97db2c2b4092098e39c80fc7
    ~~~

1. Add commits into branch. These lines will create a file with branch name and it will be commited.

    ~~~sh
    num=0

    ((num++)) \
        && echo "Test $num" >> $(git branch --show-current) \
        && git add $(git branch --show-current) \
        && git commit -m "$(git branch --show-current) Testing $num"
    ~~~

1. Now PreReleaseNumber has been incremented into 2.

    ~~~sh
    gitversion -showvariable InformationalVersion
        0.1.0-testing01.2+Branch.TICKET-testing01.Sha.1a55bbea781e485224a217a32b55d4c5abb21897
    ~~~

1. Merge back into main and check version. Notice that version stays at `0.1.0`.

    ~~~sh
    git checkout main
    gitversion -showvariable InformationalVersion
        0.1.0+0.Branch.main.Sha.0d22809fe131b793c84feb5446591a57c4644f67
    git merge TICKET-testing01
    gitversion -showvariable InformationalVersion
        0.1.0+Branch.main.Sha.1a55bbea781e485224a217a32b55d4c5abb21897
    ~~~

1. Create a new branch `git checkout -b "TICKET-testing02"`
1. Check version

    ~~~sh
    gitversion -showvariable InformationalVersion
        0.1.0-testing02.0+Branch.TICKET-testing02.Sha.1a55bbea781e485224a217a32b55d4c5abb21897
    ~~~

1. Create a commit like previously.
1. Check version

    ~~~sh
    gitversion -showvariable InformationalVersion
        0.1.0-testing02.1+Branch.TICKET-testing02.Sha.dc4e26807f244e5c269ddf6ff9f61e9f28910128
    ~~~

1. Merge back into main and check version. Notice that version stays at `0.1.0`.

    ~~~sh
    git checkout main
    gitversion -showvariable InformationalVersion
        0.1.0+Branch.main.Sha.1a55bbea781e485224a217a32b55d4c5abb21897
    git merge TICKET-testing02
    gitversion -showvariable InformationalVersion
        0.1.0+Branch.main.Sha.dc4e26807f244e5c269ddf6ff9f61e9f28910128
    ~~~

1. Let's say that now a patch has been applied properly and we want to publish it. We'll tag the current commit and check version.

    ~~~sh
    git tag -a v0.1.1 -m "Version 0.1.1"
    git log
        commit dc4e26807f244e5c269ddf6ff9f61e9f28910128 (HEAD -> main, tag: v0.1.1, TICKET-testing02)
        Author: username <example@mail.com>
        Date:   Thu May 16 10:02:43 2024 +0200

            TICKET-testing02 Testing 3
    
    gitversion -showvariable InformationalVersion
        0.1.1+Branch.main.Sha.dc4e26807f244e5c269ddf6ff9f61e9f28910128
    ~~~

1. Create a new branch `git checkout -b "TICKET-testing03"`
1. Check version

    ~~~sh
    gitversion -showvariable InformationalVersion
        0.1.1+Branch.TICKET-testing03.Sha.dc4e26807f244e5c269ddf6ff9f61e9f28910128
    ~~~

1. Create a commit like previously.
1. Check version

    ~~~sh
    gitversion -showvariable InformationalVersion
        0.1.1-testing03.1+Branch.TICKET-testing03.Sha.922f8997757036cfd8a191fcda205b1720f4dba4
    ~~~

1. Merge back into main and check version. Notice that version stays at `0.1.1`.

    ~~~sh
    git checkout main
    gitversion -showvariable InformationalVersion
        0.1.1+Branch.main.Sha.dc4e26807f244e5c269ddf6ff9f61e9f28910128
    git merge TICKET-testing03
    gitversion -showvariable InformationalVersion
        0.1.1+Branch.main.Sha.922f8997757036cfd8a191fcda205b1720f4dba4
    ~~~

1. Let's create a support/release branch and check version.

    ~~~sh
    git checkout -b "support-0.1"
    gitversion -showvariable InformationalVersion
        0.1.1+Branch.support-0.1.Sha.922f8997757036cfd8a191fcda205b1720f4dba4
    ~~~

1. Create 3 commits like previously and check version. Because the `PreReleaseNumber` doesn't increment, we can check `CommitsSinceVersionSource` for increment.

    Use jq to extract information

    ~~~sh
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'

        InformationalVersion: 0.1.1+Branch.support-0.1.Sha.669b2e517ec2554514259174ad54c85d5db1fbcf
        CommitsSinceVersionSource: 3
    ~~~

    Or without jq

    ~~~sh
    echo "InformationalVersion: $(gitversion -showvariable InformationalVersion)" \
        && echo "CommitsSinceVersionSource: $(gitversion -showvariable CommitsSinceVersionSource)"

        InformationalVersion: 0.1.1+Branch.support-0.1.Sha.669b2e517ec2554514259174ad54c85d5db1fbcf
        CommitsSinceVersionSource: 3
    ~~~

1. One more commit and version check.

    ~~~sh
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'

        InformationalVersion: 0.1.1+Branch.support-0.1.Sha.e7e1bb7a422bf869328b404e075f327fc5d7558f
        CommitsSinceVersionSource: 4
    ~~~

1. Checkout main, create new branch, create commit, check version, merge to main, tag version 0.2.0, and check version.

    ~~~sh
    git checkout main
    git checkout -b "TICKET-testing04"
    ((num++)) \
        && echo "Test $num" >> $(git branch --show-current) \
        && git add $(git branch --show-current) \
        && git commit -m "$(git branch --show-current) Testing $num"
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'
        InformationalVersion: 0.1.1-testing04.1+Branch.TICKET-testing04.Sha.be5fd28cf83ff67018f9d98f53b71b81d782da5c
        CommitsSinceVersionSource: 1
    git checkout main
    git merge "TICKET-testing04"
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'
        InformationalVersion: 0.2.0+Branch.main.Sha.be5fd28cf83ff67018f9d98f53b71b81d782da5c
        CommitsSinceVersionSource: 0
    ~~~

1. Checkout support-0.1, check version, create commit, check version, create new tag 0.1.2, and check version.

    ~~~sh
    git checkout -b "support-0.1"
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'
        InformationalVersion: 0.1.1+Branch.support-0.1.Sha.e7e1bb7a422bf869328b404e075f327fc5d7558f
        CommitsSinceVersionSource: 4
    ((num++)) \
        && echo "Test $num" >> $(git branch --show-current) \
        && git add $(git branch --show-current) \
        && git commit -m "$(git branch --show-current) Testing $num"
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'
        InformationalVersion: 0.1.1+Branch.support-0.1.Sha.3158934e43e98ffb02a788ca041f1c43ba9fd8cd
        CommitsSinceVersionSource: 5
    git tag -a v0.1.2 -m "Version 0.1.2"
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'
        InformationalVersion: 0.1.2+Branch.support-0.1.Sha.3158934e43e98ffb02a788ca041f1c43ba9fd8cd
        CommitsSinceVersionSource: 0
    ~~~

1. Checkout main and check version.

    ~~~sh
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'
        InformationalVersion: 0.2.0+Branch.main.Sha.be5fd28cf83ff67018f9d98f53b71b81d782da5c
        CommitsSinceVersionSource: 0
    ~~~

#### Test a fork

1. Create a fork from the repository (copy all branches or add support-0.1 branch separately).
1. Check information

    ~~~sh
    git checkout main

    # gitversion shows 0.2.0 version
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'
        InformationalVersion: 0.2.0+Branch.main.Sha.cc3cbeed7e41b58a7ce069587bbe6486356f9ede
        CommitsSinceVersionSource: 2

    # Tags are copied over
    git tag
        v0.1.1
        v0.1.2
        v0.2.0
    ~~~

1. Checkout support-0.1 and check version

    ~~~sh
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'
        InformationalVersion: 0.1.2+Branch.support-0.1.Sha.3158934e43e98ffb02a788ca041f1c43ba9fd8cd
        CommitsSinceVersionSource: 0
    ~~~

1. Create a commit, check version and push the commit.

    ~~~sh
    ((num++)) \
        && echo "Test $num" >> $(git branch --show-current) \
        && git add $(git branch --show-current) \
        && git commit -m "$(git branch --show-current) Testing $num"

    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'
        InformationalVersion: 0.1.2+Branch.support-0.1.Sha.c5e21c59bbd5beeec6d57ce9e81c4bdb6c6aa709
        CommitsSinceVersionSource: 1
    
    git push
    ~~~

1. Create a pull request into the original repository's support-0.1 branch and merge it.
1. Check from the original repository's support-0.1 branch version.

    ~~~sh
    gitversion | jq -r '"InformationalVersion: " + .InformationalVersion + "\nCommitsSinceVersionSource: " + (.CommitsSinceVersionSource|tostring)'
        InformationalVersion: 0.1.2+Branch.support-0.1.Sha.143ac75b7c45425b95f125bf3669629867694208
        CommitsSinceVersionSource: 2
    ~~~
