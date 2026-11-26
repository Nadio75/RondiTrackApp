function Invoke-ReleasePluginGuard {
    param(
        [Parameter(Mandatory)]
        [string]$RegistrantPath,

        [Parameter(Mandatory)]
        [scriptblock]$Build
    )

    if (-not (Test-Path -LiteralPath $RegistrantPath)) {
        throw "Generated plugin registrant missing."
    }

    $path = (Resolve-Path -LiteralPath $RegistrantPath).Path

    $originalBytes = [System.IO.File]::ReadAllBytes($path)

    $original = [System.IO.File]::ReadAllText($path)

    $pattern = '(?m)^[ \t]*try\s*\{\s*flutterEngine\.getPlugins\(\)\.add\(new dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin\(\)\);\s*\}\s*catch\s*\(Exception e\)\s*\{[^}]*\}[ \t]*\r?\n?'

    $found = [regex]::Matches($original, $pattern)

    if ($found.Count -gt 1) {
        throw "Ambiguous integration-test registration."
    }

    $updated = [regex]::Replace($original, $pattern, "")

    if ($updated.Contains("IntegrationTestPlugin")) {
        throw "Unexpected integration-test registration format."
    }

    $before = [regex]::Matches(
        $original,
        'flutterEngine\.getPlugins\(\)\.add\('
    ).Count

    $after = [regex]::Matches(
        $updated,
        'flutterEngine\.getPlugins\(\)\.add\('
    ).Count

    if ($after -ne ($before - $found.Count)) {
        throw "Unexpected plugin registration change."
    }

    try {

        if ($found.Count -eq 1) {

            [System.IO.File]::WriteAllText(
                $path,
                $updated,
                [System.Text.UTF8Encoding]::new($false)
            )

            Write-Host "Release-only plugin correction applied."
        }
        else {
            Write-Host "No integration-test registration to remove."
        }

        & $Build

    }
    finally {

        [System.IO.File]::WriteAllBytes(
            $path,
            $originalBytes
        )

        Write-Host "Original plugin registrant restored."
    }
}
