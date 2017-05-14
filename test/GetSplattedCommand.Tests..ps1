Set-StrictMode -Version 'Latest'

if(-not (Get-Module -Name 'Pester')){
    Import-Module -Name 'Pester'
}

try {
    $ModuleUnderTest = (resolve-path (join-path $PsScriptRoot  '..\src\SplattyPS.psd1')).Path
    Import-Module  -FullyQualifiedName  $ModuleUnderTest
    
    Describe 'Get-SplattedCommand' {
        InModuleScope SplattyPS {
            It "When called with a positonal args returns only mandatory params" {
                $Expected   = @(
                    '$Params = @{',
                    '    Name = #mandatory',
                    '}',
                    '',
                    'Get-SplattedCommand @Params'
                )

                $Actual = Get-SplattedCommand Get-SplattedCommand
                
                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

        It "When called with a named arg returns only mandatory params" {
                $Expected   = @(
                    '$Params = @{',
                    '    Name = #mandatory',
                    '}',
                    '',
                    'Get-SplattedCommand @Params'
                )

                $Actual = Get-SplattedCommand -Name 'Get-SplattedCommand'
                
                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

              It "When called with AllParameters..." {
                $Expected   = @(
                    '$Params = @{',
                    '    Name =                       #mandatory',
                    '    HashTableName =              #optional',
                    '    AssignmentVariableName =     #optional',
                    '    AllParameters =              #optional',
                    '    IncludeCommonParameters =    #optional',
                    '    EmitScriptBlock =            #optional',
                    '    ShowTypeHint =               #optional',
                    '    ILoveSemiColons =            #optional',
                    '    IndentSize =                 #optional',
                    '    IndentLevel =                #optional',
                    '    UseTabs =                    #optional',
                    '    ResolveAlias =               #optional',
                    '}',
                    '',
                    'Get-SplattedCommand @Params'
                )

                $Actual = Get-SplattedCommand -Name 'Get-SplattedCommand' -AllParameters
                
                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

               It "When hash table name spcified, that name is emitted" {
                $Expected   = @(
                    '$SplattParams = @{',
                    '    Name = #mandatory',
                    '}',
                    '',
                    'Get-SplattedCommand @SplattParams'
                )

                $Actual = Get-SplattedCommand -name 'Get-SplattedCommand' -HashTableName 'SplattParams'
                
                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

             It "When emit script block specified" {
                $Expected   = @(
                    'Invoke-Command {',
                    '    $Params = @{',
                    '        Name = #mandatory',
                    '    }',
                    '',
                    '    Get-SplattedCommand @Params',
                    '}'
                )

                $Actual = Get-SplattedCommand -name 'Get-SplattedCommand' -EmitScriptBlock

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }


             It "When i love semis specified" {
                $Expected   = @(
                    '$Params = @{',
                    '    Name = ;#mandatory',
                    '}',
                    '',
                    'Get-SplattedCommand @Params;'
                )

                $Actual = Get-SplattedCommand -name 'Get-SplattedCommand' -ILoveSemiColons

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

            It "When Show Type hint specified" {
                $Expected   = @(
                    '$Params = @{',
                    '    Name = #mandatory System.String[]',
                    '}',
                    '',
                    'Get-SplattedCommand @Params'
                )

                $Actual = Get-SplattedCommand -name 'Get-SplattedCommand' -ShowTypeHint

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

            It "When Compact specified" {
                $Expected   = @(
                    '$Params = @{Name = ;}',
                    '',
                    'Get-SplattedCommand @Params'
                )

                $Actual = Get-SplattedCommand -name 'Get-SplattedCommand' -CompactHashTable

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

            It "When Compact specified will AllParameters" {
                $Expected   = @(
                    '$Params = @{Name = ;  HashTableName = ;  AssignmentVariableName = ;  AllParameters = ;  IncludeCommonParameters = ;  EmitScriptBlock = ;  ShowTypeHint = ;  ILoveSemiColons = ;  IndentSize = ;  IndentLevel = ;  UseTabs = ;  ResolveAlias = ;}',
                    '',
                    'Get-SplattedCommand @Params'
                )

                $Actual = Get-SplattedCommand -name 'Get-SplattedCommand' -CompactHashTable -AllParameters

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

            It "When Name supplied from pipeline" {
                $Expected   = @(
                    '$Params = @{'
                    '    Name = #mandatory',
                    '}',
                    '',
                    'Get-SplattedCommand @Params'
                )

                $Actual = 'Get-SplattedCommand' | Get-SplattedCommand

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

            It "When Name supplied from pipeline - multiple" {
                $Expected   = @(
                    '$Params = @{'
                    '    Name = #mandatory',
                    '}',
                    '',
                    'Get-SplattedCommand @Params',
                    '$Params = @{'
                    '    Name = #mandatory',
                    '}',
                    '',
                    'Get-SplattedCommand @Params'
                )

                $Actual = 'Get-SplattedCommand', 'Get-SplattedCommand' | Get-SplattedCommand

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }

            It "When Name & HashTableName supplied from pipeline" {
                $Expected   = @(
                    '$SplattParams = @{'
                    '    Name = #mandatory',
                    '}',
                    '',
                    'Get-SplattedCommand @SplattParams'
                )

                $Actual =  [pscustomobject]@{Name = 'Get-SplattedCommand'; HashTableName = 'SplattParams'} | Get-SplattedCommand

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }    

             It "When Name & HashTableName supplied from pipeline - multi" {
                $Expected   = @(
                    '$SplattParams = @{'
                    '    Name = #mandatory',
                    '}',
                    '',
                    'Get-SplattedCommand @SplattParams',
                    '$SplattParams2 = @{'
                    '    Name = #mandatory',
                    '}',
                    '',
                    'Get-SplattedCommand @SplattParams2'
                )

                $Actual =  [pscustomobject]@{Name = 'Get-SplattedCommand'; HashTableName = 'SplattParams'}, [pscustomobject]@{Name = 'Get-SplattedCommand'; HashTableName = 'SplattParams2'}| Get-SplattedCommand

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }  

            It "When Name, HashTableName & AssignementVariable supplied from pipeline" {
                $Expected   = @(
                    '$SplattParams = @{'
                    '    Name = #mandatory',
                    '}',
                    '',
                    '$Result = Get-SplattedCommand @SplattParams'
                )

                $Pipe = [pscustomobject]@{
                    Name = 'Get-SplattedCommand'
                    HashTableName = 'SplattParams'
                    AssignmentVariableName = 'Result'
                }                        

                $Actual = $Pipe | Get-SplattedCommand

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            } 

             It "When Name, HashTableName & AssignementVariable supplied from pipeline - multi" {
                $Expected   = @(
                    '$SplattParams1 = @{'
                    '    Name = #mandatory',
                    '}',
                    '',
                    '$Result1 = Get-SplattedCommand @SplattParams1',
                    '$SplattParams2 = @{'
                    '    Name = #mandatory',
                    '}',
                    '',
                    '$Result2 = Get-SplattedCommand @SplattParams2'
                )

                $Pipe = [pscustomobject]@{Name = 'Get-SplattedCommand'; HashTableName = 'SplattParams1'; AssignmentVariableName = 'Result1'}, 
                        [pscustomobject]@{Name = 'Get-SplattedCommand'; HashTableName = 'SplattParams2'; AssignmentVariableName = 'Result2'}

                $Actual = $Pipe | Get-SplattedCommand

                for ($i = 0; $i -lt $Actual.Count; $i++) {
                    $Actual[$i] | Should Be $Expected[$i]   
                }
            }                    
        }
    }
} 
finally {

    if(Get-Module -Name 'Pester'){
        Remove-Module -Name 'Pester'
    }

    if(Get-Module -Name 'SplattyPS'){
        Remove-Module -Name 'SplattyPS'
    }
}
