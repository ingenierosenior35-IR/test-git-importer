# Import Path Migration Guide

## Overview
This document maps old import paths to new Clean Architecture paths.

## Auth Feature
| Old Path | New Path |
|----------|----------|
| `lib/services/auth_service.dart` | `lib/features/auth/presentation/controllers/auth_controller.dart` |
| `lib/screens/auth/welcome_screen.dart` | `lib/features/auth/presentation/screens/welcome_screen.dart` |
| `lib/screens/auth/login_screen.dart` | `lib/features/auth/presentation/screens/login_screen.dart` |
| `lib/screens/auth/sign_in_screen.dart` | `lib/features/auth/presentation/screens/sign_in_screen.dart` |
| `lib/screens/auth/sign_up_screen.dart` | `lib/features/auth/presentation/screens/sign_up_screen.dart` |
| `lib/screens/auth/otp_verification_screen.dart` | `lib/features/auth/presentation/screens/otp_verification_screen.dart` |
| `lib/screens/auth/reset_password_screen.dart` | `lib/features/auth/presentation/screens/reset_password_screen.dart` |
| `lib/screens/onboarding/*` | `lib/features/auth/presentation/screens/onboarding/*` |

## Home Feature
| Old Path | New Path |
|----------|----------|
| `lib/presentation/home_page/home_page.dart` | `lib/features/home/presentation/screens/home_page.dart` |
| `lib/presentation/home_page/controller/home_controller.dart` | `lib/features/home/presentation/controllers/home_controller.dart` |
| `lib/presentation/home_page/models/*` | `lib/features/home/data/models/*` |
| `lib/presentation/home_page/widgets/*` | `lib/features/home/presentation/widgets/*` |

## Matches Feature
| Old Path | New Path |
|----------|----------|
| `lib/data/models/match.dart` | `lib/features/matches/data/models/match.dart` |

## Video Feature
| Old Path | New Path |
|----------|----------|
| `lib/data/models/video.dart` | `lib/features/video/data/models/video.dart` |

## Analysis Feature
| Old Path | New Path |
|----------|----------|
| `lib/data/models/player_stats.dart` | `lib/features/analysis/data/models/player_stats.dart` |

## Profile Feature
| Old Path | New Path |
|----------|----------|
| `lib/presentation/my_profile_screen/*` | `lib/features/profile/presentation/screens/*` |
| `lib/presentation/profile_page/*` | `lib/features/profile/presentation/screens/*` |
| `lib/presentation/edit_profile_screen/*` | `lib/features/profile/presentation/screens/*` |

## Workout Feature
| Old Path | New Path |
|----------|----------|
| `lib/chhose_number_of_week/*` | `lib/features/workout/presentation/widgets/*` |
| `lib/select_muscle_tabs/*` | `lib/features/workout/presentation/widgets/*` |

## Shared Components
| Old Path | New Path |
|----------|----------|
| `lib/widgets/*` | `lib/shared/widgets/*` |

## App Configuration
| Old Path | New Path |
|----------|----------|
| `lib/routes/app_routes.dart` | `lib/app/routes/app_routes.dart` |
| `lib/core/utils/initial_bindings.dart` | `lib/app/bindings/initial_bindings.dart` |

## Quick Search & Replace Patterns

### For VS Code / Find in Files:
```
Find: from 'package:Rival/services/auth_service.dart'
Replace: from 'package:Rival/features/auth/presentation/controllers/auth_controller.dart'

Find: from 'package:Rival/screens/auth/
Replace: from 'package:Rival/features/auth/presentation/screens/

Find: from 'package:Rival/presentation/home_page/
Replace: from 'package:Rival/features/home/presentation/

Find: from 'package:Rival/data/models/match.dart'
Replace: from 'package:Rival/features/matches/data/models/match.dart'

Find: from 'package:Rival/data/models/video.dart'
Replace: from 'package:Rival/features/video/data/models/video.dart'

Find: from 'package:Rival/data/models/player_stats.dart'
Replace: from 'package:Rival/features/analysis/data/models/player_stats.dart'

Find: from 'package:Rival/widgets/
Replace: from 'package:Rival/shared/widgets/

Find: from 'package:Rival/routes/app_routes.dart'
Replace: from 'package:Rival/app/routes/app_routes.dart'
```

## Controller Access Changes

### Old Way (AuthService):
```dart
final authService = Get.find<AuthService>();
await authService.signInWithGoogle();
```

### New Way (AuthController with Use Cases):
```dart
final authController = Get.find<AuthController>();
await authController.signInWithGoogle();
```

### New Binding Setup:
```dart
// In your route or screen
Get.put(AuthBinding());
```

## Next Steps

1. Use find & replace to update imports throughout the codebase
2. Test each screen/feature after updating imports
3. Remove old files after confirming new structure works
4. Run build to catch any remaining import errors

## Benefits of New Structure

✅ **Separation of Concerns**: Clear boundaries between layers
✅ **Testability**: Easy to mock and test individual components
✅ **Scalability**: Add new features without affecting existing ones
✅ **Maintainability**: Find and update code faster
✅ **Clean Architecture**: Follows industry best practices
