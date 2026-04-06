#!/usr/bin/env dart

import 'dart:io';

/// A simple script to read lcov.info file and display coverage statistics
void main(List<String> args) async {
  final lcovPath = args.isNotEmpty ? args[0] : 'coverage/lcov.info';
  
  try {
    await generateCoverageReport(lcovPath);
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<void> generateCoverageReport(String lcovPath) async {
  final file = File(lcovPath);
  
  if (!await file.exists()) {
    throw Exception('LCOV file not found: $lcovPath');
  }
  
  print('📊 Coverage Report');
  print('=' * 80);
  print('Reading: $lcovPath\n');
  
  final coverage = await parseLcovFile(file);
  
  if (coverage.isEmpty) {
    print('No coverage data found.');
    return;
  }
  
  displayCoverageReport(coverage);
}

Future<List<FileCoverage>> parseLcovFile(File file) async {
  final lines = await file.readAsLines();
  final List<FileCoverage> coverage = [];
  
  String? currentFile;
  int? linesFound;
  int? linesHit;
  
  for (final line in lines) {
    if (line.startsWith('SF:')) {
      // Source file
      currentFile = line.substring(3);
    } else if (line.startsWith('LF:')) {
      // Lines found
      linesFound = int.tryParse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      // Lines hit
      linesHit = int.tryParse(line.substring(3));
    } else if (line == 'end_of_record') {
      // End of record - save the file coverage
      if (currentFile != null && linesFound != null && linesHit != null) {
        coverage.add(FileCoverage(
          filePath: currentFile,
          linesFound: linesFound,
          linesHit: linesHit,
        ));
      }
      
      // Reset for next file
      currentFile = null;
      linesFound = null;
      linesHit = null;
    }
  }
  
  return coverage;
}

void displayCoverageReport(List<FileCoverage> coverage) {
  // Sort by coverage percentage (lowest first)
  coverage.sort((a, b) => a.coveragePercentage.compareTo(b.coveragePercentage));
  
  // Calculate totals
  final totalLinesFound = coverage.fold<int>(0, (sum, file) => sum + file.linesFound);
  final totalLinesHit = coverage.fold<int>(0, (sum, file) => sum + file.linesHit);
  final overallCoverage = totalLinesFound > 0 ? (totalLinesHit / totalLinesFound) * 100 : 0.0;
  
  // Display summary
  print('📈 SUMMARY');
  print('-' * 80);
  print('Total files: ${coverage.length}');
  print('Total lines: $totalLinesFound');
  print('Covered lines: $totalLinesHit');
  print('Overall coverage: ${overallCoverage.toStringAsFixed(2)}%');
  print('');
  
  // Display per-file coverage
  print('📁 FILE COVERAGE');
  print('-' * 80);
  
  // Header
  print('${_padRight('File', 60)} ${_padLeft('Lines', 8)} ${_padLeft('Hit', 8)} ${_padLeft('Coverage', 10)}');
  print('-' * 80);
  
  for (final file in coverage) {
    final fileName = _shortenPath(file.filePath);
    final coverageStr = '${file.coveragePercentage.toStringAsFixed(1)}%';
    final emoji = _getCoverageEmoji(file.coveragePercentage);
    
    print('${_padRight(fileName, 60)} ${_padLeft(file.linesFound.toString(), 8)} ${_padLeft(file.linesHit.toString(), 8)} ${_padLeft(coverageStr, 9)} $emoji');
  }
  
  print('-' * 80);
  
  // Display coverage distribution
  print('\n📊 COVERAGE DISTRIBUTION');
  print('-' * 40);
  
  final ranges = [
    (90.0, 100.0, '90-100%', '🟢'),
    (80.0, 89.9, '80-89%', '🟡'),
    (70.0, 79.9, '70-79%', '🟠'),
    (0.0, 69.9, '0-69%', '🔴'),
  ];
  
  for (final (min, max, label, emoji) in ranges) {
    final count = coverage.where((f) => f.coveragePercentage >= min && f.coveragePercentage <= max).length;
    print('$emoji $label: $count files');
  }
  
  // Show files with lowest coverage
  print('\n⚠️  FILES WITH LOWEST COVERAGE');
  print('-' * 40);
  
  final lowestCoverage = coverage.take(100);
  for (final file in lowestCoverage) {
    final fileName = _shortenPath(file.filePath);
    print('${file.coveragePercentage.toStringAsFixed(1)}% - $fileName');
  }
  
  print('');
}

String _shortenPath(String path) {
  // Remove lib/ prefix and show relative path
  if (path.startsWith('lib\\') || path.startsWith('lib/')) {
    return path.substring(4);
  }
  return path;
}

String _padRight(String text, int width) {
  return text.length >= width ? text.substring(0, width) : text.padRight(width);
}

String _padLeft(String text, int width) {
  return text.padLeft(width);
}

String _getCoverageEmoji(double percentage) {
  if (percentage >= 90) return '🟢';
  if (percentage >= 80) return '🟡';
  if (percentage >= 70) return '🟠';
  return '🔴';
}

class FileCoverage {
  final String filePath;
  final int linesFound;
  final int linesHit;
  
  FileCoverage({
    required this.filePath,
    required this.linesFound,
    required this.linesHit,
  });
  
  double get coveragePercentage {
    return linesFound > 0 ? (linesHit / linesFound) * 100 : 0.0;
  }
  
  @override
  String toString() {
    return 'FileCoverage(path: $filePath, found: $linesFound, hit: $linesHit, coverage: ${coveragePercentage.toStringAsFixed(2)}%)';
  }
}
