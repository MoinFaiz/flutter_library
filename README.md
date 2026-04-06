# Flutter Library App

A Flutter library app following clean architecture patterns with modular design. This app allows users to browse books, manage favorites, and search through a comprehensive library.

## 🚀 Features

- **Home Page** - Grid view of books with search functionality
- **Favorites Management** - Add/remove books from favorites
- **Advanced Search** - Debounced search with caching
- **Theme Support** - Dark/light mode switching
- **Distributed Loading** - Efficient data loading strategies
- **Modular Components** - Reusable UI components
- **Enhanced Loading Indicators** - Smooth animated loading states
- **Micro-interactions** - Button press/hover feedback with animations
- **Professional Error/Empty States** - Improved user guidance
- **Animation System** - Centralized animation constants and curves

## 📁 Architecture

This project follows **Clean Architecture** principles:

- **Presentation Layer** - UI components, pages, widgets, and state management
- **Domain Layer** - Business logic, entities, and use cases
- **Data Layer** - Data sources, repositories, and models

## 📚 Documentation

Comprehensive documentation is available in the [`docs/`](docs/) directory:

- **[Documentation Index](docs/README.md)** - Complete documentation overview
- **[Architecture Guide](docs/architecture/README.md)** - Architecture patterns and design
- **[Component Reference](docs/components/book_components.md)** - Reusable UI components
- **[Features Guide](docs/features/README.md)** - Feature implementations
- **[Development Guide](docs/development/README.md)** - Development guidelines
- **[Animation & Micro-interactions](docs/ANIMATION_QUICK_REFERENCE.md)** - Animation constants and usage
- **[Design System](docs/DESIGN_SYSTEM.md)** - Complete design system reference

### Implementation Phases

- **Phase 1** ✅ - Fixed all 18 hardcoded values (Rating: 8.5 → 9.0)
- **Phase 2** ✅ - Enhanced components with 49 new utilities (Rating: 9.0 → 9.1)
- **Phase 3** ✅ - UI/UX enhancements with animations (Rating: 9.1 → 9.4)
- **Phase 4** 🔄 - Final documentation and polish

See [Phase 3 Completion Summary](docs/PHASE_3_COMPLETION_SUMMARY.md) for details.

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## 🎯 Key Dependencies

- **State Management** - BLoC pattern for state management
- **HTTP Client** - For API calls and data fetching
- **Local Storage** - For favorites and theme preferences
- **Image Caching** - For optimized image loading
- **Pull-to-Refresh** - For enhanced user experience

## 📖 Usage

For detailed usage instructions and examples, see the [Development Guide](docs/development/README.md).

## 🤝 Contributing

1. Read the [Development Guide](docs/development/README.md)
2. Follow the [Code Standards](docs/development/code_refactoring.md)
3. Check the [Component Usage Examples](docs/development/component_usage_examples.md)

## 📄 License

This project is licensed under the MIT License.

---

*For more information, visit the [Documentation](docs/README.md).*
