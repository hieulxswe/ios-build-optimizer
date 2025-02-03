# iOS Build Optimizer

A command-line tool for iOS project build optimization and analysis, providing real-time feedback and comprehensive reports through terminal interaction.

## Features

- Real-time terminal feedback
- Interactive configuration
- Automated project analysis
- Performance optimization
- Code quality checks
- Dependency analysis
- Build time optimization
- Comprehensive reporting


## System Requirements

- macOS 10.15 or later
- Xcode 12.0 or later
- Bash 3.2 or later
- Git

## Project Structure
```
ios-build-optimizer/
├── algorithms/           # Build optimization algorithms
│   ├── build_optimizer.sh
│   ├── build_task_manager.sh
│   ├── cache_manager.sh
│   ├── coverage_analyzer.sh
│   ├── dependency_analyzer.sh
│   ├── dependency_optimizer.sh
│   ├── memory_analyzer.sh
│   ├── parallel_processor.sh
│   ├── performance_analyzer.sh
│   ├── performance_optimizer.sh
│   └── smart_cache.sh
├── cache/               # Cache storage
│   ├── build_cache.dat
│   └── cache_stats.json
├── configs/             # Configuration files
│   ├── build_phases.sh
│   ├── environment.sh
│   ├── project_config.sh
│   ├── project_settings.sh
│   └── xcode_config.sh
├── logs/                # Log files
│   └── log_rotation.sh
├── results/             # Analysis results
├── src/                 # Source files
│   └── main.sh
├── utils/              # Utility scripts
│   ├── build_analytics.sh
│   ├── calculations.sh
│   ├── code_analyzer.sh
│   ├── config_loader.sh
│   ├── environment.sh
│   ├── logger.sh
│   ├── project_analyzer.sh
│   ├── project_report.sh
│   └── results_manager.sh
└── reports/            # Generated reports
```


## Installation

1. Clone the repository:
```bash
git clone https://github.com/hieulxswe/ios-build-optimizer.git
cd ios-build-optimizer
```


## Interactive Terminal Usage

1. **Set Execution Permissions**
```bash
chmod +x install.sh
chmod +x src/*.sh
chmod +x algorithms/*.sh
chmod +x utils/*.sh
```

2. **Run Installation Script**
```bash
./install.sh
```

3. **Installation Process**
You'll see the following interactive prompts:
```bash
🚀 Starting iOS Build Optimizer installation...
📂 Please enter the path to your Xcode project:
```

Enter your project path, for example:
```bash
/Users/username/Desktop/MyProject
```

4. **Installation Confirmation**
```bash
✅ Valid Xcode project found: MyProject
📁 Creating directory structure...
📝 Creating configuration files...
📝 Creating utility files...
📝 Creating algorithm files...
✅ Installation completed!
📝 Configuration is ready
🚀 To start the build optimizer, run: ./src/main.sh
```

5. **Configuration Summary**
```bash
Configuration Summary:
Project Path: /Users/username/Desktop/MyProject
Project Name: MyProject
Build Configuration: Release
```

6. **Start Analysis**
```bash
Would you like to start project analysis now? (y/n)
```

7. **Analysis Process**
When you enter 'y', you'll see real-time analysis feedback:
```bash
[INFO] 2025-02-03 17:52:06 - Starting iOS Build Optimizer...
[INFO] 2025-02-03 17:52:06 - Analyzing project at: /Users/username/Desktop/MyProject
```

8. **Analysis Warnings**
The tool will show warnings for potential issues:
```bash
[WARNING] 2025-02-03 17:52:06 - Large file detected: /Users/username/Desktop/MyProject/LargeFile.swift (586 lines)
```

9. **Completion**
```bash
[SUCCESS] 2025-02-03 17:52:06 - Analysis completed. Check results at: /path/to/results/build_report.md
```


## Generated Reports

The tool creates detailed reports in:
```
results/YYYYMMDD_HHMMSS/build_report.md
```

Reports include:
- Project overview
- Code quality metrics
- Performance analysis
- Optimization recommendations

## Troubleshooting

If you encounter permission issues:
```bash
chmod +x install.sh
chmod +x src/*.sh
chmod +x algorithms/*.sh
chmod +x utils/*.sh
```

For project path issues:
- Verify the path exists
- Ensure it contains a .xcodeproj file
- Check read/write permissions

## License

This project is licensed under the MIT License.

## Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create feature branch
3. Submit pull request

## Acknowledgments

- iOS development community
- Open source contributors
- Performance optimization experts