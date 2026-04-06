# PowerShell script to read lcov.info file and display coverage statistics
param(
    [string]$LcovPath = "coverage\lcov.info"
)

function Get-CoverageStatus {
    param([double]$Percentage)
    
    if ($Percentage -ge 90) { return "EXCELLENT" }
    elseif ($Percentage -ge 80) { return "GOOD" }
    elseif ($Percentage -ge 70) { return "FAIR" }
    else { return "POOR" }
}

function Format-Path {
    param([string]$Path)
    
    # Remove lib\ prefix and normalize path separators
    if ($Path.StartsWith("lib\") -or $Path.StartsWith("lib/")) {
        return $Path.Substring(4).Replace("\", "/")
    }
    return $Path.Replace("\", "/")
}

function Show-CoverageReport {
    param([string]$LcovPath)
    
    if (-not (Test-Path $LcovPath)) {
        Write-Error "LCOV file not found: $LcovPath"
        return
    }
    
    Write-Host "COVERAGE REPORT" -ForegroundColor Cyan
    Write-Host ("=" * 80) -ForegroundColor Gray
    Write-Host "Reading: $LcovPath`n" -ForegroundColor Yellow
    
    # Parse LCOV file
    $content = Get-Content $LcovPath
    $files = @()
    
    $currentFile = $null
    $linesFound = 0
    $linesHit = 0
    
    foreach ($line in $content) {
        if ($line.StartsWith("SF:")) {
            $currentFile = $line.Substring(3)
        }
        elseif ($line.StartsWith("LF:")) {
            $linesFound = [int]$line.Substring(3)
        }
        elseif ($line.StartsWith("LH:")) {
            $linesHit = [int]$line.Substring(3)
        }
        elseif ($line -eq "end_of_record") {
            if ($currentFile -and $linesFound -gt 0) {
                $coverage = ($linesHit / $linesFound) * 100
                $files += [PSCustomObject]@{
                    FilePath = $currentFile
                    LinesFound = $linesFound
                    LinesHit = $linesHit
                    Coverage = $coverage
                }
            }
            $currentFile = $null
            $linesFound = 0
            $linesHit = 0
        }
    }
    
    if ($files.Count -eq 0) {
        Write-Host "No coverage data found." -ForegroundColor Red
        return
    }
    
    # Sort by coverage percentage (lowest first)
    $files = $files | Sort-Object Coverage
    
    # Calculate totals
    $totalLinesFound = ($files | Measure-Object -Property LinesFound -Sum).Sum
    $totalLinesHit = ($files | Measure-Object -Property LinesHit -Sum).Sum
    $overallCoverage = if ($totalLinesFound -gt 0) { ($totalLinesHit / $totalLinesFound) * 100 } else { 0 }
    
    # Display summary
    Write-Host "SUMMARY" -ForegroundColor Green
    Write-Host ("-" * 80) -ForegroundColor Gray
    Write-Host "Total files: $($files.Count)"
    Write-Host "Total lines: $totalLinesFound"
    Write-Host "Covered lines: $totalLinesHit"
    Write-Host "Overall coverage: $($overallCoverage.ToString('F2'))%"
    Write-Host ""
    
    # Display per-file coverage
    Write-Host "FILE COVERAGE" -ForegroundColor Blue
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    # Header
    $header = "{0,-50} {1,8} {2,8} {3,10} {4,10}" -f "File", "Lines", "Hit", "Coverage", "Status"
    Write-Host $header -ForegroundColor White
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    foreach ($file in $files) {
        $fileName = Format-Path $file.FilePath
        if ($fileName.Length -gt 50) {
            $fileName = $fileName.Substring(0, 47) + "..."
        }
        
        $coverageStr = $file.Coverage.ToString("F1") + "%"
        $status = Get-CoverageStatus $file.Coverage
        
        $line = "{0,-50} {1,8} {2,8} {3,9} {4,10}" -f $fileName, $file.LinesFound, $file.LinesHit, $coverageStr, $status
        
        # Color code based on coverage
        if ($file.Coverage -ge 90) {
            Write-Host $line -ForegroundColor Green
        }
        elseif ($file.Coverage -ge 80) {
            Write-Host $line -ForegroundColor Yellow
        }
        elseif ($file.Coverage -ge 70) {
            Write-Host $line -ForegroundColor DarkYellow
        }
        else {
            Write-Host $line -ForegroundColor Red
        }
    }
    
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    # Display coverage distribution
    Write-Host "`nCOVERAGE DISTRIBUTION" -ForegroundColor Magenta
    Write-Host ("-" * 40) -ForegroundColor Gray
    
    $excellent = ($files | Where-Object { $_.Coverage -ge 90 }).Count
    $good = ($files | Where-Object { $_.Coverage -ge 80 -and $_.Coverage -lt 90 }).Count
    $fair = ($files | Where-Object { $_.Coverage -ge 70 -and $_.Coverage -lt 80 }).Count
    $poor = ($files | Where-Object { $_.Coverage -lt 70 }).Count
    
    Write-Host "EXCELLENT (90-100%): $excellent files" -ForegroundColor Green
    Write-Host "GOOD (80-89%): $good files" -ForegroundColor Yellow
    Write-Host "FAIR (70-79%): $fair files" -ForegroundColor DarkYellow
    Write-Host "POOR (0-69%): $poor files" -ForegroundColor Red
    
    # Show files with lowest coverage
    Write-Host "`nFILES WITH LOWEST COVERAGE" -ForegroundColor Red
    Write-Host ("-" * 40) -ForegroundColor Gray
    
    $lowestCoverage = $files | Select-Object -First 5
    foreach ($file in $lowestCoverage) {
        $fileName = Format-Path $file.FilePath
        $line = "$($file.Coverage.ToString('F1'))% - $fileName"
        Write-Host $line -ForegroundColor Red
    }
    
    Write-Host ""
}

# Main execution
try {
    Show-CoverageReport -LcovPath $LcovPath
}
catch {
    Write-Error "Error: $($_.Exception.Message)"
    exit 1
}
