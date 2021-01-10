function Invoke-GSM {
    param(
        [Parameter()]$OriginalParams,
        [Parameter()]$ParameterMap,
        [Parameter()]$OutputHandlers,
        [Parameter()]$CommandArgs
    )
    
    if ($OriginalParams["Debug"]) { Wait-Debugger }
    foreach ($paramName in $OriginalParams.Keys | Sort-Object { $ParameterMap[$_].OriginalPosition }) {
        $value = $OriginalParams[$paramName]
        $param = $ParameterMap[$paramName]
        if ($param) {
            if ( $value -is [switch] ) { $CommandArgs += if ( $null -ne $OriginalParams.$paramName ) { if (!$value.ToBool()) { $param.OriginalName + "=false" } else { $param.OriginalName } } else { $param.DefaultMissingValue } }
            elseif ( $param.NoGap ) { $CommandArgs += "{0}""{1}""" -f $param.OriginalName, $value }
            else { $CommandArgs += $param.OriginalName; $CommandArgs += $value | ForEach-Object { $_ } }
        }
    }
    $CommandArgs = $CommandArgs | Where-Object { $_ }
    if ($OriginalParams["Debug"]) { Wait-Debugger }
    if ( $OriginalParams["Verbose"]) {
        Write-Verbose -Verbose -Message gsm
        $CommandArgs | Write-Verbose -Verbose
    }
    $__handlerInfo = $OutputHandlers[$PSCmdlet.ParameterSetName]
    if (! $__handlerInfo ) {
        $__handlerInfo = $OutputHandlers["Default"] # Guaranteed to be present
    }
    $__handler = $__handlerInfo.Handler
    if ( $__handlerInfo.StreamOutput ) {
        & "gsm" $CommandArgs | ForEach-Object $__handler
    }
    else {
        $result = & "gsm" $CommandArgs
        & $__handler $result
    }
}

