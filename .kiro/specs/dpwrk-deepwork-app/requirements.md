# Requirements Document

## Introduction

DPWRK is a Swift-based macOS productivity application designed to help users maintain deep focus by blocking digital distractions and building better work habits. The app combines session-based focus management with app/website blocking capabilities and provides lightweight productivity insights to help users track and improve their deep work routine over time.

## Requirements

### Requirement 1

**User Story:** As a knowledge worker, I want to set focused work goals before starting a session using a notepad-style interface, so that I can freely write as much detail as needed to maintain clear intention and purpose during my deep work time.

#### Acceptance Criteria

1. WHEN the user opens the app THEN the system SHALL display a goal-setting interface with a notepad-style text area
2. WHEN the user writes in the notepad THEN the system SHALL allow unlimited text input with proper text formatting
3. WHEN the user proceeds without setting a goal THEN the system SHALL allow starting the session with an empty notepad
4. WHEN the user types in the notepad THEN the system SHALL auto-save the content as they write
5. IF the user has previously set goals THEN the system SHALL preserve the notepad content between app launches

### Requirement 2

**User Story:** As a user wanting to control my focus time, I want to choose session duration using a built-in countdown timer, so that I can work within defined time boundaries.

#### Acceptance Criteria

1. WHEN the user accesses session setup THEN the system SHALL display duration selection options (15min, 25min, 45min, 60min, custom)
2. WHEN the user selects a custom duration THEN the system SHALL allow input of minutes between 5 and 180
3. WHEN the session starts THEN the system SHALL display a countdown timer showing remaining time
4. WHEN the timer reaches zero THEN the system SHALL notify the user that the session has ended
5. WHEN the session is active THEN the system SHALL update the timer display every second

### Requirement 3

**User Story:** As someone easily distracted by apps, I want to customize which applications get blocked during my focus session, so that I can eliminate my specific sources of distraction.

#### Acceptance Criteria

1. WHEN the user taps "Edit Blocklist" THEN the system SHALL display all installed applications with checkboxes
2. WHEN the user selects apps to block THEN the system SHALL save these preferences for future sessions
3. WHEN a focus session begins THEN the system SHALL prevent launching of selected blocked applications
4. WHEN a user attempts to open a blocked app THEN the system SHALL display a gentle reminder about the active focus session
5. IF the user has default blocklist preferences THEN the system SHALL pre-select those apps in the interface

### Requirement 4

**User Story:** As a user concerned about web distractions, I want to block specific websites during focus sessions, so that I can avoid browsing distractions while working.

#### Acceptance Criteria

1. WHEN the user accesses blocklist settings THEN the system SHALL provide an option to add website URLs
2. WHEN the user enters a website URL THEN the system SHALL validate the format and add it to the blocklist
3. WHEN a focus session is active THEN the system SHALL block access to listed websites across all browsers
4. WHEN the user tries to access a blocked website THEN the system SHALL display a focus reminder page
5. WHEN the session ends THEN the system SHALL restore normal website access

### Requirement 5

**User Story:** As someone wanting to build better habits, I want to reflect on what I achieved after each session using a notepad-style interface, so that I can freely write detailed reflections to learn from my focus time and improve future sessions.

#### Acceptance Criteria

1. WHEN a focus session ends THEN the system SHALL display a reflection notepad asking "What did you achieve?"
2. WHEN the user writes in the reflection notepad THEN the system SHALL allow unlimited text input with proper formatting
3. WHEN the user writes their reflection THEN the system SHALL auto-save the content and associate it with the session
4. WHEN the user skips reflection THEN the system SHALL still record the session as completed
5. WHEN the user completes reflection THEN the system SHALL show a brief positive acknowledgment
6. IF the user set a goal THEN the system SHALL display both the original goal and reflection notepad side by side for comparison

### Requirement 6

**User Story:** As a user wanting to track my productivity, I want to see lightweight insights about my focus patterns, so that I can understand and improve my deep work routine.

#### Acceptance Criteria

1. WHEN the user accesses insights THEN the system SHALL display completion rates for the past week/month
2. WHEN viewing insights THEN the system SHALL show focus consistency metrics (sessions per day/week)
3. WHEN sufficient data exists THEN the system SHALL display average session duration and preferred times
4. WHEN the user has reflection data THEN the system SHALL highlight common achievement themes
5. IF the user has less than 5 sessions THEN the system SHALL show encouraging messages about building the habit

### Requirement 7

**User Story:** As a macOS user, I want the app to have a clean, familiar interface with white background and elegant typography, so that it feels native and pleasant to use.

#### Acceptance Criteria

1. WHEN the app launches THEN the system SHALL display a white background with black text
2. WHEN displaying text THEN the system SHALL use Georgia, Georgia Italic, and other fonts consistent with Claude website and macOS apps
3. WHEN showing interface elements THEN the system SHALL incorporate relevant emojis for visual appeal
4. WHEN designing layouts THEN the system SHALL follow macOS Human Interface Guidelines
5. WHEN the user interacts with the app THEN the system SHALL provide smooth animations and transitions typical of quality macOS applications

### Requirement 8

**User Story:** As a user managing multiple focus sessions, I want the app to remember my preferences and provide a seamless experience, so that I can quickly start focused work without setup friction.

#### Acceptance Criteria

1. WHEN the user opens the app THEN the system SHALL remember the last used session duration
2. WHEN setting up a session THEN the system SHALL recall the previous blocklist configuration
3. WHEN the app is closed during a session THEN the system SHALL maintain blocking and timer state
4. WHEN the system restarts THEN the system SHALL restore any active focus session
5. IF no previous preferences exist THEN the system SHALL provide sensible defaults for first-time users