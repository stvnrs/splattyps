Write-Output 'releasing ...'

$ApiKey = $Env:ApiKey

Publish-Module  -Name SplattyPS -NuGetApiKey $ApiKey -RequiredVersion 0.2

Write-Output 'releasing - done.'