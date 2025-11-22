# Contributing to Maawa

First off, thank you for considering contributing to Maawa! It's people like you that make Maawa such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Describe the exact steps which reproduce the problem** in as many details as possible.
* **Provide specific examples to demonstrate the steps**.
* **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
* **Explain which behavior you expected to see instead and why.**
* **Include screenshots and animated GIFs** which show you following the described steps and clearly demonstrate the problem.
* **If the problem is related to performance or memory**, include a CPU profile capture with your report.
* **Include your environment details** (Flutter version, Dart version, OS, device).

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title** for the issue to identify the suggestion.
* **Provide a step-by-step description of the suggested enhancement** in as many details as possible.
* **Provide specific examples to demonstrate the steps**.
* **Describe the current behavior** and **explain which behavior you expected to see instead** and why.
* **Explain why this enhancement would be useful** to most Maawa users.

### Pull Requests

* Fill in the required template
* Do not include issue numbers in the PR title
* Include screenshots and animated GIFs in your pull request whenever possible
* Follow the Flutter and Dart style guides
* Document new code based on the Documentation Styleguide
* End all files with a newline

## Development Setup

### Frontend (Flutter)

1. **Fork and clone the repo**
   ```bash
   git clone https://github.com/your-username/maawa_project.git
   cd maawa_project
   ```

2. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Code Style

We follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and [Flutter Best Practices](https://flutter.dev/docs/development/best-practices).

**Key points:**
- Use `flutter analyze` before committing
- Run `flutter format .` to format code
- Follow Clean Architecture principles
- Write meaningful commit messages
- Add comments for complex logic
- Write unit tests for business logic

### Project Structure Guidelines

```
lib/
├── core/                  # Core utilities (don't add business logic here)
├── data/                  # Data layer (DTOs, API clients, repo implementations)
├── domain/                # Domain layer (entities, repository interfaces, use cases)
├── presentation/          # UI layer (screens, widgets, controllers)
└── l10n/                  # Localization files
```

**Rules:**
- **Domain layer** should be independent (no imports from data or presentation)
- **Data layer** can import from domain
- **Presentation layer** can import from domain (use cases)
- Use dependency injection (Riverpod providers)
- Keep widgets small and composable

### Naming Conventions

**Files:**
- Use `snake_case` for file names: `property_detail_screen.dart`
- DTOs end with `_dto.dart`: `property_dto.dart`
- Use cases end with use case description: `fetch_properties.dart`

**Classes:**
- Use `PascalCase`: `PropertyDetailScreen`, `PropertyDto`
- Screen classes end with `Screen`: `PropertyDetailScreen`
- Controller/Notifier classes end with `Controller` or `Notifier`: `AuthController`
- Use cases are nouns: `FetchProperties`, `CreateBooking`

**Variables:**
- Use `camelCase`: `propertyId`, `checkInDate`
- Private variables start with `_`: `_isLoading`
- Constants use `SCREAMING_SNAKE_CASE`: `API_BASE_URL`

**Functions:**
- Use `camelCase`: `fetchProperties()`, `createBooking()`
- Boolean functions/variables start with `is`, `has`, `should`: `isLoading`, `hasError`

### Testing

We aim for high test coverage. When adding new features:

1. **Unit Tests** for business logic (use cases)
   ```bash
   flutter test test/domain/usecases/
   ```

2. **Widget Tests** for UI components
   ```bash
   flutter test test/presentation/widgets/
   ```

3. **Integration Tests** for user flows
   ```bash
   flutter test integration_test/
   ```

**Example Unit Test:**
```dart
void main() {
  group('FetchPropertiesUseCase', () {
    late MockPropertyRepository mockRepository;
    late FetchPropertiesUseCase useCase;

    setUp(() {
      mockRepository = MockPropertyRepository();
      useCase = FetchPropertiesUseCase(mockRepository);
    });

    test('should return list of properties from repository', () async {
      // Arrange
      final properties = [Property(/* ... */)];
      when(mockRepository.getProperties(any))
          .thenAnswer((_) async => properties);

      // Act
      final result = await useCase(PropertyFilters());

      // Assert
      expect(result, equals(properties));
      verify(mockRepository.getProperties(any));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
```

### Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (formatting, etc.)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Changes to build process or auxiliary tools

**Examples:**
```
feat(booking): add guest count selection to booking form

- Add number picker for guests
- Validate guest count based on property capacity
- Update booking API to include guests parameter

Closes #123
```

```
fix(auth): prevent duplicate login requests

Add loading state to prevent multiple simultaneous login attempts
that could cause race conditions.

Fixes #456
```

### Localization

When adding new UI text:

1. Add keys to `lib/l10n/app_en.arb`
   ```json
   {
     "propertyDetails": "Property Details",
     "@propertyDetails": {
       "description": "Title for property detail screen"
     }
   }
   ```

2. Add translations to `lib/l10n/app_ar.arb`
   ```json
   {
     "propertyDetails": "تفاصيل العقار"
   }
   ```

3. Use in code:
   ```dart
   final l10n = AppLocalizations.of(context);
   Text(l10n.propertyDetails)
   ```

### Backend Contributions (Laravel)

If contributing to the backend:

1. Follow [Laravel Best Practices](https://laravel.com/docs/contributions)
2. Use PHP 8.2+ features
3. Write feature tests for new endpoints
4. Update API documentation in `backend/postman/README.md`
5. Run `php artisan test` before committing

## Review Process

1. **All submissions** require review
2. We use GitHub pull requests for this process
3. Consult [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information

### Review Checklist

- [ ] Code follows the style guide
- [ ] All tests pass (`flutter test`)
- [ ] No linter warnings (`flutter analyze`)
- [ ] Code is properly formatted (`flutter format .`)
- [ ] Commit messages follow the convention
- [ ] Documentation is updated
- [ ] Localization strings are added (if applicable)
- [ ] No breaking changes (or documented if necessary)

## Questions?

Feel free to create an issue with the `question` label or reach out to the maintainers directly.

## Recognition

Contributors will be recognized in our README and release notes. Thank you for making Maawa better!

---

Happy coding! 🚀

