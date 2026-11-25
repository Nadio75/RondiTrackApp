param(
    [Parameter(Mandatory = $true)]
    [string]$Tag,

    [Parameter(Mandatory = $true)]
    [int]$BuildNumber,

    [ValidateSet("all", "staging", "prod")]
    [string]$Target = "all",

    [string]$ExpectedFingerprint = $env:RELEASE_CERT_SHA256,

    [switch]$ValidateOnly
)

$ErrorActionPreference = "Stop"

Set-Location (Split-Path $PSScriptRoot -Parent)

function Invoke-Checked {
    param(
        [string]$Command,
        [string[]]$Arguments
    )

    & $Command @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $Command"
    }
}

function Normalize-Fingerprint {
    param([string]$Value)

    return ($Value -replace '[:\s]', '').ToUpperInvariant()
}

if ($Tag -notmatch '^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$') {
    throw "Invalid release tag. Expected vX.Y.Z."
}

if ($BuildNumber -lt 1 -or $BuildNumber -gt 2100000000) {
    throw "Invalid Android build number."
}

$version = $Tag.Substring(1)

$expected = Normalize-Fingerprint $ExpectedFingerprint

if ($expected -notmatch '^[A-F0-9]{64}$') {
    throw "A valid expected SHA256 certificate is required."
}

if (-not (Test-Path "android/key.properties")) {
    throw "Release signing refused: key.properties missing."
}

$tagCommit = git rev-parse --verify "refs/tags/${Tag}^{commit}" 2>$null

if ($LASTEXITCODE -ne 0) {
    throw "Release tag does not exist locally."
}

$headCommit = git rev-parse HEAD

if ($LASTEXITCODE -ne 0 -or $tagCommit -ne $headCommit) {
    throw "Release tag must identify the current commit."
}

$changes = @(git status --porcelain --untracked-files=all -- .)

if ($LASTEXITCODE -ne 0 -or $changes.Count -gt 0) {
    throw "Mobile working tree must be clean before release."
}

if (-not $env:JAVA_HOME -and $env:OS -eq "Windows_NT") {
    $env:JAVA_HOME = "$env:ProgramFiles\Android\Android Studio\jbr"
}

if (-not $env:JAVA_HOME) {
    throw "JAVA_HOME is required."
}

$javaBin = Join-Path $env:JAVA_HOME "bin"

if ($env:OS -eq "Windows_NT") {
    $keytool = Join-Path $javaBin "keytool.exe"
    $jarsigner = Join-Path $javaBin "jarsigner.exe"
    $env:Path = "$javaBin;$env:Path"
    $signerName = "apksigner.bat"
} else {
    $keytool = Join-Path $javaBin "keytool"
    $jarsigner = Join-Path $javaBin "jarsigner"
    $env:Path = "${javaBin}:$env:Path"
    $signerName = "apksigner"
}

$sdk = $env:ANDROID_SDK_ROOT

if (-not $sdk) {
    $sdk = $env:ANDROID_HOME
}

if (-not $sdk -and $env:OS -eq "Windows_NT") {
    $sdk = "$env:LOCALAPPDATA\Android\Sdk"
}

if (-not $sdk -or -not (Test-Path $sdk)) {
    throw "Android SDK not found."
}

$apksigner = Join-Path $sdk "build-tools/37.0.0/$signerName"

foreach ($tool in @($keytool, $jarsigner, $apksigner)) {
    if (-not (Test-Path $tool)) {
        throw "Required signing tool missing: $tool"
    }
}

$flavours = if ($Target -eq "all") {
    @("staging", "prod")
} else {
    @($Target)
}

$apiAddresses = @{}

# Validate all requested environments before compiling.
foreach ($flavour in $flavours) {

    $configPath = "config/$flavour.json"
    $firebasePath = "config/firebase.$flavour.json"

    if (-not (Test-Path $configPath)) {
        throw "Missing $flavour configuration."
    }

    $config = Get-Content $configPath -Raw |
        ConvertFrom-Json

    if ($config.APP_FLAVOR -ne $flavour) {
        throw "Configuration flavour mismatch."
    }

    $apiAddress = if ($flavour -eq "staging") {
        $env:API_BASE_URL_STAGING
    } else {
        $env:API_BASE_URL_PROD
    }

    if ([string]::IsNullOrWhiteSpace($apiAddress)) {
        $apiAddress = [string]$config.API_BASE_URL
    }

    $apiAddresses[$flavour] = $apiAddress

    $uri = $null

    if (
        -not [Uri]::TryCreate(
            $apiAddress,
            [UriKind]::Absolute,
            [ref]$uri
        )
    ) {
        throw "Invalid API address for $flavour."
    }

    if (
        $uri.Scheme -ne "https" -or
        $uri.IsLoopback -or
        $uri.Host -match '\.invalid$'
    ) {
        throw "A real HTTPS API address is required for $flavour."
    }

    if (-not (Test-Path $firebasePath)) {
        throw "Missing Firebase configuration for $flavour."
    }

    $allowedConfigKeys = @("APP_FLAVOR", "API_BASE_URL")

    foreach ($property in $config.PSObject.Properties.Name) {
        if ($property -cnotin $allowedConfigKeys) {
            throw "Unexpected application configuration key."
        }
    }

    $firebase = Get-Content $firebasePath -Raw |
        ConvertFrom-Json

    foreach ($key in @(
        "FIREBASE_API_KEY",
        "FIREBASE_APP_ID",
        "FIREBASE_MESSAGING_SENDER_ID",
        "FIREBASE_PROJECT_ID"
    )) {
        if ([string]::IsNullOrWhiteSpace(
            [string]$firebase.$key
        )) {
            throw "Missing Firebase setting: $key"
        }
    }

    $allowedFirebaseKeys = @(
        "FIREBASE_API_KEY",
        "FIREBASE_APP_ID",
        "FIREBASE_MESSAGING_SENDER_ID",
        "FIREBASE_PROJECT_ID"
    )

    foreach ($property in $firebase.PSObject.Properties.Name) {
        if ($property -cnotin $allowedFirebaseKeys) {
            throw "Unexpected Firebase configuration key."
        }
    }

    Write-Host "$flavour configuration validated."
}

Write-Host "Release version: $version"
Write-Host "Build number: $BuildNumber"

if ($ValidateOnly) {
    Write-Host "Release preflight passed."
    return
}

$output = Join-Path (Get-Location).Path `
    "release-output/$Tag-$BuildNumber"

if (Test-Path $output) {
    throw "Release output already exists. Use a new build number."
}

New-Item -ItemType Directory -Path $output -Force |
    Out-Null

function Assert-ApkCertificate {
    param([string]$Path)

    $report = @(
        & $apksigner verify --verbose --print-certs $Path
    )

    if ($LASTEXITCODE -ne 0) {
        throw "APK signature verification failed."
    }

    $matches = [regex]::Matches(
        ($report -join "`n"),
        '(?im)^Signer #\d+ certificate SHA-256 digest:\s*([A-F0-9:]+)'
    )

    if ($matches.Count -ne 1) {
        throw "Expected exactly one APK signer."
    }

    $actual = Normalize-Fingerprint $matches[0].Groups[1].Value

    if ($actual -ne $expected) {
        throw "APK certificate mismatch. Release refused."
    }

    Write-Host "APK certificate verified."
}

function Assert-AabCertificate {
    param([string]$Path)

    Invoke-Checked -Command $jarsigner -Arguments @(
        "-verify",
        $Path
    )

    $report = @(
        & $keytool -J-Duser.language=en `
            -printcert -jarfile $Path
    )

    if ($LASTEXITCODE -ne 0) {
        throw "AAB certificate inspection failed."
    }

    $matches = [regex]::Matches(
        ($report -join "`n"),
        '(?im)^\s*SHA-?256:\s*([A-F0-9:]+)'
    )

    if ($matches.Count -ne 1) {
        throw "Expected exactly one AAB certificate."
    }

    $actual = Normalize-Fingerprint $matches[0].Groups[1].Value

    if ($actual -ne $expected) {
        throw "AAB certificate mismatch. Release refused."
    }

    $javaName = if ($env:OS -eq "Windows_NT") {
        "java.exe"
    } else {
        "java"
    }

    $java = Join-Path $javaBin $javaName

    Invoke-Checked -Command $java -Arguments @(
        (Join-Path $PSScriptRoot "VerifyAab.java"),
        $Path,
        $expected
    )

    Write-Host "AAB certificate verified."
}

foreach ($flavour in $flavours) {

    $symbols = Join-Path $output "symbols/$flavour"

    New-Item -ItemType Directory -Force -Path $symbols |
        Out-Null

    $package = if ($flavour -eq "staging") {
        "za.co.maja.ronditrack.staging"
    } else {
        "za.co.maja.ronditrack"
    }

    $release = "${package}@${version}+${BuildNumber}"

    $common = @(
        "--release",
        "--no-pub",
        "--flavor=$flavour",
        "--build-name=$version",
        "--build-number=$BuildNumber",
        "--obfuscate",
        "--split-debug-info=$symbols",
        "--dart-define=APP_FLAVOR=$flavour",
        "--dart-define-from-file=config/firebase.$flavour.json",
        "--dart-define=API_BASE_URL=$($apiAddresses[$flavour])",
        "--dart-define=SENTRY_RELEASE=$release",
        "--dart-define=SENTRY_DIST=$BuildNumber"
    )

    $dsn = if ($flavour -eq "staging") {
        $env:SENTRY_DSN_STAGING
    } else {
        $env:SENTRY_DSN_PROD
    }

    if ($dsn) {
        $common += "--dart-define=SENTRY_DSN=$dsn"
    }

    if ($flavour -eq "staging") {

        Invoke-Checked -Command "flutter" -Arguments (
            @("build", "apk") + $common
        )

        $artifact = "build/app/outputs/flutter-apk/app-staging-release.apk"

        if (-not (Test-Path $artifact)) {
            throw "Staging APK not found."
        }

        Assert-ApkCertificate $artifact

        $destination = Join-Path $output `
            "RondiTrack-staging-$version-$BuildNumber.apk"

    } else {

        Invoke-Checked -Command "flutter" -Arguments (
            @("build", "appbundle") + $common
        )

        $artifact = "build/app/outputs/bundle/prodRelease/app-prod-release.aab"

        if (-not (Test-Path $artifact)) {
            throw "Production AAB not found."
        }

        Assert-AabCertificate $artifact

        $destination = Join-Path $output `
            "RondiTrack-prod-$version-$BuildNumber.aab"
    }

    Copy-Item $artifact $destination

    $mapping = "build/app/outputs/mapping/${flavour}Release/mapping.txt"

    if (-not (Test-Path $mapping)) {
        throw "Required Android mapping file missing."
    }

    $dartSymbols = @(
        Get-ChildItem $symbols -Recurse -File -Filter "*.symbols"
    )

    if ($dartSymbols.Count -eq 0) {
        throw "Required Dart debugging symbols missing."
    }

    Copy-Item $mapping (Join-Path $symbols "mapping.txt")

    $hash = (Get-FileHash $destination -Algorithm SHA256).Hash

    @(
        "Version=$version",
        "BuildNumber=$BuildNumber",
        "Flavour=$flavour",
        "SentryRelease=$release",
        "SentryDist=$BuildNumber",
        "CertificateSHA256=$expected",
        "ArtifactSHA256=$hash"
    ) | Set-Content (Join-Path $output "$flavour-metadata.txt")

    Write-Host "$flavour release verified and exported."
}

Write-Host "Release output: $output"
Write-Host "RELEASE BUILD COMPLETE"
