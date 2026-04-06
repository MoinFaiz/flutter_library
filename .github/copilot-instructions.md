# Copilot Instructions for Flutter Library App

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Project Overview
This is a Flutter library app following clean architecture patterns with modular design.

## Architecture Guidelines
- Follow clean architecture with clear separation of concerns
- Use the following layer structure:
  - **Presentation Layer**: UI components, pages, widgets, and state management
  - **Domain Layer**: Business logic, entities, and use cases
  - **Data Layer**: Data sources, repositories, and models

## Code Standards
- Use proper naming conventions (camelCase for variables, PascalCase for classes)
- Keep widgets modular and reusable
- Implement proper error handling with user-friendly messages
- Use pull-to-refresh functionality on all list pages
- Follow Flutter best practices for state management
- Implement dark/light theme support
- Use proper folder structure matching clean architecture

## Key Features
- Home page with book grid and search functionality
- Favorites management
- Bottom navigation (Home, Add, Library)
- Theme switching (dark/light mode)
- Responsive and attractive UI/UX

## Dependencies
- State management solution (bloc/provider)
- HTTP client for API calls
- Local storage for favorites and theme preferences
- Image caching and loading
- Pull-to-refresh functionality
