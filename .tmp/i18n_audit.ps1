$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$libPath = Join-Path $root 'lib'
$translationsPath = Join-Path $root 'assets/translations'

$allUsedKeys = @()
$regex = [regex]"\btr\(\s*'([^']+)'"

Get-ChildItem -Path $libPath -Recurse -Filter '*.dart' | ForEach-Object {
  $content = Get-Content -Raw -Path $_.FullName
  if ([string]::IsNullOrEmpty($content)) { return }
  foreach ($match in $regex.Matches($content)) {
    $allUsedKeys += $match.Groups[1].Value
  }
}

$usedKeys = @($allUsedKeys | Sort-Object -Unique)

Write-Output ("USED_KEYS_COUNT=" + $usedKeys.Count)

$jsonFiles = Get-ChildItem -Path $translationsPath -Filter '*.json' | Sort-Object Name
$missingTotal = 0

foreach ($file in $jsonFiles) {
  try {
    $json = Get-Content -Raw -Path $file.FullName | ConvertFrom-Json
    $present = @($json.PSObject.Properties.Name)
    $missing = @($usedKeys | Where-Object { $_ -notin $present })

    if ($missing.Count -gt 0) {
      $missingTotal += $missing.Count
      $sample = ($missing | Select-Object -First 20) -join ', '
      Write-Output ("MISSING|" + $file.Name + "|" + $missing.Count + "|" + $sample)
    } else {
      Write-Output ("OK|" + $file.Name)
    }
  }
  catch {
    Write-Output ("ERROR|" + $file.Name + "|" + $_.Exception.Message)
  }
}

Write-Output ("MISSING_TOTAL=" + $missingTotal)
