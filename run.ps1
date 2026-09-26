$url="https://github.com/laksina31/AlienX/raw/refs/heads/main/ALIENX-Installer.exe"
$out="$env:TEMP\ALIENX-Installer.exe"

Invoke-WebRequest -Uri $url -OutFile $out
Start-Process $out -Verb RunAs