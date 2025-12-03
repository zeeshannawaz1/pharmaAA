# Script to help download missing Gradle Kotlin JAR files
# Due to SSL issues, you'll need to download these manually via browser

$downloadsPath = "$env:USERPROFILE\Downloads"
$gradleCache = "$env:USERPROFILE\.gradle\caches\modules-2\files-2.1\org.jetbrains.kotlin"

Write-Host "=== MISSING FILES NEEDED ===" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. kotlin-gradle-plugin-1.9.24-gradle82.jar"
Write-Host "   URL: https://plugins.gradle.org/m2/org/jetbrains/kotlin/kotlin-gradle-plugin/1.9.24/kotlin-gradle-plugin-1.9.24-gradle82.jar"
Write-Host ""
Write-Host "2. kotlin-compiler-embeddable-1.9.24.jar"
Write-Host "   URL: https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-compiler-embeddable/1.9.24/kotlin-compiler-embeddable-1.9.24.jar"
Write-Host ""
Write-Host "=== DOWNLOAD INSTRUCTIONS ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open your web browser"
Write-Host "2. Copy and paste the URLs above one by one"
Write-Host "3. Download the files to: $downloadsPath"
Write-Host "4. Run this script again after downloading to move files to cache"
Write-Host ""

# Check if files exist in Downloads
$file1 = "$downloadsPath\kotlin-gradle-plugin-1.9.24-gradle82.jar"
$file2 = "$downloadsPath\kotlin-compiler-embeddable-1.9.24.jar"

if (Test-Path $file1) {
    Write-Host "[OK] Found: kotlin-gradle-plugin-1.9.24-gradle82.jar" -ForegroundColor Green
    $destDir1 = "$gradleCache\kotlin-gradle-plugin\1.9.24"
    $hash1 = (Get-FileHash $file1 -Algorithm SHA1).Hash.ToLower()
    $destSubDir1 = "$destDir1\$hash1"
    New-Item -ItemType Directory -Path $destSubDir1 -Force | Out-Null
    Copy-Item -Path $file1 -Destination "$destSubDir1\kotlin-gradle-plugin-1.9.24-gradle82.jar" -Force
    Write-Host "   Moved to: $destSubDir1\" -ForegroundColor Green
} else {
    Write-Host "[ ] Missing: kotlin-gradle-plugin-1.9.24-gradle82.jar" -ForegroundColor Red
}

if (Test-Path $file2) {
    Write-Host "[OK] Found: kotlin-compiler-embeddable-1.9.24.jar" -ForegroundColor Green
    $destDir2 = "$gradleCache\kotlin-compiler-embeddable\1.9.24"
    $hash2 = (Get-FileHash $file2 -Algorithm SHA1).Hash.ToLower()
    $destSubDir2 = "$destDir2\$hash2"
    New-Item -ItemType Directory -Path $destSubDir2 -Force | Out-Null
    Copy-Item -Path $file2 -Destination "$destSubDir2\kotlin-compiler-embeddable-1.9.24.jar" -Force
    Write-Host "   Moved to: $destSubDir2\" -ForegroundColor Green
} else {
    Write-Host "[ ] Missing: kotlin-compiler-embeddable-1.9.24.jar" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== ALL JAR FILES IN DOWNLOADS ===" -ForegroundColor Cyan
Get-ChildItem -Path $downloadsPath -Filter "*.jar" | ForEach-Object {
    $sizeKB = [math]::Round($_.Length / 1KB, 2)
    Write-Host "  - $($_.Name) ($sizeKB KB)"
}

