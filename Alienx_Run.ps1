# ==============================================================================
#  ALIENX launcher - downloads Alienx_Setting.exe from GitHub, runs it, cleans up
#
#  Customer command (Windows PowerShell):
#    irm https://raw.githubusercontent.com/USER/REPO/main/Alienx_Run.ps1 | iex
# ==============================================================================

# ---------------------------- CONFIG (edit these) -----------------------------
# GitHub Releases link: always points to the file named Alienx_Setting.exe in your LATEST release
$ExeUrl = "https://github.com/laksina31/AlienX/blob/main/Alienx_Setting.exe"

# Optional safety lock: paste the SHA-256 of your exe (Get-FileHash .\Alienx_Setting.exe)
# and the launcher will refuse to run any other file. Leave "" to skip the check.
$ExpectedSha256 = ""
# ------------------------------------------------------------------------------

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"   # downloads are much faster in Windows PowerShell 5.1
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

function Write-Step($text, $color) {
    if (-not $color) { $color = "Cyan" }
    Write-Host "  $text" -ForegroundColor $color
}

Write-Host ""
Write-Host "  ALIENX  -  CMD BY EMPEROR STORE" -ForegroundColor Cyan
Write-Host "  -------------------------------" -ForegroundColor DarkGray
Write-Host ""

$exe = Join-Path $env:TEMP ("Alienx_" + [Guid]::NewGuid().ToString("N") + ".exe")

try {
    if ($ExeUrl -match "USER/REPO") {
        throw "Edit `$ExeUrl at the top of this script first (replace USER/REPO with your GitHub name and repository)."
    }

    Write-Step "[1/3] Downloading..."
    Write-Step "      $ExeUrl" "DarkGray"
    Invoke-WebRequest -Uri $ExeUrl -OutFile $exe -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0" }
    if (-not (Test-Path $exe)) { throw "The download did not create a file." }
    if ((Get-Item $exe).Length -lt 10KB) { throw "The downloaded file is too small - check the link." }

    Write-Step "[2/3] Checking the file..."
    $hash = (Get-FileHash -Path $exe -Algorithm SHA256).Hash
    Write-Step "      SHA-256 $hash" "DarkGray"
    if ($ExpectedSha256 -and ($hash -ne $ExpectedSha256.Trim().ToUpper())) {
        throw "SHA-256 does not match, so the file was NOT run."
    }

    Write-Step "[3/3] Starting ALIENX (allow the administrator prompt)..."
    Start-Process -FilePath $exe -Verb RunAs -Wait
    Write-Step "Closed. Bye!" "DarkGray"
}
catch {
    Write-Host ""
    Write-Host "  [!] $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Message -match "404|Not Found") {
        Write-Host "      The link is wrong, or the repository / release is not public." -ForegroundColor DarkGray
    }
    if ($_.Exception.Message -match "canceled|cancelled") {
        Write-Host "      ALIENX needs administrator rights. Run the command again and click Yes." -ForegroundColor DarkGray
    }
}
finally {
    Remove-Item -Path $exe -Force -ErrorAction SilentlyContinue
}
