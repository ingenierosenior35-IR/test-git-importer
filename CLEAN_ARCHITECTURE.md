# Clean Architecture Implementation

## Directory Structure

```
lib/
├── app/                          # Global application configuration
│   ├── app.dart                  # Main app widget
│   ├── bindings/                 # Dependency injection bindings
│   │   └── initial_bindings.dart
│   ├── routes/                   # Application routing
│   │   └── app_routes.dart
│   └── config/                   # App configuration
│       └── app_config.dart
│
├── core/                         # Shared core utilities
│   ├── constants/                # App-wide constants
│   ├── utils/                    # Utility functions
│   ├── extensions/               # Dart extensions
│   │   └── string_extensions.dart
│   ├── errors/                   # Error handling
│   │   ├── failures.dart         # Domain failures
│   │   └── exceptions.dart       # Data exceptions
│   └── network/                  # Network utilities
│       └── network_info.dart
│
├── features/                     # Feature modules (Clean Architecture)
│   ├── auth/                     # Authentication feature
│   │   ├── data/
│   │   │   ├── models/           # Data models (extend entities)
│   │   │   │   └── user_model.dart
│   │   │   ├── datasources/      # Data sources (Remote & Local)
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   └── repositories/     # Repository implementations
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/         # Business entities
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/     # Repository interfaces
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/         # Business logic use cases
│   │   │       ├── sign_in_with_google.dart
│   │   │       ├── sign_in_with_facebook.dart
│   │   │       ├── sign_in_with_email_password.dart
│   │   │       ├── sign_up_with_email_password.dart
│   │   │       ├── send_phone_verification_code.dart
│   │   │       ├── verify_otp.dart
│   │   │       └── sign_out.dart
│   │   ├── presentation/
│   │   │   ├── controllers/      # GetX controllers
│   │   │   │   └── auth_controller.dart
│   │   │   ├── screens/          # UI screens
│   │   │   │   ├── welcome_screen.dart
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── sign_in_screen.dart
│   │   │   │   ├── sign_up_screen.dart
│   │   │   │   ├── otp_verification_screen.dart
│   │   │   │   ├── reset_password_screen.dart
│   │   │   │   └── onboarding/
│   │   │   └── widgets/          # Feature-specific widgets
│   │   └── auth_binding.dart     # Dependency injection for auth
│   │
│   ├── home/                     # Home feature
│   │   ├── data/
│   │   │   └── models/
│   │   │       ├── home_model.dart
│   │   │       └── healthtips_item_model.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── home_controller.dart
│   │       ├── screens/
│   │       │   └── home_page.dart
│   │       └── widgets/
│   │           └── healthtips_item_widget.dart
│   │
│   ├── matches/                  # Matches feature
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── match.dart
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── controllers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── video/                    # Video feature
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── video.dart
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── analysis/                 # Player analysis feature
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── player_stats.dart
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── profile/                  # Profile feature
│   │   ├── data/
│   │   │   └── models/
│   │   │       ├── profile_model.dart
│   │   │       └── my_profile_model.dart
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── my_profile_controller.dart
│   │       ├── screens/
│   │       │   ├── profile_page.dart
│   │       │   ├── my_profile_screen.dart
│   │       │   └── edit_profile_screen.dart
│   │       └── widgets/
│   │
│   └── workout/                  # Workout feature
│       ├── data/
│       │   └── models/
│       │       ├── select_muscle_tabs_data.dart
│       │       └── choose_number_of_hour_model.dart
│       ├── domain/
│       └── presentation/
│           ├── controllers/
│           │   ├── select_muscle_controller.dart
│           │   └── choose_number_of_week_controller.dart
│           └── widgets/
│               ├── gym_execirse_tab.dart
│               ├── home_exercise_tab.dart
│               ├── stretches_exercise_tab.dart
│               └── number_of_hour_dialogue.dart
│
└── shared/                       # Shared across features
    ├── widgets/                  # Reusable UI components
    │   ├── app_bar/
    │   │   ├── custom_app_bar.dart
    │   │   ├── appbar_title.dart
    │   │   ├── appbar_subtitle.dart
    │   │   └── appbar_image*.dart
    │   ├── custom_button.dart
    │   ├── custom_text_form_field.dart
    │   ├── custom_bottom_bar.dart
    │   ├── social_login_button.dart
    │   ├── sport_card.dart
    │   └── ... (other shared widgets)
    └── animations/               # Shared animations
```

## Layer Responsibilities

### Domain Layer (Business Logic)
- **Entities**: Pure business objects with no dependencies
- **Repositories**: Interfaces defining data operations
- **Use Cases**: Single-responsibility business operations

### Data Layer (Data Management)
- **Models**: Data transfer objects that extend entities
- **Data Sources**: Remote (API) and Local (Cache/DB) data access
- **Repository Implementations**: Concrete implementations of domain repositories

### Presentation Layer (UI)
- **Controllers**: State management using GetX
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components specific to the feature

## Key Principles

### 1. Dependency Rule
- Dependencies point inward: Presentation → Domain ← Data
- Domain layer is independent and has no external dependencies
- Inner layers don't know about outer layers

### 2. Single Responsibility
- Each use case does one thing
- Each model/entity represents one concept
- Each screen serves one purpose

### 3. Dependency Inversion
- High-level modules don't depend on low-level modules
- Both depend on abstractions (interfaces)
- Example: `AuthController` depends on `AuthRepository` interface, not implementation

### 4. Error Handling
- **Domain Layer**: Returns `Failure` objects
- **Data Layer**: Throws `Exception` objects
- **Repository**: Converts exceptions to failures using Either<Failure, Success>

## Data Flow

### Example: Sign In with Google

```
1. User taps Google Sign In button
   ↓
2. UI calls: authController.signInWithGoogle()
   ↓
3. Controller calls: signInWithGoogleUseCase.call()
   ↓
4. Use case calls: authRepository.signInWithGoogle()
   ↓
5. Repository calls: authRemoteDataSource.signInWithGoogle()
   ↓
6. Data source calls Firebase Auth
   ↓
7. Success/Failure flows back through layers
   ↓
8. UI updates based on result
```

## Benefits

✅ **Testability**: Each layer can be tested independently
✅ **Maintainability**: Clear structure makes code easy to find and update
✅ **Scalability**: Add new features without affecting existing code
✅ **Flexibility**: Easy to swap implementations (e.g., change data source)
✅ **Team Collaboration**: Clear boundaries prevent merge conflicts
✅ **Code Reusability**: Shared components and business logic

## Testing Strategy

### Unit Tests
- **Use Cases**: Test business logic in isolation
- **Repositories**: Test data transformations and error handling
- **Controllers**: Test state management logic

### Integration Tests
- **Data Sources**: Test API/database interactions
- **Feature Flows**: Test complete user journeys

### Widget Tests
- **Screens**: Test UI rendering and interactions
- **Widgets**: Test reusable components

## Migration Benefits

| Before | After |
|--------|-------|
| Mixed patterns (screens/ + presentation/) | Single consistent structure |
| Services with multiple responsibilities | Single-responsibility use cases |
| Direct Firebase calls in controllers | Clean abstraction layers |
| Difficult to test | Easy to mock and test |
| Unclear data flow | Clear unidirectional flow |
| Features scattered across folders | Features self-contained |

## Next Steps

1. ✅ Complete structure setup
2. ✅ Migrate auth feature (reference implementation)
3. ✅ Migrate other features
4. 🔄 Update imports throughout codebase
5. ⏳ Add domain/presentation layers to remaining features
6. ⏳ Write tests for critical paths
7. ⏳ Remove old duplicate code
8. ⏳ Documentation and team training
