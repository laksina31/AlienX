# ==============================================================================
#  ALIENX launcher
#  Download Alienx_Setting.exe from GitHub -> verify -> run -> cleanup
# ==============================================================================

$ExeUrl = "https://raw.githubusercontent.com/laksina31/AlienX/main/Alienx_Setting.exe"

# ใส่ SHA-256 ถ้าต้องการล็อกไฟล์
$ExpectedSha256 = ""

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {}

function Write-Step($text, $color = "Cyan") {
    Write-Host "  $text" -ForegroundColor $color
}

Write-Host ""
Write-Host "  ALIENX  -  CMD BY EMPEROR STORE" -ForegroundColor Cyan
Write-Host "  --------------------------------" -ForegroundColor DarkGray
Write-Host ""

$exe = Join-Path $env:TEMP (
    "Alienx_" + [Guid]::NewGuid().ToString("N") + ".exe"
)

try {

    # ==========================================================
    # 1. DOWNLOAD
    # ==========================================================

    Write-Step "[1/4] Downloading..."

    Write-Step "      $ExeUrl" "DarkGray"

    Invoke-WebRequest `
        -Uri $ExeUrl `
        -OutFile $exe `
        -UseBasicParsing `
        -Headers @{
            "User-Agent" = "Mozilla/5.0"
        }

    if (!(Test-Path $exe)) {
        throw "Download failed: file was not created."
    }

    $file = Get-Item $exe

    if ($file.Length -lt 10KB) {
        throw "Downloaded file is too small. GitHub may not be returning the EXE."
    }

    Write-Step "      Size: $([math]::Round($file.Length / 1MB, 2)) MB" "DarkGray"


    # ==========================================================
    # 2. CHECK PE HEADER
    # ==========================================================

    Write-Step "[2/4] Checking EXE..."

    $bytes = [System.IO.File]::ReadAllBytes($exe)

    if ($bytes.Length -lt 2) {
        throw "Downloaded file is invalid."
    }

    # Windows PE files start with MZ
    if ($bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
        throw "Downloaded file is NOT a valid Windows EXE. Check the GitHub file URL."
    }

    Write-Step "      Windows PE detected." "Green"


    # ==========================================================
    # 3. SHA-256
    # ==========================================================

    Write-Step "[3/4] Checking SHA-256..."

    $hash = (Get-FileHash -Path $exe -Algorithm SHA256).Hash.ToUpper()

    Write-Step "      SHA-256: $hash" "DarkGray"

    if ($ExpectedSha256 -and
        ($hash -ne $ExpectedSha256.Trim().ToUpper())) {

        throw "SHA-256 mismatch. File was NOT executed."
    }

    Write-Step "      File check passed." "Green"


    # ==========================================================
    # 4. RUN
    # ==========================================================

    Write-Step "[4/4] Starting ALIENX..." "Cyan"
    Write-Step "      Administrator permission may appear." "DarkGray"

    Start-Process `
        -FilePath $exe `
        -Verb RunAs `
        -Wait

    Write-Host ""
    Write-Step "ALIENX closed." "Green"
}
catch {

    Write-Host ""
    Write-Host "  [!] ERROR" -ForegroundColor Red
    Write-Host "      $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}
finally {

    # Cleanup downloaded EXE
    if (Test-Path $exe) {
        Remove-Item $exe -Force -ErrorAction SilentlyContinue
    }
}
