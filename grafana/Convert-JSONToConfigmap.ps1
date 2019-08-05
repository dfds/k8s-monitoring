# Import all JSON files in folder
$JSONFiles = Get-ChildItem -Name -File -Filter '*.json' -Path ".\dashboards"

Write-Output "Deploying the following ConfigMaps:"

foreach ($File in $JSONFiles) {
    $DASHBOARD_NAME = ($File.Substring(0,$File.Length-19) -replace ' ','-').ToLower()

    # Generate configmap, indenting JSON 4 spaces
    (Get-Content .\template-dashboard-cm.yaml) -replace "DASHBOARD_NAME", $DASHBOARD_NAME | Out-File .\configmaps\$($DASHBOARD_NAME)-cm.yaml
    '    ' + (Get-Content .\dashboards\$($File) -Raw) -replace "`n", "`n    " | Out-File .\configmaps\$($DASHBOARD_NAME)-cm.yaml -Append

    Get-ChildItem -Name -Path ".\configmaps"
}