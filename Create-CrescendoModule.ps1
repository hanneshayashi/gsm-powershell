function Update-ModuleDefinition {
    param(
        [String]$def
    )

    $replacements = @{
        '$MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $PSBoundParameters[$_.Name]}).ForEach({$PSBoundParameters[$_.Name] = [switch]::new($false)})' = ""
        '$__commandArgs | & $__handler' = '$__commandArgs | Foreach-Object $__handler'
        'if ( $value -is [switch] ) { $__commandArgs += if ( $value.IsPresent ) { $param.OriginalName } else { $param.DefaultMissingValue } }' = 'if ( $value -is [switch] ) { $__commandArgs += if ( $null -ne $PSBoundParameters.$paramName ) { if(!$value.ToBool()) {$param.OriginalName + "=false"} else {$param.OriginalName}} else { $param.DefaultMissingValue } }'
    }
    foreach($key in $replacements.Keys) {
        $def = $def.Replace($key, $replacements.$key)
    }
    return $def
}

$files = Get-ChildItem -Path ./json -Filter "*.json"
$null = Get-ChildItem -Path ./psm1 -Filter "*.psm1" | Remove-Item
if (Test-Path GSM.psm1) {
    $null = Remove-Item GSM.psm1
}
foreach($file in $files) {
    Export-CrescendoModule -ConfigurationFile $file.FullName -ModuleName ("./psm1/" + ($file.Name).Replace(".json",".psm1"))
    $null = Remove-Item $file.FullName
}
$modules = Get-ChildItem -Path ./psm1 -Filter "*.psm1"
foreach($module in $modules) {
    $moduleName = ($module.Name).Replace(".psm1","")
    Remove-Module $moduleName -ErrorAction Ignore -WarningAction Ignore
    Import-Module $module.FullName -Global -WarningAction Ignore
    $foo = ($moduleName).Split("_")
    if ($foo.Count -eq 2) {
        $fName = $foo[1] + "-" + $foo[0]   
    } else {
        $fName = $foo[1] + "-" + $foo[0]+$foo[2]
    }
    $command = Get-Command $fName
    "Function " + ($command.ToString()).Replace("-","-GSM") + " {`n`n" + (Update-ModuleDefinition -def $command.Definition)  + "}`n`n" >> GSM.psm1
    $null = Remove-Item $module.FullName
}
