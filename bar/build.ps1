Set-StrictMode -Version 'Latest'
$ErrorActionPrefernce = 'Stop'

Write-Output 'building ...'

if(Test-Path .\out){
    rm .\out\* -Recurse
} else {
    md .\out
}
Copy-Item .\src\SplattyPS.* .\out\

Import-Module PlatyPS
New-ExternalHelp -Path .\docs\ -OutputPath .\out\en-us\ -Force

Write-Output 'building - done.'