# Rival App - Visual Structure

## 🏗️ App Architecture

```
┌─────────────────────────────────────────┐
│          Rival Sports Analytics         │
│         (Dark + #CDFF4D Yellow)         │
└─────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │   Authentication      │
        │   Flow (Firebase)     │
        └───────────┬───────────┘
                    │
        ┌───────────┴───────────┐
        │    Main Container     │
        │   (Bottom Nav - 5)    │
        └───────────┬───────────┘
                    │
    ┌───────┬───────┼───────┬───────┐
    │       │       │       │       │
┌───▼───┐ ┌─▼────┐ ┌▼────┐ ┌▼──────┐ ┌─▼──────┐
│ HOME  │ │MATCH │ │VIDEO│ │ANALYS │ │PROFILE │
│       │ │  ES  │ │     │ │  IS   │ │        │
└───────┘ └──────┘ └─────┘ └───────┘ └────────┘
```

## 📱 Screen Breakdown

### 1. HOME SCREEN
```
┌──────────────────────────┐
│ "Hola, {userName}"       │
│ Welcome to Rival         │
├──────────────────────────┤
│  ┌──────────────────┐   │
│  │ Player Card      │   │
│  │ • Avatar         │   │
│  │ • Next Match     │   │
│  │ • Rating: 7.5    │   │
│  └──────────────────┘   │
├──────────────────────────┤
│  Scoreboards             │
│  [Configure Custom]      │
├──────────────────────────┤
│  Your Matches (Agenda)   │
│  • Match 1 - Tomorrow    │
│  • Match 2 - Next Week   │
│  • Match 3 - ...         │
├──────────────────────────┤
│  [Create Tournament] 🏆  │
└──────────────────────────┘
```

### 2. MATCHES SCREEN
```
┌──────────────────────────┐
│ Matches                  │
│ [All][Pending][Complete] │
├──────────────────────────┤
│  ┌──────────────────┐   │
│  │ ⚽ Match Name    │   │
│  │ 📍 Venue        │   │
│  │ 📅 Date/Time    │   │
│  │ 👥 Players      │   │
│  │ [Pending]       │   │
│  └──────────────────┘   │
│  ┌──────────────────┐   │
│  │ ⚽ Match 2...    │   │
│  └──────────────────┘   │
├──────────────────────────┤
│         [+ Create]       │
└──────────────────────────┘
```

### 3. VIDEO SCREEN
```
┌──────────────────────────┐
│ Video                    │
├──────────────────────────┤
│  ┌──────────────────┐   │
│  │ 📹 Upload Video │   │
│  │                  │   │
│  │ Select Match:    │   │
│  │ [Dropdown▼]      │   │
│  │                  │   │
│  │ [Select File]    │   │
│  │                  │   │
│  │ Progress: 75%    │   │
│  │ ████████░░       │   │
│  └──────────────────┘   │
├──────────────────────────┤
│  My Videos               │
│  • Video 1 [Ready]       │
│  • Video 2 [Processing]  │
│  • Video 3 [Uploading]   │
└──────────────────────────┘
```

### 4. ANALYSIS SCREEN
```
┌──────────────────────────┐
│ Análisis                 │
│ Review your performance  │
├──────────────────────────┤
│  Stats Overview          │
│  ┌────┬────┬────┐       │
│  │⚽12│⭐7.5│🎯3 │       │
│  │Mat │Imp │Ast │       │
│  └────┴────┴────┘       │
│  ┌────┬────┬────┐       │
│  │🏃45│✓82%│🛡5 │       │
│  │km  │Acc │Tac │       │
│  └────┴────┴────┘       │
├──────────────────────────┤
│  Match History           │
│  • Match 1 - 5 Jan 2024  │
│  • Match 2 - 10 Jan 2024 │
│  • Match 3 - ...         │
└──────────────────────────┘
```

### 5. PROFILE SCREEN
```
┌──────────────────────────┐
│       ┌────────┐         │
│       │ Avatar │         │
│       └────────┘         │
│     {User Name}          │
│   {user@email.com}       │
├──────────────────────────┤
│  ┌─────────┬─────────┐  │
│  │   7.5   │   42    │  │
│  │ Rating  │ Matches │  │
│  └─────────┴─────────┘  │
├──────────────────────────┤
│  Accumulated Stats       │
│  ┌────────┬────────┐    │
│  │🏃 125km│🎯 15   │    │
│  │Distance│Assists │    │
│  ├────────┼────────┤    │
│  │✓ 84%   │🛡 89   │    │
│  │Accurcy │Tackles │    │
│  └────────┴────────┘    │
├──────────────────────────┤
│  [✏️ Edit Profile]       │
│  [⚙️ Settings]           │
│  [🚪 Sign Out]           │
└──────────────────────────┘
```

## 🎨 Component Library

### Cards
```
┌──────────────────┐
│ Dark Card        │
│ Border-radius:16 │
│ #252D32         │
└──────────────────┘
```

### Buttons
```
┌──────────────────┐
│   Primary Btn    │  Yellow #CDFF4D
│   Background     │  on Black text
└──────────────────┘
```

### Bottom Navigation
```
┌──────────────────────────────────┐
│ [🏠]  [⚽]  [🎥]  [📊]  [👤]    │
│ Home Match Video Analy Profile │
└──────────────────────────────────┘
```

## 🗂️ File Structure

```
lib/
├── core/
│   └── constants/
│       ├── colors.dart      [#CDFF4D]
│       └── strings.dart     [Spanish]
├── data/
│   ├── models/
│   │   ├── match.dart
│   │   ├── player_stats.dart
│   │   └── video.dart
│   ├── repositories/
│   │   ├── match_repository.dart
│   │   ├── stats_repository.dart
│   │   └── video_repository.dart
│   └── services/
│       └── ai_service.dart
└── presentation/
    ├── controllers/
    │   ├── home_controller.dart
    │   ├── matches_controller.dart
    │   ├── video_controller.dart
    │   ├── analysis_controller.dart
    │   └── profile_controller.dart
    └── screens/
        ├── main_container_screen.dart
        ├── home/
        │   ├── home_screen.dart
        │   └── widgets/
        ├── matches/
        │   ├── matches_list_screen.dart
        │   └── create_match_screen.dart
        ├── video/
        │   └── video_upload_screen.dart
        ├── analysis/
        │   └── match_history_screen.dart
        └── profile/
            ├── profile_screen.dart
            └── edit_profile_screen.dart
```

## 🔄 Data Flow

```
User Action
    ↓
Controller (GetX)
    ↓
Repository
    ↓
Firebase/API
    ↓
Model
    ↓
Observable State
    ↓
UI Update (Obx)
```

## 🎯 Key Features Map

```
HOME
├─ User Profile
├─ Next Match
├─ Scoreboards
└─ Match Agenda

MATCHES
├─ List (Filter)
├─ Create Match
└─ Match Cards

VIDEO
├─ Upload
├─ Progress
└─ Status List

ANALYSIS
├─ History
├─ Stats Grid
└─ AI Insights*

PROFILE
├─ Avatar/Rating
├─ Stats Summary
├─ Edit Profile
└─ Settings
```

## 🚀 Ready to Use

✅ All screens functional
✅ Navigation working
✅ State management active
✅ Firebase integrated
✅ Dark theme applied
✅ Spanish language
✅ Error handling
✅ Loading states

**Status**: Production Ready! 🎉
