# Onboarding Flow Visual Guide

## Screen-by-Screen Breakdown

---

## 📱 Screen 1: Identity Screen (Login)
**File:** `lib/screens/onboarding/identity_screen.dart`

```
┌─────────────────────────────┐
│                             │
│         R I V A L           │  ← Logo (Yellow/Lime)
│                             │
│    Crea tu identidad        │  ← Title
│                             │
│  ┌───────────────────────┐  │
│  │ Teléfono o correo     │  │  ← Single input field
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │      Comenzar         │  │  ← Yellow button
│  └───────────────────────┘  │
│                             │
│  ──── O continuar con ────  │  ← Divider
│                             │
│  ┌───────────────────────┐  │
│  │  Continue with Google │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │ Continue with Facebook│  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │  Continue with Apple  │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Key Features:**
- Full screen (NO modal)
- Black solid background
- Single field detects phone or email
- Yellow/lime (#CDFF4D) accents

---

## 📱 Screen 2: Sport Selection
**File:** `lib/screens/onboarding/sport_selection_screen.dart`

```
┌─────────────────────────────┐
│  ¿Cuál es tu juego?         │  ← Title
│  Elige tu cancha.           │  ← Subtitle
│                             │
│  ┌──────────┐  ┌──────────┐ │
│  │  🏃      │  │  🏀      │ │
│  │ Running  │  │Basketball│ │  ← 2-column grid
│  │    ✓     │  └──────────┘ │     of square cards
│  └──────────┘               │
│  ┌──────────┐  ┌──────────┐ │
│  │  ⚽      │  │  🏊      │ │
│  │ Football │  │ Swimming │ │
│  └──────────┘  └──────────┘ │
│  ┌──────────┐  ┌──────────┐ │
│  │  🚴      │  │  🎾      │ │
│  │ Cycling  │  │  Tennis  │ │
│  └──────────┘  └──────────┘ │
│                             │
│  ┌───────────────────────┐  │
│  │      Continue         │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Key Features:**
- Large square cards (aspect ratio 1:1)
- 2 columns per row
- Checkmark (✓) top-right when selected
- Yellow border when selected
- Up to 5 sports selectable

---

## 📱 Screen 3: Gender Selection
**File:** `lib/screens/onboarding/gender_selection_screen.dart`

```
┌─────────────────────────────┐
│   ¿Cómo compites?           │  ← Title
│                             │
│         👤                  │  ← Avatar icon
│                             │
│  ┌────┐   ┌────┐   ┌────┐  │
│  │ ♂️ │   │ ♀️ │   │ 👤 │  │  ← 3 buttons in
│  │Male│   │Fem.│   │Pref│  │     ONE row
│  └────┘   └────┘   └────┘  │
│                             │
│  Esto ayuda a calibrar      │  ← Helper text
│  tu avatar.                 │
│                             │
│  ┌───────────────────────┐  │
│  │      Continue         │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Key Features:**
- 3 buttons horizontally in ONE row
- Equal width (Expanded widgets)
- Icons above text
- Yellow background when selected

---

## 📱 Screen 4: Height Screen
**File:** `lib/screens/onboarding/height_screen.dart`

```
┌─────────────────────────────┐
│  ¿Cuál es tu altura?        │  ← Title
│  Estos números ayudan a     │  ← Subtitle
│  calibrar tu avatar.        │
│                             │
│          📏                 │  ← Ruler icon
│                             │
│       165 cm                │
│       170 cm  ← Selected    │  ← Scroll picker
│       175 cm                │     (large numbers)
│                             │
│   ┌────────┐  ┌────────┐   │
│   │ Metros │  │  Pies  │   │  ← Unit toggle
│   └────────┘  └────────┘   │
│                             │
│  ┌───────────────────────┐  │
│  │      Continue         │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Key Features:**
- Only height measurement
- Scroll picker (100-250 cm)
- Toggle: Metros ↔ Pies
- Rounded toggle buttons

---

## 📱 Screen 5: Weight Screen
**File:** `lib/screens/onboarding/weight_screen.dart`

```
┌─────────────────────────────┐
│  ¿Cuál es tu peso?          │  ← Title
│  Cada jugador tiene         │  ← Subtitle
│  sus números.               │
│                             │
│          ⚖️                 │  ← Scale icon
│                             │
│        65 kg                │
│        70 kg  ← Selected    │  ← Scroll picker
│        75 kg                │     (large numbers)
│                             │
│     ┌────┐    ┌────┐       │
│     │ Kg │    │ Lb │       │  ← Unit toggle
│     └────┘    └────┘       │     (circular)
│                             │
│  ┌───────────────────────┐  │
│  │      Continue         │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Key Features:**
- Only weight measurement
- Scroll picker (30-200 kg / 66-440 lbs)
- Toggle: Kg ↔ Lb
- Circular toggle buttons (60x60)

---

## 📱 Screen 6: Photo Upload
**File:** `lib/screens/onboarding/photo_upload_screen.dart`
*(Unchanged - preserved existing design)*

```
┌─────────────────────────────┐
│    Hazlo más real           │  ← Title
│  Si subes una foto, tu      │  ← Subtitle
│  avatar se parecerá más a ti│
│                             │
│      ┌───────────┐          │
│      │           │          │  ← Photo
│      │     📷    │          │     preview area
│      │  Add Photo│          │     (200x200)
│      └───────────┘          │
│                             │
│  Tu avatar, tu estilo.      │  ← Helper text
│                             │
│  ┌───────────────────────┐  │
│  │    Subir foto         │  │  ← Upload button
│  └───────────────────────┘  │
│         Omitir              │  ← Skip option
└─────────────────────────────┘
```

---

## 📱 Screen 7: Congratulations
**File:** `lib/screens/onboarding/congratulations_screen.dart`
*(Unchanged - preserved existing design)*

```
┌─────────────────────────────┐
│                             │
│         ┌─────┐             │
│         │  ✓  │             │  ← Animated
│         └─────┘             │     checkmark
│                             │
│    Congratulations!         │  ← Title
│                             │
│  Account successfully       │  ← Message
│  created. You'll be taken   │
│  to the home page shortly.  │
│                             │
│  ┌───────────────────────┐  │
│  │   Back to Home        │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

---

## 🔄 Complete Navigation Flow

```
Identity Screen (Login)
         ↓
   (User logs in)
         ↓
Sport Selection Screen
         ↓
 (Select 1-5 sports)
         ↓
Gender Selection Screen
         ↓
   (Select gender)
         ↓
   Height Screen ← NEW
         ↓
  (Enter height)
         ↓
   Weight Screen ← NEW
         ↓
  (Enter weight)
         ↓
Photo Upload Screen
         ↓
(Upload photo or skip)
         ↓
Congratulations Screen
         ↓
   (Auto-redirect)
         ↓
    Home Screen
```

---

## 🎨 Design System

### Colors
- **Background:** `#000000` (Black)
- **Primary Accent:** `#CDFF4D` (Yellow/Lime)
- **Card Background:** `#1E1E1E` or `#2C2C2C`
- **Border (unselected):** `#3C3C3C`
- **Border (selected):** `#CDFF4D`
- **Text Primary:** `#FFFFFF` (White)
- **Text Secondary:** Grey variants

### Typography
- **Titles:** 28px, bold, white
- **Subtitles:** 16px, grey
- **Button Text:** 16px, bold
- **Helper Text:** 14px, grey

### Spacing
- **Screen Padding:** 24px
- **Card Spacing:** 16px
- **Button Height:** 54-56px
- **Border Radius:** 12-16px

### Icons
- **Large Icons:** 48-64px
- **Small Icons:** 24-28px
- **Checkmark:** 16px

---

## 📊 Data Flow

```
Identity Screen
    ↓
[User Authentication Data]
    ↓
Sport Selection
    ↓
[selectedSports: List<String>]
    ↓
Gender Selection
    ↓
[selectedGender: String]
    ↓
Height Screen
    ↓
[height: {value: double, unit: String}]
    ↓
Weight Screen
    ↓
[weight: {value: double, unit: String}]
    ↓
Photo Upload
    ↓
[photoUrls: List<String>]
    ↓
Save to Firebase
    ↓
Congratulations
```

---

## ✅ Implementation Checklist

- [x] Identity Screen - Full screen design
- [x] Sport Selection - 2-column card grid
- [x] Gender Selection - 3 buttons horizontal
- [x] Height Screen - Separate screen created
- [x] Weight Screen - Separate screen created
- [x] Navigation Flow - Updated correctly
- [x] App Routes - New routes added
- [x] Sport Card Widget - New widget created
- [x] Design Consistency - All screens match
- [x] Back Navigation - Preserved on all screens
- [x] Firebase Integration - Preserved

---

## 🚀 Ready for Testing

All requirements have been implemented. The onboarding flow is ready for:
- Manual testing on device/simulator
- UI/UX review
- Firebase integration testing
- Different screen size testing

**Status: COMPLETE ✅**
