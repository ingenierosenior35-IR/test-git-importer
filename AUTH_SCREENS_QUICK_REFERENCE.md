# Authentication Screens - Quick Reference

## Screen Flow

```
App Start → Splash → Onboarding → Welcome Screen
                                        ↓
                    ┌───────────────────┴───────────────────┐
                    ↓                                       ↓
              Continue with Email                    Social Login
                    ↓                                       ↓
            Sign In Screen                      Google/Facebook/Apple
                    ↓                                       ↓
        ┌───────────┴──────────┐                          ↓
        ↓                      ↓                           ↓
   Forgot Password         Sign In              Onboarding or Home
        ↓                      ↓
Reset Password Screen    Onboarding or Home
        ↓
    Success
```

## Screen Components

### 1. Welcome Screen (`/welcome_screen`)

**Visual Structure:**
```
┌─────────────────────────┐
│                         │
│   [Placeholder Image]   │  ← 250px height, dark gray
│                         │
├─────────────────────────┤
│ Welcome to airfly ✈️    │  ← White text, 28px, bold
│                         │
│ If you already have...  │  ← Gray text, 14px
│                         │
├─────────────────────────┤
│ 📧 Continue with Email  │  ← LIME button (#CDFF4D)
├─────────────────────────┤
│   ─── Sign in with ───  │
├─────────────────────────┤
│ 🔍 Continue with Google │  ← Dark gray buttons
│ 📘 Continue with FB     │
│ 🍎 Continue with Apple  │
├─────────────────────────┤
│ Don't have an account?  │
│      Register           │  ← Register in lime color
└─────────────────────────┘
```

### 2. Sign In Screen (`/sign_in_screen`)

**Visual Structure:**
```
┌─────────────────────────┐
│ ← Back                  │  ← White back arrow
│                         │
│ Sign in your account    │  ← White text, 28px, bold
│                         │
├─────────────────────────┤
│ 📧 Your Email          │  ← Dark gray input (#1E1E1E)
├─────────────────────────┤
│ 🔒 Enter Password  👁   │  ← Show/hide toggle
├─────────────────────────┤
│ ☑ Remember me          │  ← Lime checkbox
│         Forgot Password │  ← Lime link (right-aligned)
├─────────────────────────┤
│      Sign In            │  ← LIME button
└─────────────────────────┘
```

### 3. Sign Up Screen (`/sign_up_screen`)

**Visual Structure:**
```
┌─────────────────────────┐
│ ← Back                  │  ← White back arrow
│                         │
│       Sign Up           │  ← White text, centered, 28px
│                         │
├─────────────────────────┤
│ 👤 Full Name           │  ← Dark gray inputs
├─────────────────────────┤
│ 📧 Your Email          │
├─────────────────────────┤
│ 🔒 Enter Password  👁   │  ← Show/hide toggles
├─────────────────────────┤
│ 🔒 Confirm Password 👁  │
├─────────────────────────┤
│ ☑ I agree with         │  ← Lime checkbox
│    Terms & Condition   │  ← Underlined
├─────────────────────────┤
│       Signup            │  ← LIME button
│                         │
│ have an account?        │
│      Sign In            │  ← Underlined
└─────────────────────────┘
```

### 4. Reset Password Screen (`/reset_password_screen`)

**Visual Structure:**
```
┌─────────────────────────┐
│ ← Back                  │  ← White back arrow
│                         │
│   Reset Password        │  ← White text, 28px, bold
│                         │
│ Code has been sent to   │  ← Gray text
│ arishairean@gmail.com   │  ← LIME text (#CDFF4D)
│                         │
├─────────────────────────┤
│   [1] [2] [3] [4] [5]  │  ← 5 separate input boxes
│                         │  ← Active has lime border
├─────────────────────────┤
│  Resend code in 55s     │  ← Gray text / lime when ready
├─────────────────────────┤
│       Verify            │  ← LIME button
└─────────────────────────┘
```

## Color Palette

| Usage | Hex Code | Flutter Code |
|-------|----------|--------------|
| Background | `#000000` | `Colors.black` |
| Primary Button | `#CDFF4D` | `Color(0xFFCDFF4D)` |
| Input Background | `#1E1E1E` | `Color(0xFF1E1E1E)` |
| Text Primary | `#FFFFFF` | `Colors.white` |
| Text Secondary | Gray | `Colors.grey` |
| Border Active | `#CDFF4D` | `Color(0xFFCDFF4D)` |
| Button Text | `#000000` | `Colors.black` |

## Key Features

### Input Fields
- 12px border radius
- Icon on left (person, email, lock)
- Password fields have show/hide toggle on right
- Dark gray background (#1E1E1E)
- Lime border when focused

### Buttons
- 12px border radius
- 16px vertical padding
- Full width
- Bold text (weight 600)
- Lime background for primary actions

### Checkboxes
- Lime color when checked
- Black checkmark
- Used for "Remember me" and "Terms"

### Validation
- Email format validation
- Password minimum 6 characters
- Password confirmation match
- Required field checks
- Real-time error messages

### Navigation
- Back button (top-left) on all sub-screens
- GetX for navigation management
- Proper state preservation
- Error handling with snackbars

## Implementation Status

✅ All 4 screens implemented
✅ Exact color matching
✅ Form validation
✅ Navigation flow
✅ Error handling
✅ AuthService integration
✅ Routes configuration
✅ Documentation complete

## Testing Checklist

- [ ] Welcome screen displays correctly
- [ ] All navigation buttons work
- [ ] Sign in validates email/password
- [ ] Sign up creates new account
- [ ] Password visibility toggles work
- [ ] Reset password accepts 5-digit code
- [ ] Auto-advance works in OTP fields
- [ ] Remember me checkbox functions
- [ ] Terms checkbox prevents signup if unchecked
- [ ] Error messages display correctly
- [ ] Success navigation works
- [ ] Social login buttons work
- [ ] Back buttons navigate correctly
- [ ] Forms validate properly
- [ ] Colors match specifications exactly

## File Locations

```
lib/screens/auth/
├── welcome_screen.dart          # Entry point
├── sign_in_screen.dart          # Email/password login
├── sign_up_screen.dart          # Registration
└── reset_password_screen.dart   # OTP verification

lib/services/
└── auth_service.dart            # Authentication logic

lib/routes/
└── app_routes.dart              # Route definitions
```

## Quick Commands

### Navigate to screens programmatically:
```dart
// Welcome Screen
Get.toNamed(AppRoutes.welcomeScreen);

// Sign In Screen
Get.to(() => SignInScreen());

// Sign Up Screen
Get.to(() => SignUpScreen());

// Reset Password Screen
Get.to(() => ResetPasswordScreen());
```

### Use AuthService methods:
```dart
final AuthService _authService = Get.put(AuthService());

// Sign Up
await _authService.signUpWithEmailPassword(email, password, name);

// Sign In
await _authService.signInWithEmailPassword(email, password);

// Password Reset
await _authService.sendPasswordResetEmail(email);
```

## Notes

- All screens use black background for consistency
- Lime color (#CDFF4D) is used for all primary actions
- Dark mode is default and only mode
- Phone authentication (existing) still works
- Email/password authentication is fully integrated
- Social logins preserved from original implementation
