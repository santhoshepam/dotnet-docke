[cmdletbinding()]
param(
   [string]$OS="windowsservercore"
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

$dockerRepo="microsoft/dotnet-nightly"
$repoRoot = Split-Path -parent $PSScriptRoot

if ($env:DEBUGTEST -eq $null) {
    $optionalDockerRunArgs="--rm"
}
else {
    $optionalDockerRunArgs=""
}

pushd $repoRoot

Get-ChildItem -Directory -Exclude 'test', 'update-dependencies', '.*' | foreach {
    $tagBase="$($dockerRepo):$($_.Name)-$OS"

    $timeStamp = Get-Date -Format FileDateTime
    $appName="app$timeStamp"
    $appDir="${repoRoot}\.test-assets\${appName}"

    New-Item $appDir -type directory | Out-Null

    Write-Host "----- Testing $tagBase-sdk -----"
    docker run -t $optionalDockerRunArgs -v "$($appDir):c:\$appName" -v "$repoRoot\test:c:\test" --name "sdk-test-$appName" --entrypoint powershell "$tagBase-sdk" c:\test\create-run-publish-app.ps1 "c:\$appName"
    if (-NOT $?) {
        throw  "Testing $tagBase-sdk failed"
    }

    Write-Host "----- Testing $tagBase-core -----"
    docker run -t $optionalDockerRunArgs -v "$($appDir):c:\$appName" --name "core-test-$appName" --entrypoint dotnet "$tagBase-core" "C:\$appName\publish\$appName.dll"
    if (-NOT $?) {
        throw  "Testing $tagBase-core failed"
    }

    Write-Host "----- Testing $tagBase-onbuild -----"
    pushd $appDir
    $onbuildTag = "$appName-onbuild".ToLowerInvariant()
    New-Item -Name Dockerfile -Value "FROM $tagBase-onbuild" | Out-Null
    docker build -t $onbuildTag .
    popd
    if (-NOT $?) {
        throw  "Failed building $onbuildTag"
    }

    docker run -t $optionalDockerRunArgs --name "onbuild-test-$appName" $onbuildTag
    if (-NOT $?) {
        throw "Testing $tagBase-onbuild failed"
    }

    if ($env:DEBUGTEST -eq $null) {
        docker rmi $onbuildTag
        if (-NOT $?) {
            throw "Failed to delete $onbuildTag image"
        }
    }
}

popd
