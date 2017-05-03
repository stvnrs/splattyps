---
external help file: SplattyPS-help.xml
online version: https://github.com/stvnrs/splattyps/wiki/Get-a-splatted-command
schema: 2.0.0
---

# Get-SplattedCommand

## SYNOPSIS
Generate a splatted command invocation for the specified command.

## SYNTAX

### Regular (Default)
```
Get-SplattedCommand [-Name] <String> [-HashTableName <String>] [-ParameterSet <String>] [-AllParameters]
 [-IncludeCommonParameters] [-EmitScriptBlock] [-ShowTypeHint] [-ILoveSemiColons] [-IndentSize <Int32>]
 [-IndentLevel <Int32>] [-UseTabs] [-ResolveAlias] [-AssignmentVariableName <String>] [<CommonParameters>]
```

### Compact
```
Get-SplattedCommand [-Name] <String> [-HashTableName <String>] [-ParameterSet <String>] [-AllParameters]
 [-IncludeCommonParameters] [-EmitScriptBlock] [-CompactHashTable] [-ILoveSemiColons] [-IndentSize <Int32>]
 [-IndentLevel <Int32>] [-UseTabs] [-ResolveAlias] [-AssignmentVariableName <String>] [<CommonParameters>]
```

## DESCRIPTION
Generate a splatted command invocation for the specified command.

## EXAMPLES

### Example 1 Get a splatted command
```
$Params = @{
    Name =  #mandatory
}

Get-SplattedCommand @Params
PS C:\>
```

### Example 2 Get a splatted command with all parameters
```
PS C:\> Get-SplattedCommand Get-SplattedCommand -AllParameters
$Params = @{
    Name =                        #mandatory
    HashTableName =               #optional
    ParameterSet =                #optional
    AllParameters =               #optional
    IncludeCommonParameters =     #optional
    EmitScriptBlock =             #optional
    ShowTypeHint =                #optional
    CompactHashTable =            #optional
    ILoveSemiColons =             #optional
    IndentSize =                  #optional
    IndentLevel =                 #optional
    UseTabs =                     #optional
    ResolveAlias =                #optional
    AssignmentVariableName =      #optional
}


Get-SplattedCommand @Params
PS C:\>
```

### Example 3 Get a splatted command with all parameters and common parameters
```
PS C:\> Get-SplattedCommand Get-SplattedCommand -AllParameters -IncludeCommonParameters
$Params = @{
    Name =                        #mandatory 
    HashTableName =               #optional 
    ParameterSet =                #optional 
    AllParameters =               #optional 
    IncludeCommonParameters =     #optional 
    EmitScriptBlock =             #optional 
    ShowTypeHint =                #optional 
    CompactHashTable =            #optional 
    ILoveSemiColons =             #optional 
    IndentSize =                  #optional 
    IndentLevel =                 #optional 
    UseTabs =                     #optional 
    ResolveAlias =                #optional 
    AssignmentVariableName =      #optional 
    Verbose =                     #optional 
    Debug =                       #optional 
    ErrorAction =                 #optional 
    WarningAction =               #optional 
    InformationAction =           #optional 
    ErrorVariable =               #optional 
    WarningVariable =             #optional 
    InformationVariable =         #optional 
    OutVariable =                 #optional 
    OutBuffer =                   #optional 
    PipelineVariable =            #optional 
}

Get-SplattedCommand @Params
PS C:\>
```

### Example 4 Specify the name of the splattable hashtable
```
PS C:\> Get-SplattedCommand Get-SplattedCommand -HashTableName 'SplattedParams'
$SplattedParams = @{
    Name =  #mandatory
}

Get-SplattedCommand @SplattedParams
PS C:\>
```

### Example 5 Assign the result to a variable
```
PS C:\> Get-SplattedCommand Get-SplattedCommand -AssignmentVariableName 'Result'
$Params = @{
    Name =  #mandatory
}

$Result = Get-SplattedCommand @Params
PS C:\>
```

### Example 6 Get a splattable command in a script block
```
PS C:\> Get-SplattedCommand Get-SplattedCommand -AssignmentVariableName 'Result' -EmitScriptBlock
Invoke-Command {
    $Params = @{
        Name =  #mandatory
    }

    $Result = Get-SplattedCommand @Params
}
PS C:\>
```

### Example 7 Get a type hint for each parameter
```
PS C:\> Get-SplattedCommand Get-SplattedCommand -ShowTypeHint
$Params = @{
    Name =  #mandatory System.String
}

Get-SplattedCommand @Params
PS C:\>
```

### Example 8 Specify a parameter set
```
PS C:\> Get-SplattedCommand Get-Help -ParameterSet Online
$Params = @{
    Online =    #mandatory
}

Get-Help @Params
PS C:\> 
PS C:\> Get-SplattedCommand Get-Help -ParameterSet Examples
$Params = @{
    Examples =  #mandatory
}

Get-Help @Params
PS C:\>
```

## PARAMETERS

### -AllParameters
Include both mandatory and optional paramers.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: All

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AssignmentVariableName
The name of a variable to assign the result of invoking the command.

```yaml
Type: String
Parameter Sets: (All)
Aliases: avn

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CompactHashTable
Emit a single line hash table. (Not really a good idea :))

```yaml
Type: SwitchParameter
Parameter Sets: Compact
Aliases: c

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EmitScriptBlock
Emits a script block.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: esb

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HashTableName
Name of the hash table used for splatting.

```yaml
Type: String
Parameter Sets: (All)
Aliases: htn

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ILoveSemiColons
If specifed all (non-blank) lines are terminated with a semi-colon.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ILoveSemis

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeCommonParameters
Includes common parameters (if the command suport them)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: icp

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndentLevel
Initial indent level. Default 0.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: il

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IndentSize
The number of characters for each indent. Default 4 with spaces, default 1 with tabs.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: is

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the command.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ParameterSet
The parameter set to use.

```yaml
Type: String
Parameter Sets: (All)
Aliases: ps

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResolveAlias
Emit the command name instead of an alias, if an alias was specified.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ra

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowTypeHint
Emit a type hint for each parameter.

```yaml
Type: SwitchParameter
Parameter Sets: Regular
Aliases: sth

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseTabs
Emit Tabs instead of spaces.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ut, nooooo

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS

