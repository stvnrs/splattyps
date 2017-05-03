Write-Output 'building ...'

Copy-Item .\src\SplattyPS.* .\out\
New-ExternalHelp -Path .\docs\ -OutputPath .\out\en-us\ -Force

Write-Output 'building - done.'