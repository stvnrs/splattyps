Set-StrictMode -Version 'Latest'

function Get-SplattedCommand {
    [CmdletBinding(DefaultParameterSetName = 'Regular')]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]        
        [string[]]$Name,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('htn')]
        [string]$HashTableName = 'Params',

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('avn')]
        [ValidateNotNullOrEmpty()]
        [string]$AssignmentVariableName,

        [Alias('All')]
        [switch]$AllParameters,
    
        [Alias('icp')]
        [switch]$IncludeCommonParameters,
        
        [Alias('esb')]
        [switch]$EmitScriptBlock,
        
        [Parameter(ParameterSetName = 'Regular')]
        [Alias('sth')]
        [switch]$ShowTypeHint,

        [Parameter(Mandatory = $true, ParameterSetName = 'Compact')]
        [Alias('c')]
        [switch]$CompactHashTable,

        [Alias('ILoveSemis')]
        [switch]$ILoveSemiColons,

        [Alias('is')]
        [int]$IndentSize = 4,

        [Alias('il')]
        [int]$IndentLevel = 0,

        [Alias('ut', 'nooooo')]
        [Switch]$UseTabs,

        [Alias('ra')]
        [Switch]$ResolveAlias        
    )

    DynamicParam {
        $ParameterName = "ParameterSet"        

        if ($PSBoundParameters.ContainsKey('Name')) {
            if ($PSBoundParameters['Name'].Length -eq 1) {
                $Command = (Get-Command $Name)

                if ($Command.CommandType -eq 'Alias') {
                    $Command = (Get-Command $Command.Definition)
                }

                $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
                $ParameterAttribute.ParameterSetName = "__AllParameterSets"
                $ParameterAttribute.Mandatory = $false                
                $Values = $Command.ParameterSets.Name
        
                if ($Values) {
                    $ValidateSet = New-Object 'System.Management.Automation.ValidateSetAttribute' -ArgumentList($Values)            
                }

                $Attributes = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
                $Attributes.Add($ParameterAttribute)
                $Attributes.Add($ValidateSet)
                $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $Attributes)
                $Parameters = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
                $Parameters.Add($Parameter.Name, $Parameter)
        
                return $Parameters
            }
        }
    }

    begin {
        $CommonParamNames = 'Debug', 'Verbose', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'WhatIf', 'Confirm'

        $IndentChar = ' '

        if ($UseTabs.IsPresent) {
            $IndentChar = "`t"

            if (-not $PSBoundParameters.ContainsKey('IndentSize')) {
                $IndentSize = 1
            }
        }
        
        $Indent = $IndentChar * $IndentSize

        if ($ILoveSemiColons.IsPresent) {
            $LineEnding = ';'
        } 
        else {
            $LineEnding = ''
        }

        $Assignment = ''
    }   

    process {        
        $Name | ForEach-Object {
            $Command = (Get-Command $Name)

            if ($Command.CommandType -eq 'Alias') {
                $Command = (Get-Command $Command.Definition)
                if ($ResolveAlias.IsPresent) {
                    $Name = $Command.Name
                }
            }

            $DefaultParameterSet = $PSBoundParameters["ParameterSet"]
            
            if (!$DefaultParameterSet) {
                $DefaultParameterSet = $Command.DefaultParameterSet
            }
        
            if (!$DefaultParameterSet) {
                $DefaultParameterSet = "__AllParameterSets"
            }

            Write-Verbose "DefaultParameterSet = $DefaultParameterSet"
            
            $Output = @()
            
            if ($AssignmentVariableName) {
                $Assignment = "`$$AssignmentVariableName = "
            }

            if ($EmitScriptBlock.IsPresent) {
                $Output += "$($Indent * $IndentLevel)Invoke-Command {"
                $IndentLevel++
            }   

            $IndentLevel++       
            
            $MaxLength = 0

            ($Command.ParameterSets | Where-Object Name -eq $DefaultParameterSet).Parameters | ForEach-Object {        
                if ($AllParameters.IsPresent -or $_.IsMandatory) {
                    $MaxLength = [math]::Max($_.Name.Length, $MaxLength)
                }
            }                    

            $MaxLength = $MaxLength + ($MaxLength % 4)
            
            $ParamsOutput = @()
            
            ($Command.ParameterSets | Where-Object Name -eq $DefaultParameterSet).Parameters | ForEach-Object {
                if ($AllParameters.IsPresent -or $_.IsMandatory) {
                    if ($_.IsMandatory) {
                        $MandatoryComment = 'mandatory'
                    }
                    else {
                        $MandatoryComment = 'optional'
                    }

                    if ($ShowTypeHint.IsPresent) {
                        $TypeHint = ' ' + $_.ParameterType.ToString()
                    } 
                    else {
                        $TypeHint = ''
                    }

                    if ($IncludeCommonParameters -or $_.Name -inotin $CommonParamNames) {
                        $x = ' ' * ($MaxLength - $_.Name.Length)
                        $Param = "$($_.Name) = $LineEnding"
                        
                        if (-not $CompactHashTable.IsPresent) {            
                            $Param = "$($Indent * $IndentLevel)$Param$($x)#$mandatoryComment$TypeHint"
                        }
        
                        $ParamsOutput += $Param                    
                    }
                }    
            }
            
            $IndentLevel--
            
            if ($CompactHashTable.IsPresent) {
                $Output += "$($Indent * $IndentLevel)`$$HashTableName = @{$([string]::join(';  ', $ParamsOutput));}";
            } 
            else {
                $Output += "$($Indent * $IndentLevel)`$$HashTableName = @{"
                $Output += $ParamsOutput;
                $Output += "$($Indent * $IndentLevel)}"
            }
        
            $Output += ''
            $Output += "$($Indent * $IndentLevel)$Assignment$($name) @$($HashTableName)$($LineEnding)"

            if ($EmitScriptBlock.IsPresent) {
                $IndentLevel--
                $Output += "$($Indent * $IndentLevel)}"
            }

            Write-Output $Output    
        }
    }
}

function Get-SplattedRunbook {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]        
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]        
        [string]$AutomationAccountName,

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidateNotNullOrEmpty()]        
        [string]$Name,

        [Alias('All')]
        [switch]$AllParameters,
        
        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]        
        [string]$TagName,
        
        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]        
        [string]$TagValue,

        [Alias('w')]
        [switch]$Wait,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $false)]
        [Alias('htn')]
        [string]$HashTableName = 'Params',
                    
        [Alias('esb')]
        [switch]$EmitScriptBlock,
        
        [Alias('sth')]
        [switch]$ShowTypeHint,

        [Alias('ILoveSemis')]
        [switch]$ILoveSemiColons,

        [Alias('is')]
        [int]$IndentSize = 4,

        [Alias('il')]
        [int]$IndentLevel = 0
    )

    process {
        if ($PSBoundParameters.ContainsKey('Name')) {
            $Runbook = Get-AzureRmAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $Name
        }
        else {
            $Runbook = Get-AzureRmAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName

            if ($PSBoundParameters.ContainsKey('TagName') ) {
                $Runbook = $Runbook | % {
                    $rb = $_ | Get-AzureRmAutomationRunbook 
    
                    Write-Verbose "Checking $($rb.name)" -Verbose

                    if ( $Rb.Tags.ContainsKey($TagName)) {
                        if (-not $PSBoundParameters.ContainsKey('TagValue')) {
                            $rb 
                        }
                        elseif ($Rb.Tags[$TagName] -eq $TagValue) {
                            $Rb
                        }
                    }
                } 
            }
        }

        $Runbook | ForEach-Object {
            $Rb = $_ | Get-AzureRmAutomationRunbook

            $Indent = ' ' * $IndentSize
        
            if ($ILoveSemiColons.IsPresent) {
                $LineEnding = ';'
            } 
            else {
                $LineEnding = ''
            }

            $Output = @()
            
            if ($EmitScriptBlock.IsPresent) {
                $Output += "$($Indent * $IndentLevel)Invoke-Command {"
                $IndentLevel++
            }        
            $Output += "$($Indent * $IndentLevel)`$$HashTableName = @{"
            $IndentLevel++       

            $Output += "$($Indent * $IndentLevel)ResourceGroupName = '$ResourceGroupName'"
            $Output += "$($Indent * $IndentLevel)AutomationAccountName = '$AutomationAccountName'"
            $Output += "$($Indent * $IndentLevel)Name = '$($Rb.Name)'"
            $Output += "$($Indent * $IndentLevel)Parameters = @{"
            $IndentLevel++


            $Parameters = $Rb.Parameters.GetEnumerator() |   Sort-Object {$_.Value.Position} 

            $MaxLength = 0

            foreach ($Parameter in $Parameters) {
                if ($AllParameters.IsPresent -or $Parameter.Value.IsMandatory) {
                    $MaxLength = [Math]::Max($Parameter.Name.Length, $MaxLength)
                }
            }

            $MaxLength = $MaxLength + ($MaxLength % 4)
            
            foreach ($Parameter in $Parameters) {
               if ($AllParameters.IsPresent -or $Parameter.Value.IsMandatory) {
                    if ($Parameter.Value.IsMandatory) {
                        $MandatoryComment = '#mandatory'
                    }
                    else {
                        $MandatoryComment = '#optional'
                    }

                    if ($ShowTypeHint.IsPresent) {
                        $TypeHint = ' ' + $Parameter.Value.Type.ToString()
                    } 
                    else {
                        $TypeHint = ''
                    }
                    
                    $x = ' ' * ($MaxLength - $Parameter.Key.Length)
                    $Output += "$($Indent * $IndentLevel)$($Parameter.Key) = $LineEnding$($x)$mandatoryComment$TypeHint"
                }
            }

            $IndentLevel--
            $Output += "$($Indent * $IndentLevel)}"
            $IndentLevel--

            $Output += "$($Indent * $IndentLevel)}"
            $Output += ''
            $Output += "$($Indent * $IndentLevel)`$Job = Start-AzureRmAutomationRunbook @$($HashTableName)$($LineEnding)$(if($Wait.IsPresent){' -Wait'})"

            if ($EmitScriptBlock.IsPresent) {
                $IndentLevel--
                $Output += "$($Indent * $IndentLevel)}"
            }

            Write-Output $Output        
        }    
    }
}