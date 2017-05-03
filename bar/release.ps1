Write-Output 'releasing ...'

$ApiKey = $Env:ApiKey

Publish-Module  -Name SplattyPS -NuGetApiKey $ApiKey

Write-Output 'releasing - done.'