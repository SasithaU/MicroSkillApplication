# MicroSkill App Completion Checklist & Testing Guide

Use this checklist after development to determine whether your app is complete, stable, and ready for demonstration/submission.

---

# 1. Core Functionality Checklist

## Onboarding & Authentication
- [ ] Splash screen loads correctly
- [ ] First-time setup screen appears only once
- [ ] User name and goal are saved
- [ ] Biometric authentication works (Face ID / Touch ID)
- [ ] App opens successfully after authentication

## Home Dashboard
- [ ] Continue Learning button works
- [ ] Greeting shows user name
- [ ] Current streak displays correctly
- [ ] Lesson cards appear correctly

## Lesson System
- [ ] Lessons load successfully
- [ ] Lesson content scrolls properly
- [ ] Mark lesson complete works
- [ ] Completed lesson status saves

## Quiz System
- [ ] Quiz appears after lesson
- [ ] Options are selectable
- [ ] Correct answer logic works
- [ ] Result screen shows correct score
- [ ] Continue Learning button opens next lesson

## Adaptive Learning Path
- [ ] Lessons unlock in order
- [ ] Locked lessons cannot be opened
- [ ] Next lesson unlocks after completion

## Saved Lessons
- [ ] Bookmark button works
- [ ] Saved lessons display correctly
- [ ] Saved lesson opens properly

## Progress & Insights
- [ ] Charts display correctly
- [ ] Streak updates accurately
- [ ] Productivity insights calculate correctly

## Notifications
- [ ] Notification permission prompt appears
- [ ] Notifications trigger successfully
- [ ] Notification actions work

## Core Data
- [ ] Data persists after app restart
- [ ] Lessons remain completed after relaunch
- [ ] User progress is retained

---

# 2. UI / UX Checklist

## Visual Consistency
- [ ] Colors remain consistent across screens
- [ ] Typography follows iOS style
- [ ] Padding and spacing are consistent
- [ ] Buttons look consistent
- [ ] Cards use similar design style

## Navigation
- [ ] No dead-end screens
- [ ] Back navigation works
- [ ] Tab navigation works correctly
- [ ] Navigation transitions feel smooth

## Accessibility
- [ ] Buttons have accessibility labels
- [ ] Font scales correctly
- [ ] Contrast is readable
- [ ] VoiceOver reads screen correctly

---

# 3. Code Quality Checklist

- [ ] Code is modular
- [ ] View names are meaningful
- [ ] Variables are named clearly
- [ ] Reusable components are used
- [ ] Large files are separated into smaller components
- [ ] No unnecessary duplicate code

---

# 4. Performance Checklist

- [ ] App launches quickly
- [ ] No UI freezing
- [ ] Navigation feels smooth
- [ ] Charts render quickly
- [ ] Data loads without delay

---

# 5. Crash Testing Checklist

Try these intentionally:

- [ ] Open app repeatedly
- [ ] Rapidly tap buttons
- [ ] Navigate quickly between tabs
- [ ] Open empty saved screen
- [ ] Open quiz without lesson completion
- [ ] Restart app during lesson
- [ ] Close app and reopen

App should not crash.

---

# 6. Manual Testing Plan

## Test Case 1 – New User Flow
1. Install app
2. Launch app
3. Complete onboarding
4. Authenticate
5. Verify Home Dashboard appears

Expected Result:
- App works smoothly

---

## Test Case 2 – Learning Flow
1. Open lesson
2. Complete lesson
3. Start quiz
4. Submit answer
5. Continue learning

Expected Result:
- Next lesson opens

---

## Test Case 3 – Save Lesson
1. Bookmark lesson
2. Open Saved tab
3. Open bookmarked lesson

Expected Result:
- Saved lesson appears correctly

---

## Test Case 4 – Restart App
1. Complete lesson
2. Close app
3. Reopen app

Expected Result:
- Progress remains saved

---

# 7. Device Testing Checklist

Test on multiple device sizes if possible:

- [ ] iPhone SE size
- [ ] Standard iPhone size
- [ ] Larger iPhone size

Check:
- UI spacing
- Scroll behavior
- Safe area handling

---

# 8. Accessibility Testing

Test:

- VoiceOver enabled
- Larger text size
- Reduced motion
- Dark mode

---

# 9. Lecturer Viva Checklist

Be able to explain:

- Why SwiftUI was used
- Why Core Data was selected
- Why biometric authentication was chosen
- How adaptive learning works
- How quiz logic works
- How progress tracking works
- Why navigation is structured this way

---

# 10. “Perfect App” Final Readiness Checklist

Your app is ready if:

- [ ] No crashes
- [ ] Core features work
- [ ] UI feels consistent
- [ ] Data persists
- [ ] Notifications work
- [ ] Accessibility included
- [ ] Navigation works
- [ ] App demonstrates advanced iOS features
- [ ] Code is readable
- [ ] You can confidently explain every feature

---

# Final Rule

If another student can use your app without explanation and understand it immediately, your UX is strong.

If your app can survive repeated testing without crashing, your implementation is stable.

If you can explain every design decision during viva, your project is complete.

