Set-StrictMode -Version 'Latest'

if (-not (Get-Module -Name 'Pester')) {
    Import-Module -Name 'Pester'
}


try {
    $ModuleUnderTest = (resolve-path (join-path $PsScriptRoot  '..\src\SplattyPS.psd1')).Path
    Import-Module  -FullyQualifiedName  $ModuleUnderTest

    Describe 'Get-SplattedRunbook' {
        InModuleScope SplattyPS {
            Mock -CommandName Get-AzureRmAutomationRunbook -MockWith {
                Write-Verbose "Name: $Name" -Verbose        
                
                $Runbook = [PSCustomObject]@{
                    Location              = 'West Europe'
                    Tags                  = @{}
                    RunbookType           = 'PowerShell'
                    Parameters            = @{}
                    LogVerbose            = $False
                    LogProgress           = $False
                    LastModifiedBy        = 'user@example.com'
                    State                 = 'Published'
                    ResourceGroupName     = $ResourceGroupName
                    AutomationAccountName = $AutomationAccountName
                    Name                  = $Name
                    CreationTime          = (Get-Date -Year 2017 -Month 4 -Day 1)
                    LastModifiedTime      = (Get-Date -Year 2017 -Month 4 -Day 1)
                    Description           = 'lorem ipsum'
                }

                if ($Name -eq 'RunbookWithParams') {
                    $Runbook.Parameters = @{
                        MandatoryParam = [PSCustomObject]@{
                            Position    = 1
                            IsMandatory = $true
                            Type        = [System.String]
                        }
                        OptionalParam  = [PSCustomObject]@{
                            Position    = 2
                            IsMandatory = $false
                            Type        = [System.Int32]
                        }
                    }
                }

                return $Runbook     
            }

            It "When called with a positonal args returns only mandatory params RunbookWithParams" {
                $Expected = @(
                    '$Params = @{',
                    "    ResourceGroupName = 'example-resource-group'",
                    "    AutomationAccountName = 'example-automation-account'",
                    "    Name = 'RunbookWithParams'",
                    "    Parameters = @{",
                    "        MandatoryParam =   #mandatory"
                    "    }",
                    '}',
                    '',
                    '$Job = Start-AzureRmAutomationRunbook @Params'
                )
                
                $Actual = Get-SplattedRunbook 'example-resource-group' 'example-automation-account' -Name 'RunbookWithParams'
                
                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

            It "When called with a positonal args and allparams for a RunbookWithParams" {                
                $Expected = @(
                    '$Params = @{',
                    "    ResourceGroupName = 'example-resource-group'",
                    "    AutomationAccountName = 'example-automation-account'",
                    "    Name = 'RunbookWithParams'",
                    "    Parameters = @{",
                    "        MandatoryParam =   #mandatory"
                    "        OptionalParam =    #optional"
                    "    }",
                    '}',
                    '',
                    '$Job = Start-AzureRmAutomationRunbook @Params'
                )
                
                $Actual = Get-SplattedRunbook 'example-resource-group' 'example-automation-account' 'RunbookWithParams' -AllParameters
                
                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

            It "When called with a named arg for Runbook with no params..." {
                $Expected = @(
                    '$Params = @{',
                    "    ResourceGroupName = 'example-resource-group'",
                    "    AutomationAccountName = 'example-automation-account'",
                    "    Name = 'RunbookWithNoParams'",
                    "    Parameters = @{",
                    "    }",
                    '}',
                    '',
                    '$Job = Start-AzureRmAutomationRunbook @Params'
                )

                $Actual = Get-SplattedRunbook -ResourceGroupName 'example-resource-group' -AutomationAccountName 'example-automation-account' -Name 'RunbookWithNoParams'
                
                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

            # It "When called with AllParameters..." {
            #     $Expected = @(
            #         '$Params = @{',
            #         '    Name =                       #mandatory',
            #         '    HashTableName =              #optional',
            #         '    AssignmentVariableName =     #optional',
            #         '    AllParameters =              #optional',
            #         '    IncludeCommonParameters =    #optional',
            #         '    EmitScriptBlock =            #optional',
            #         '    ShowTypeHint =               #optional',
            #         '    ILoveSemiColons =            #optional',
            #         '    IndentSize =                 #optional',
            #         '    IndentLevel =                #optional',
            #         '    UseTabs =                    #optional',
            #         '    ResolveAlias =               #optional',
            #         '}',
            #         '',
            #         'Get-SplattedRunbook @Params'
            #     )

            #     $Actual = Get-SplattedRunbook -Name 'Get-SplattedRunbook' -AllParameters
                
            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }

            # It "When hash table name spcified, that name is emitted" {
            #     $Expected = @(
            #         '$SplattParams = @{',
            #         '    Name = #mandatory',
            #         '}',
            #         '',
            #         'Get-SplattedRunbook @SplattParams'
            #     )

            #     $Actual = Get-SplattedRunbook -name 'Get-SplattedRunbook' -HashTableName 'SplattParams'
                
            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }

            # It "When emit script block specified" {
            #     $Expected = @(
            #         'Invoke-Command {',
            #         '    $Params = @{',
            #         '        Name = #mandatory',
            #         '    }',
            #         '',
            #         '    Get-SplattedRunbook @Params',
            #         '}'
            #     )

            #     $Actual = Get-SplattedRunbook -name 'Get-SplattedRunbook' -EmitScriptBlock

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }


            # It "When i love semis specified" {
            #     $Expected = @(
            #         '$Params = @{',
            #         '    Name = ;#mandatory',
            #         '}',
            #         '',
            #         'Get-SplattedRunbook @Params;'
            #     )

            #     $Actual = Get-SplattedRunbook -name 'Get-SplattedRunbook' -ILoveSemiColons

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }

            # It "When Show Type hint specified" {
            #     $Expected = @(
            #         '$Params = @{',
            #         '    Name = #mandatory System.String[]',
            #         '}',
            #         '',
            #         'Get-SplattedRunbook @Params'
            #     )

            #     $Actual = Get-SplattedRunbook -name 'Get-SplattedRunbook' -ShowTypeHint

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }

            # It "When Compact specified" {
            #     $Expected = @(
            #         '$Params = @{Name = ;}',
            #         '',
            #         'Get-SplattedRunbook @Params'
            #     )

            #     $Actual = Get-SplattedRunbook -name 'Get-SplattedRunbook' -CompactHashTable

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }

            # It "When Compact specified will AllParameters" {
            #     $Expected = @(
            #         '$Params = @{Name = ;  HashTableName = ;  AssignmentVariableName = ;  AllParameters = ;  IncludeCommonParameters = ;  EmitScriptBlock = ;  ShowTypeHint = ;  ILoveSemiColons = ;  IndentSize = ;  IndentLevel = ;  UseTabs = ;  ResolveAlias = ;}',
            #         '',
            #         'Get-SplattedRunbook @Params'
            #     )

            #     $Actual = Get-SplattedRunbook -name 'Get-SplattedRunbook' -CompactHashTable -AllParameters

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }

            # It "When Name supplied from pipeline" {
            #     $Expected = @(
            #         '$Params = @{'
            #         '    Name = #mandatory',
            #         '}',
            #         '',
            #         'Get-SplattedRunbook @Params'
            #     )

            #     $Actual = 'Get-SplattedRunbook' | Get-SplattedRunbook

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }

            # It "When Name supplied from pipeline - multiple" {
            #     $Expected = @(
            #         '$Params = @{'
            #         '    Name = #mandatory',
            #         '}',
            #         '',
            #         'Get-SplattedRunbook @Params',
            #         '$Params = @{'
            #         '    Name = #mandatory',
            #         '}',
            #         '',
            #         'Get-SplattedRunbook @Params'
            #     )

            #     $Actual = 'Get-SplattedRunbook', 'Get-SplattedRunbook' | Get-SplattedRunbook

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }

            # It "When Name & HashTableName supplied from pipeline" {
            #     $Expected = @(
            #         '$SplattParams = @{'
            #         '    Name = #mandatory',
            #         '}',
            #         '',
            #         'Get-SplattedRunbook @SplattParams'
            #     )

            #     $Actual = [pscustomobject]@{Name = 'Get-SplattedRunbook'; HashTableName = 'SplattParams'} | Get-SplattedRunbook

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }    

            # It "When Name & HashTableName supplied from pipeline - multi" {
            #     $Expected = @(
            #         '$SplattParams = @{'
            #         '    Name = #mandatory',
            #         '}',
            #         '',
            #         'Get-SplattedRunbook @SplattParams',
            #         '$SplattParams2 = @{'
            #         '    Name = #mandatory',
            #         '}',
            #         '',
            #         'Get-SplattedRunbook @SplattParams2'
            #     )

            #     $Actual = [pscustomobject]@{Name = 'Get-SplattedRunbook'; HashTableName = 'SplattParams'}, [pscustomobject]@{Name = 'Get-SplattedRunbook'; HashTableName = 'SplattParams2'}| Get-SplattedRunbook

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }  

            # It "When Name, HashTableName & AssignementVariable supplied from pipeline" {
            #     $Expected = @(
            #         '$SplattParams = @{'
            #         '    Name = #mandatory',
            #         '}',
            #         '',
            #         '$Result = Get-SplattedRunbook @SplattParams'
            #     )

            #     $Pipe = [pscustomobject]@{
            #         Name                   = 'Get-SplattedRunbook'
            #         HashTableName          = 'SplattParams'
            #         AssignmentVariableName = 'Result'
            #     }                        

            #     $Actual = $Pipe | Get-SplattedRunbook

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # } 

            # It "When Name, HashTableName & AssignementVariable supplied from pipeline - multi" {
            #     $Expected = @(
            #         '$SplattParams1 = @{'
            #         '    Name = #mandatory',
            #         '}',
            #         '',
            #         '$Result1 = Get-SplattedRunbook @SplattParams1',
            #         '$SplattParams2 = @{'
            #         '    Name = #mandatory',
            #         '}',
            #         '',
            #         '$Result2 = Get-SplattedRunbook @SplattParams2'
            #     )

            #     $Pipe = [pscustomobject]@{Name = 'Get-SplattedRunbook'; HashTableName = 'SplattParams1'; AssignmentVariableName = 'Result1'}, 
            #     [pscustomobject]@{Name = 'Get-SplattedRunbook'; HashTableName = 'SplattParams2'; AssignmentVariableName = 'Result2'}

            #     $Actual = $Pipe | Get-SplattedRunbook

            #     for ($i = 0; $i -lt $Actual.Count; $i++) {
            #         $Actual[$i] | Should Be $Expected[$i]   
            #     }
            # }                    
        }
    }
} 
finally {

    if (Get-Module -Name 'Pester') {
        Remove-Module -Name 'Pester'
    }

    if (Get-Module -Name 'SplattyPS') {
        Remove-Module -Name 'SplattyPS'
    }
}
