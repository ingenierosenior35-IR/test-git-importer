# Testing Guide for Match and Weather Features - February 2026

## Overview
This document provides step-by-step testing instructions for all implemented features and fixes.

---

## Prerequisites

1. Flutter environment set up
2. Device/emulator running
3. App installed and ready to launch
4. Internet connection (for weather API)

---

## Test Suite

### Test 1: Global Color Scheme

**Objective**: Verify pure black background throughout the app

**Steps**:
1. Launch the app
2. Navigate to Home screen
3. Navigate to Matches screen
4. Navigate to Profile screen
5. Open Match Detail screen
6. Open Weather Detail screen

**Expected Results**:
- ✅ All screen backgrounds are pure black (#000000)
- ✅ Cards use subtle dark backgrounds (#1A1A1A)
- ✅ No gray backgrounds visible
- ✅ Accent color #DDEE5E visible in highlights

**Pass Criteria**: All screens consistently use black background

---

### Test 2: Match Creation - Step 2 Validation

**Objective**: Verify "Siguiente" button enables when typing match name

**Steps**:
1. Launch app
2. Navigate to Matches tab
3. Tap "Crear Partido" or similar button to start match creation
4. Observe Step 0 (Match Type) - "Siguiente" should be enabled
5. Tap "Siguiente" to go to Step 1
6. Select match type (Local or Versus)
7. If Versus: Select home and away teams
8. Tap "Siguiente" to go to Step 2 (Match Name)
9. **CRITICAL TEST**: Observe "Siguiente" button - should be DISABLED initially
10. Type "Partido de Amigos" in the text field
11. **CRITICAL TEST**: Observe "Siguiente" button - should become ENABLED immediately

**Expected Results**:
- ✅ Step 2 initially shows disabled "Siguiente" button
- ✅ As soon as text is entered, button enables
- ✅ No need to tap elsewhere or trigger validation manually
- ✅ Button updates in real-time as text changes

**Pass Criteria**: Button state updates instantly when text is entered

**Bug Reproduced If**: 
- ❌ Button stays disabled after typing
- ❌ Need to tap elsewhere to trigger validation
- ❌ Error message appears despite valid input

---

### Test 3: Match Creation - Navigation Buttons Design

**Objective**: Verify minimalist button styling

**Steps**:
1. Continue from Test 2 or start new match creation flow
2. Navigate to any step after Step 0
3. Observe "Anterior" and "Siguiente" buttons

**Expected Results - "Anterior" Button**:
- ✅ Text-only style (no heavy background)
- ✅ Yellow accent color (#DDEE5E)
- ✅ Clean, minimal appearance
- ✅ NOT a large yellow block
- ✅ Subtle, lightweight design

**Expected Results - "Siguiente" Button**:
- ✅ Filled yellow background (#DDEE5E)
- ✅ Black text
- ✅ No heavy shadow (flat design)
- ✅ Rounded corners (subtle)
- ✅ Compact padding

**Expected Results - Footer**:
- ✅ Black background
- ✅ Very subtle shadow at top
- ✅ Clean, minimal spacing
- ✅ Both buttons aligned nicely

**Pass Criteria**: Navigation footer has clean, minimalist Apple-style design

---

### Test 4: Home Screen - "Tus favoritos" Overflow

**Objective**: Verify no overflow errors in favorites section

**Steps**:
1. Launch app to Home screen
2. Scroll to "Tus favoritos" section
3. Observe favorite clubs cards
4. Scroll horizontally through favorites
5. **Enable large font**: 
   - iOS: Settings > Accessibility > Display & Text Size > Larger Text
   - Android: Settings > Display > Font size > Largest
6. Return to app and check "Tus favoritos" again

**Expected Results**:
- ✅ No "BOTTOM OVERFLOWED BY X pixels" error message
- ✅ All club names visible and properly truncated if too long
- ✅ Status badges ("Ganó", "Empató", "Perdió") visible
- ✅ Horizontal scrolling smooth
- ✅ Cards properly sized and aligned
- ✅ Works with large font settings

**Pass Criteria**: No overflow errors under any font size setting

**Bug Reproduced If**:
- ❌ Red/yellow overflow warning appears
- ❌ Text overlaps or gets cut off incorrectly
- ❌ Cards have strange sizing

---

### Test 5: Home Screen - Quick Access Cards

**Objective**: Verify minimalist styling and weather navigation

**Steps**:
1. On Home screen, locate "Acceso Rápido" section
2. Observe three cards: Pollas, Fixtures, Clima
3. **CRITICAL TEST**: Tap "Clima" card
4. Verify navigation to Weather Detail Screen

**Expected Results - Card Design**:
- ✅ Compact size (not too large)
- ✅ Subtle borders (low opacity)
- ✅ Small icons (24px, not 28px)
- ✅ Clean, minimalist appearance
- ✅ Consistent spacing

**Expected Results - Weather Navigation**:
- ✅ Tapping "Clima" opens Weather Detail Screen
- ✅ Does NOT open old simple weather screen
- ✅ Transition is smooth

**Pass Criteria**: Cards are minimalist and Clima navigates to detail screen

---

### Test 6: Weather Detail Screen - API Integration

**Objective**: Verify weather data loads from SAB API

**Steps**:
1. Tap "Clima" from Home screen quick access
2. Observe loading indicator
3. Wait for data to load (or error to appear)
4. If data loads successfully:
   - Observe station cards
   - Check rain levels and colors
   - Verify legend
5. Pull down to refresh
6. Tap refresh icon in app bar

**Expected Results - Loading**:
- ✅ Shows circular progress indicator
- ✅ Yellow accent color
- ✅ Centered on screen

**Expected Results - Success**:
- ✅ List of weather stations appears
- ✅ Each station shows:
  - Station name (e.g., "Estación Centro")
  - Location with pin icon
  - Accumulated rainfall in mm
  - Color-coded level badge
  - Last reading timestamp
- ✅ Info banner at top explaining data source
- ✅ Legend showing all 5 rain levels
- ✅ Stations are filtered (only VISIBLE=1 and ESTADO=1)

**Expected Results - Error**:
- ✅ Error icon displayed
- ✅ Error message shown
- ✅ "Reintentar" button available
- ✅ Tapping retry reloads data

**Rain Level Verification**:
- 0mm → Yellow sun icon → "Sin Lluvias"
- 0-10mm → Green drop icon → "Acumulados Bajos"
- 10.1-30mm → Blue drop icon → "Acumulados Moderados"
- 30.1-50mm → Orange cloud icon → "Acumulados Altos"
- >50mm → Red storm icon → "Acumulados Muy Altos"

**Pass Criteria**: Weather data loads successfully and displays correctly

---

### Test 7: Bottom Navigation Bar

**Objective**: Verify minimalist navigation design

**Steps**:
1. On any screen with bottom navigation
2. Observe navigation bar design
3. Tap each tab: Inicio, Partidos, Video, Análisis, Perfil
4. Observe selected vs unselected states

**Expected Results - Design**:
- ✅ Compact height (reduced padding)
- ✅ Very subtle shadow at top
- ✅ Clean, minimalist icons (22px)
- ✅ Small text labels (10px)
- ✅ Sufficient touch targets despite smaller size

**Expected Results - Selected State**:
- ✅ Yellow icon and text (#DDEE5E)
- ✅ Subtle yellow background (very low opacity)
- ✅ Rounded corners on background

**Expected Results - Unselected State**:
- ✅ Gray icon and text
- ✅ No background
- ✅ Clear visual difference from selected

**Pass Criteria**: Navigation bar is compact yet usable with clear states

---

### Test 8: Complete Match Creation Flow

**Objective**: End-to-end test of creating a match

**Steps**:
1. Start match creation
2. Step 0: Select "Partido Local"
3. Tap "Siguiente"
4. Step 1: Observe "not needed for local" message
5. Tap "Siguiente"
6. Step 2: Type "Partido entre Amigos"
7. **Verify button enables**
8. Tap "Siguiente"
9. Step 3: Select a court
10. Tap "Siguiente"
11. Step 4: Select date and time
12. Tap "Siguiente"
13. Step 5: Review confirmation
14. Tap "Crear Partido"

**Expected Results**:
- ✅ Flow completes without errors
- ✅ No stuck on any step
- ✅ All navigation buttons work
- ✅ Match created successfully
- ✅ Success message appears
- ✅ Returned to previous screen or match list

**Pass Criteria**: Complete flow works end-to-end

---

## Success Criteria

All tests must pass with:
- ✅ No crashes
- ✅ No visual overflow errors
- ✅ Correct API integration
- ✅ Proper color scheme
- ✅ Functional navigation
- ✅ Good accessibility
- ✅ Acceptable performance

---

## Sign-off

- [ ] All tests executed
- [ ] All tests passed
- [ ] Issues logged (if any)
- [ ] Ready for production

**Tester Name**: ___________________
**Date**: ___________________
**Signature**: ___________________
