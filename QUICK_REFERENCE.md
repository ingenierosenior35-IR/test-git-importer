# Quick Reference: Onboarding Flow Changes

## 🚀 What Changed?

### Before (Old Flow - 6 screens)
```
Identity → Sports → Gender → Measurements (Height+Weight together) → Photo → Congratulations
```

### After (New Flow - 7 screens)
```
Identity → Sports → Gender → Height → Weight → Photo → Congratulations
```

---

## 📝 Summary of Changes

| Screen | Change | File |
|--------|--------|------|
| **1. Identity** | Modal → Full Screen | `identity_screen.dart` |
| **2. Sports** | Chips → Square Cards (2-col grid) | `sport_selection_screen.dart`, `sport_card.dart` |
| **3. Gender** | 2+1 buttons → 3 horizontal buttons | `gender_selection_screen.dart` |
| **4. Height** | NEW - Separate screen | `height_screen.dart` ✨ |
| **5. Weight** | NEW - Separate screen | `weight_screen.dart` ✨ |

---

## 🔧 Key Implementation Details

### Identity Screen
- **Background:** Black solid (no gradient, no modal)
- **Layout:** Full screen with SafeArea
- **Button:** Yellow/lime "Comenzar" (56px height)
- **Divider:** "O continuar con"

### Sport Selection
- **Widget:** New `SportCard` component
- **Grid:** 2 columns, 1:1 aspect ratio
- **Icons:** 48px, yellow/lime when selected
- **Selection:** Checkmark (top-right), yellow border

### Gender Selection
- **Layout:** Single `Row` with 3 `Expanded` buttons
- **Icons:** 48px circles
- **Text:** 12px, 2-line max
- **Selection:** Yellow background + border

### Height Screen
- **Picker:** 100-250 cm
- **Toggle:** Metros / Pies (rounded buttons)
- **Icon:** Ruler/straighten
- **Navigation:** → Weight Screen

### Weight Screen
- **Picker:** 30-200 kg / 66-440 lbs
- **Toggle:** Kg / Lb (circular, 60x60)
- **Icon:** Scale/monitor_weight
- **Navigation:** → Photo Upload

---

## 🎨 Design Tokens

```dart
// Colors
const primaryAccent = Color(0xFFCDFF4D);  // Yellow/Lime
const background = Colors.black;
const cardBackground = Color(0xFF1E1E1E);
const cardBackgroundAlt = Color(0xFF2C2C2C);
const borderDefault = Color(0xFF3C3C3C);
const borderSelected = Color(0xFFCDFF4D);

// Spacing
const screenPadding = 24.0;
const cardSpacing = 16.0;
const buttonHeight = 54.0;

// Typography
const titleSize = 28.0;
const subtitleSize = 16.0;
const buttonTextSize = 16.0;
const helperTextSize = 14.0;
```

---

## 📦 New Dependencies

None! Uses existing packages:
- `flutter/material.dart`
- `get/get.dart` (navigation)
- Custom widgets: `CustomButton`, `ScrollPicker`

---

## 🧪 Testing Checklist

### Quick Test Path
1. ✅ Identity: Enter email → tap "Comenzar"
2. ✅ Sports: Select 3 sports → tap "Continue"
3. ✅ Gender: Select gender → tap "Continue"
4. ✅ Height: Set height → toggle units → tap "Continue"
5. ✅ Weight: Set weight → toggle units → tap "Continue"
6. ✅ Photo: Upload or skip → tap "Continue"
7. ✅ Congratulations: Auto-redirect to home

### Validation Points
- [ ] Identity screen is full screen (no modal)
- [ ] Sports show in 2-column grid with cards
- [ ] Gender shows 3 buttons in ONE row
- [ ] Height and Weight are separate screens
- [ ] Back button works on all screens
- [ ] Data persists through navigation
- [ ] Firebase save works at the end

---

## 🔄 Navigation Updates

### Old Flow
```dart
GenderSelectionScreen → MeasurementsScreen
```

### New Flow
```dart
GenderSelectionScreen → HeightScreen → WeightScreen
```

### Route Changes in `app_routes.dart`
```dart
// Added routes
static const String heightScreen = '/height_screen';
static const String weightScreen = '/weight_screen';

// Route factory updated
case AppRoutes.heightScreen:
  return getPage(HeightScreen(...), settings);
case AppRoutes.weightScreen:
  return getPage(WeightScreen(...), settings);
```

---

## 📂 File Structure

```
lib/
├── screens/
│   └── onboarding/
│       ├── identity_screen.dart       (Modified)
│       ├── sport_selection_screen.dart (Modified)
│       ├── gender_selection_screen.dart (Modified)
│       ├── height_screen.dart         (NEW ✨)
│       ├── weight_screen.dart         (NEW ✨)
│       ├── photo_upload_screen.dart   (Unchanged)
│       └── congratulations_screen.dart (Unchanged)
├── widgets/
│   ├── sport_card.dart                (NEW ✨)
│   ├── custom_button.dart             (Unchanged)
│   └── scroll_picker.dart             (Unchanged)
└── routes/
    └── app_routes.dart                (Modified)
```

---

## 💡 Tips for Developers

### Common Tasks

**To test full flow:**
```dart
// Start from Identity Screen
Navigator.pushNamed(context, AppRoutes.identityScreen);
```

**To modify card colors:**
```dart
// Edit lib/widgets/sport_card.dart
color: isSelected ? Color(0xFFCDFF4D) : Color(0xFF2C2C2C)
```

**To add more sports:**
```dart
// Edit lib/screens/onboarding/sport_selection_screen.dart
final List<Map<String, dynamic>> _sports = [
  {'name': 'New Sport', 'icon': Icons.sports},
  // ...
];
```

**To change height/weight ranges:**
```dart
// Height: lib/screens/onboarding/height_screen.dart
List<int> get _heightOptions => List.generate(151, (index) => 100 + index);

// Weight: lib/screens/onboarding/weight_screen.dart
List<int> get _weightOptions => List.generate(171, (index) => 30 + index);
```

---

## 🐛 Troubleshooting

**Issue:** Sports cards not showing correctly
- **Check:** `sport_card.dart` is imported
- **Check:** GridView aspect ratio is 1.0

**Issue:** Gender buttons stacked vertically
- **Check:** All 3 buttons wrapped in single `Row`
- **Check:** Each button has `Expanded` widget

**Issue:** Height/Weight screens not appearing
- **Check:** Routes added to `app_routes.dart`
- **Check:** Navigation updated in `gender_selection_screen.dart`

**Issue:** Back button not working
- **Check:** AppBar with back button on all screens
- **Check:** `Get.back()` on back button press

---

## 📚 Documentation Files

1. **ONBOARDING_FLOW_CHANGES.md** - Detailed implementation guide
2. **VISUAL_FLOW_GUIDE.md** - ASCII diagrams and visual flow
3. **QUICK_REFERENCE.md** - This file (quick reference)

---

## ✅ Final Checklist

- [x] All 4 design changes implemented
- [x] New screens created (height, weight)
- [x] New widget created (sport_card)
- [x] Routes updated
- [x] Navigation flow corrected
- [x] Documentation complete
- [x] Code committed and pushed

**Status: Ready for Testing! 🎉**

---

## 🤝 Need Help?

- Review detailed docs: `ONBOARDING_FLOW_CHANGES.md`
- See visual flow: `VISUAL_FLOW_GUIDE.md`
- Check code comments in each screen file
- Test on device/simulator for best results

**Last Updated:** 2026-01-27
