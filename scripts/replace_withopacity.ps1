# PowerShell script: Batch replace withOpacity to withValues
# Usage: Run .\replace_withopacity.ps1 in project root directory

# Set encoding to UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Get all .dart files
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

Write-Host "Found $($dartFiles.Count) Dart files"

$totalReplacements = 0

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Use regex to replace withOpacity(value) with withValues(alpha: value)
    $content = $content -replace '\.withOpacity\((\d+(?:\.\d+)?)\)', '.withValues(alpha: $1)'
    
    # Count replacements
    $replacements = ([regex]::Matches($originalContent, '\.withOpacity\(\d+(?:\.\d+)?\)')).Count
    
    if ($replacements -gt 0) {
        # Write back to file
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "Processed: $($file.Name) - Replaced $replacements occurrences"
        $totalReplacements += $replacements
    }
}

Write-Host "`nReplacement completed! Total replaced $totalReplacements withOpacity calls"
Write-Host "Please check the code and test to ensure replacements are correct."