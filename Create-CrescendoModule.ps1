$files = Get-ChildItem -Path ./json -Filter "*.json"
$null = Get-ChildItem -Path ./psm1 -Filter "*.psm1" | Remove-Item
if (Test-Path GSM.psm1) {
    $null = Remove-Item GSM.psm1
}
foreach($file in $files) {
    Export-CrescendoModule -ConfigurationFile $file.FullName -ModuleName ("./psm1/" + ($file.Name).Replace(".json",".psm1"))
    #$null = Remove-Item $file.FullName
}
Get-Content -Path ./Invoke-GSM.ps1 -Raw  >> GSM.psm1
$original = Get-Content -Path ./crescendo_original.txt -Raw
$new = '    Invoke-GSM -OriginalParams $PSBoundParameters -ParameterMap $__PARAMETERMAP -OutputHandlers $__outputHandlers -CommandArgs $__commandArgs'
$modules = Get-ChildItem -Path ./psm1 -Filter "*.psm1"
$commandNames = @()
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
    $commandName = ($command.ToString()).Replace("-","-GSM")
    $commandNames += $commandName
    "Function " + $commandName + " {`n`n" + ($command.Definition).Replace($original, $new)  + "}`n`n" >> GSM.psm1
    $null = Remove-Item $module.FullName
}
"Export-ModuleMember -Function " + ($commandNames -join ", ") >> GSM.psm1
