# Screen Flow and UI Description

## Navigation Flow

```
Home Screen
├── Weather Widget (Top)
├── Performance Banner (Yellow)
├── Favorites Section
│   └── "Ver todo" → Fixtures Screen
└── Tools Section
    ├── Partidos → Create Match Screen
    ├── Entrenos → Coming Soon
    ├── Equipos → Coming Soon
    ├── Torneos → Coming Soon
    └── Pollas → Polls Screen
        ├── Create Poll Button → Create Poll Screen
        ├── Join Poll Button → Join Poll Screen
        └── Poll Card Tap → Poll Detail Screen
            ├── Tab 1: Standings Table
            ├── Tab 2: Match Predictions
            └── Tab 3: Participants List

Fixtures Screen
├── Tab 1: Upcoming Matches
└── Tab 2: Finished Matches
```

## Screen Descriptions

### 1. Home Screen (Already Implemented)
**Location**: `/lib/features/home/presentation/screens/home_page.dart`

**Layout from top to bottom**:

```
┌─────────────────────────────────────┐
│  🌤️  Next Match Info  🔍 🔔       │  ← Weather strip (dark)
├─────────────────────────────────────┤
│                                     │
│   📊 RENDIMIENTO                    │  
│   Último encuentro                  │  ← Yellow banner
│   Jugados 90 mins                   │     with avatar
│   108 PASES EN            [8.5] 👤 │
│                                     │
├─────────────────────────────────────┤
│  TUS FAVORITOS          Ver todo → │
│                                     │
│  ⚽    ⚽    ⚽    ⚽    ⚽           │  ← Horizontal scroll
│  Real  Barça  Atlé  Valen Sevi     │     of team bubbles
│  Ganó  Ganó   Emp   Perd  Ganó     │
│                                     │
├─────────────────────────────────────┤
│  HERRAMIENTAS                       │
│                                     │
│  ⚽    🏋️    👥    🏆    📊        │  ← Horizontal scroll
│  Parti Entr  Equi  Torn  Polla     │     of tool buttons
│  dos   enos  pos   eos   s         │
│                                     │
├─────────────────────────────────────┤
│  DÍAS DE JUEGO                      │
│  L  M  X  J  V  S  D               │  ← Week days chips
├─────────────────────────────────────┤
│  TUS PARTIDOS                       │
│  [Match cards...]                   │  ← Match list
└─────────────────────────────────────┘
```

**Color Scheme**:
- Background: Dark (#192126)
- Cards: Dark Card (#252D32)
- Accent: Neon Yellow (#CDFF4D)
- Text: White/Grey

### 2. Fixtures Screen (NEW)
**Location**: `/lib/features/fixtures/presentation/screens/fixtures_screen.dart`

**Layout**:
```
┌─────────────────────────────────────┐
│  ← RESULTADOS Y FIXTURES            │  ← AppBar
│  ┌─────────────┬─────────────┐     │
│  │  PRÓXIMOS   │  RESULTADOS │     │  ← Tabs
│  └─────────────┴─────────────┘     │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐ │
│  │ La Liga        18 Feb         │ │  ← Fixture card
│  │                               │ │
│  │    ⚽              ⚽          │ │
│  │  Barcelona   VS  Atlético     │ │  ← For upcoming
│  │               20:00           │ │
│  │                               │ │
│  │    📍 Camp Nou                │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ La Liga        16 Feb         │ │
│  │                               │ │
│  │    ⚽     2-1      ⚽          │ │  ← For finished
│  │  Real         Barcelona       │ │     with score
│  │  Madrid                       │ │
│  │                               │ │
│  │    📍 Santiago Bernabéu       │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Features**:
- Two tabs: Upcoming / Results
- Match cards show:
  - Competition badge (yellow)
  - Date
  - Teams with icons
  - Score (finished) or time (upcoming)
  - Venue

### 3. Polls Screen (NEW)
**Location**: `/lib/features/polls/presentation/screens/polls_screen.dart`

**Layout**:
```
┌─────────────────────────────────────┐
│  ← POLLAS FUTBOLERAS         👥+   │  ← AppBar with join button
│  ┌─────────────┬─────────────┐     │
│  │   ACTIVAS   │ FINALIZADAS │     │  ← Tabs
│  └─────────────┴─────────────┘     │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐ │
│  │ [ACTIVA]               →      │ │
│  │                               │ │  ← Poll card
│  │ La Liga 2024 - Amigos         │ │
│  │ Polla de predicciones para    │ │
│  │ la temporada de La Liga...    │ │
│  │                               │ │
│  │ 👤 Carlos García              │ │
│  │              👥 5 participantes│ │
│  │ 📅 Creada: 18 Jan 2024        │ │
│  └───────────────────────────────┘ │
│                                     │
│                          [+ Crear  │  ← FAB button
│                             Polla] │
└─────────────────────────────────────┘
```

**Features**:
- Two tabs: Active / Finished
- Poll cards show:
  - Status badge
  - Name and description
  - Creator
  - Participant count
  - Creation date
- FAB to create new poll
- Top button to join poll

### 4. Create Poll Screen (NEW)
**Location**: `/lib/features/polls/presentation/screens/create_poll_screen.dart`

**Layout**:
```
┌─────────────────────────────────────┐
│  ✕  CREAR POLLA                     │  ← AppBar
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │ ℹ️  Crea una polla para       │ │  ← Info card
│  │    predecir resultados...     │ │
│  └───────────────────────────────┘ │
│                                     │
│  Nombre de la Polla                 │
│  ┌───────────────────────────────┐ │
│  │ Ej: La Liga 2024 - Amigos     │ │  ← Text input
│  └───────────────────────────────┘ │
│                                     │
│  Descripción                        │
│  ┌───────────────────────────────┐ │
│  │ Describe de qué trata esta    │ │  ← Text area
│  │ polla...                      │ │
│  │                               │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │       CREAR POLLA             │ │  ← Submit button
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Features**:
- Form with validation
- Info card explaining polls
- Name and description fields
- Yellow submit button

### 5. Join Poll Screen (NEW)
**Location**: `/lib/features/polls/presentation/screens/join_poll_screen.dart`

**Layout**:
```
┌─────────────────────────────────────┐
│  ✕  UNIRSE A POLLA                  │  ← AppBar
├─────────────────────────────────────┤
│                                     │
│         ┌───────────┐               │
│         │           │               │
│         │   📱 QR   │               │  ← QR icon
│         │           │               │
│         └───────────┘               │
│                                     │
│    Ingresa el código de invitación  │
│    Pídele el código al creador...   │
│                                     │
│  ┌───────────────────────────────┐ │
│  │      X X X X X X              │ │  ← Code input
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │         UNIRSE                │ │  ← Join button
│  └───────────────────────────────┘ │
│                                     │
│  ───────────── O ────────────────  │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 📱 ESCANEAR CÓDIGO QR         │ │  ← QR scan button
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Features**:
- Large code input field
- QR scanner option (placeholder)
- Clean, centered design

### 6. Poll Detail Screen (NEW)
**Location**: `/lib/features/polls/presentation/screens/poll_detail_screen.dart`

**Layout**:
```
┌─────────────────────────────────────┐
│  ← LA LIGA 2024 - AMIGOS            │  ← AppBar with poll name
│  ┌─────┬─────────┬──────────────┐  │
│  │TABLA│ PARTIDOS│ PARTICIPANTES│  │  ← 3 Tabs
│  └─────┴─────────┴──────────────┘  │
├─────────────────────────────────────┤
│  TAB 1: STANDINGS TABLE             │
│  ┌───────────────────────────────┐ │
│  │ [1] Carlos García    145 pts  │ │  ← 1st place (yellow)
│  │     12/20 aciertos            │ │
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │ [2] María López      132 pts  │ │  ← 2nd place (silver)
│  │     11/20 aciertos            │ │
│  └───────────────────────────────┘ │
│                                     │
│  TAB 2: MATCH PREDICTIONS           │
│  ┌───────────────────────────────┐ │
│  │ Real Madrid vs Barcelona  [+15│ │
│  │         2  -  1               │ │  ← Prediction
│  │ 👤 Carlos García              │ │
│  └───────────────────────────────┘ │
│                                     │
│  TAB 3: PARTICIPANTS                │
│  ┌───────────────────────────────┐ │
│  │ 👤 Participante 1  [CREADOR]  │ │  ← Participant
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │ 👤 Participante 2             │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Features**:
- Tab 1: Standings with rankings and points
  - Top 3 highlighted with colors
  - Shows correct predictions
- Tab 2: Match predictions history
  - Shows predicted scores
  - Points earned
- Tab 3: Participants list
  - Creator badge
  - User avatars

## Color Legend

```
🟡 Yellow (#CDFF4D) - Primary accent, buttons, highlights
⚫ Dark (#192126) - Background
🔲 Dark Card (#252D32) - Card backgrounds
⬜ White (#FFFFFF) - Primary text
⚪ Grey (#888888) - Secondary text
🟢 Green (#34C759) - Won/Success
🟠 Orange (#EFA83C) - Drew/Warning
🔴 Red (#D65656) - Lost/Error
```

## Responsive Design Notes

All screens are designed with:
- Scrollable content areas
- Proper overflow handling
- Minimum touch target sizes (44x44)
- Flexible layouts
- Proper text truncation

## Accessibility Features

- High contrast colors (Yellow on Black)
- Clear visual hierarchy
- Icon + text labels
- Proper spacing
- Touch-friendly sizes

## Future Enhancements

When integrating with real APIs:
1. Add loading states (shimmer effects)
2. Add error states with retry
3. Add empty states with CTAs
4. Add pull-to-refresh
5. Add infinite scroll for large lists
6. Add real-time updates
7. Add animations and transitions
8. Add haptic feedback
