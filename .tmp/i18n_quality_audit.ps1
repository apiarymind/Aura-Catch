$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$translationsPath = Join-Path $root 'assets/translations'
$enPath = Join-Path $translationsPath 'en.json'

$en = Get-Content -Raw -Path $enPath | ConvertFrom-Json
$enMap = @{}
foreach ($p in $en.PSObject.Properties) {
  $enMap[$p.Name] = [string]$p.Value
}

# Small heuristic dictionary for obviously English UI terms
$englishMarkers = @(
  'Current Price','Target Price','Pending','Buy','Delete Alert','Attributes','Status','Date added',
  'Store','Unlock with PRO','Item locked','Failed to','No item selected','Save ','Tracking for','Free window'
)

$jsonFiles = Get-ChildItem -Path $translationsPath -Filter '*.json' | Sort-Object Name
$totalSuspicious = 0

foreach ($file in $jsonFiles) {
  $name = $file.Name
  if ($name -match '^en([_-].+)?\.json$') {
    continue
  }

  $obj = Get-Content -Raw -Path $file.FullName | ConvertFrom-Json
  $props = @{}
  foreach ($p in $obj.PSObject.Properties) {
    $props[$p.Name] = [string]$p.Value
  }

  $sameAsEn = @()
  $containsEnglish = @()

  foreach ($k in $props.Keys) {
    $val = $props[$k]
    if ($enMap.ContainsKey($k) -and $val -eq $enMap[$k]) {
      $sameAsEn += $k
    }

    foreach ($marker in $englishMarkers) {
      if ($val -like "*$marker*") {
        $containsEnglish += $k
        break
      }
    }
  }

  $sameAsEn = @($sameAsEn | Sort-Object -Unique)
  $containsEnglish = @($containsEnglish | Sort-Object -Unique)

  $suspiciousKeys = @($sameAsEn + $containsEnglish | Sort-Object -Unique)
  $count = $suspiciousKeys.Count
  $totalSuspicious += $count

  if ($count -gt 0) {
    $sample = ($suspiciousKeys | Select-Object -First 20) -join ', '
    Write-Output ("SUSPECT|" + $name + "|" + $count + "|" + $sample)
  } else {
    Write-Output ("OK|" + $name)
  }
}

Write-Output ("TOTAL_SUSPECT_KEYS=" + $totalSuspicious)
