# DPWRK Deep Work App - Design Document

## Overview

DPWRK is a native macOS application built with SwiftUI that helps users maintain deep focus through session-based work management, distraction blocking, and productivity insights. The app follows macOS Human Interface Guidelines while incorporating a clean, elegant design inspired by Claude's website and premium macOS applications.

The application architecture emphasizes simplicity, reliability, and user experience, with a focus on minimal friction between the user's intention to focus and actually beginning productive work.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DPWRK App (SwiftUI)                     │
├─────────────────────────────────────────────────────────────┤
│  UI Layer                                                   │
│  ├── Session Setup View (Goal + Duration)                   │
│  ├── Active Session View (Timer + Controls)                 │
│  ├── Blocklist Management View                              │
│  ├── Reflection View (Post-session)                         │
│  └── Insights View (Analytics)                              │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer                                       │
│  ├── Session Manager                                        │
│  ├── Blocking Service                                       │
│  ├── Timer Service                                          │
│  ├── Data Persistence Manager                               │
│  └── Analytics Engine                                       │
├─────────────────────────────────────────────────────────────┤
│  System Integration Layer                                   │
│  ├── App Blocking (NSWorkspace + Launch Services)          │
│  ├── Website Blocking (Network Extension)                  │
│  ├── Notifications (UserNotifications)                     │
│  └── System Permissions                                     │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                 │
│  ├── Core Data (Session History)                           │
│  ├── UserDefaults (Preferences)                            │
│  └── Keychain (Sensitive Settings)                         │
└─────────────────────────────────────────────────────────────┘
```

### Design Patterns

- **MVVM (Model-View-ViewModel)**: SwiftUI's natural pattern for separating UI from business logic
- **Observer Pattern**: For real-time timer updates and session state changes
- **Strategy Pattern**: For different blocking mechanisms (apps vs websites)
- **Repository Pattern**: For data persistence abstraction

## Components and Interfaces

### 1. Core Models

#### Session Model
```swift
struct FocusSession {
    let id: UUID
    let goal: String
    let duration: TimeInterval
    let startTime: Date
    let endTime: Date?
    let reflection: String?
    let blockedApps: [String]
    let blockedWebsites: [String]
    let completed: Bool
}
```

#### User Preferences
```swift
struct UserPreferences {
    var defaultDuration: TimeInterval
    var defaultBlockedApps: [String]
    var defaultBlockedWebsites: [String]
    var notificationsEnabled: Bool
    var soundEnabled: Bool
}
```

### 2. UI Components

#### Main Navigation Structure
- **Tab-based navigation** with clean, minimal tabs
- **Session Setup** (🎯 Focus)
- **Active Session** (⏱️ Timer) 
- **Insights** (📊 Progress)
- **Settings** (⚙️ Preferences)

#### Session Setup View
- **Goal Notepad**: Large, clean text area with Georgia font
- **Duration Picker**: Elegant time selection with preset options
- **Blocklist Quick Access**: "Edit Blocklist" button with app count indicator
- **Start Session Button**: Prominent, encouraging CTA

#### Active Session View
- **Large Timer Display**: Clean, readable countdown in Georgia font
- **Goal Reference**: Minimized view of current goal (expandable)
- **Progress Ring**: Visual representation of session progress
- **Emergency Controls**: Pause/Stop options (with confirmation)

#### Blocklist Management View
- **App List**: Searchable list of installed applications with toggle switches
- **Website Manager**: Add/remove website URLs with validation
- **Quick Presets**: Common blocklist configurations (Social Media, News, etc.)

#### Reflection View
- **Achievement Notepad**: Large text area for detailed reflection
- **Goal Comparison**: Side-by-side view of original goal and achievement
- **Session Summary**: Duration, completion status, blocked items count
- **Positive Reinforcement**: Encouraging messages and emojis

#### Insights View
- **Weekly Overview**: Session completion rates with visual charts
- **Focus Patterns**: Best times of day, average session length
- **Achievement Themes**: Common words/themes from reflections
- **Streak Tracking**: Consecutive days with completed sessions

### 3. Service Layer

#### Session Manager
- Coordinates session lifecycle (setup → active → reflection)
- Manages session state persistence
- Handles session interruptions and recovery

#### Blocking Service
- **App Blocking**: Uses NSWorkspace and Launch Services APIs
- **Website Blocking**: Implements Network Extension for system-wide blocking
- **Graceful Blocking**: Shows custom "focus reminder" instead of hard blocks

#### Timer Service
- High-precision countdown with second-by-second updates
- Background operation support
- Notification scheduling for session end

#### Analytics Engine
- Processes session data for insights
- Calculates completion rates, patterns, and trends
- Generates encouraging feedback messages

## Data Models

### Core Data Schema

#### FocusSession Entity
- `id: UUID` (Primary Key)
- `goal: String` (Notepad content)
- `duration: Double` (Seconds)
- `startTime: Date`
- `endTime: Date?`
- `reflection: String?` (Notepad content)
- `completed: Bool`
- `blockedAppsData: Data` (JSON encoded array)
- `blockedWebsitesData: Data` (JSON encoded array)

#### UserPreference Entity
- `key: String` (Primary Key)
- `value: Data` (JSON encoded value)
- `lastModified: Date`

### Data Relationships
- One-to-many relationship between User and FocusSession
- Preferences stored as key-value pairs for flexibility

## Error Handling

### System Permission Errors
- **App Blocking Permissions**: Guide user through System Preferences setup
- **Network Extension**: Handle installation and activation gracefully
- **Accessibility Permissions**: Required for some blocking features

### Session Interruption Handling
- **App Crash Recovery**: Restore active session on restart
- **System Sleep/Wake**: Pause timer during sleep, resume on wake
- **Force Quit Protection**: Persist session state frequently

### User Experience Errors
- **Invalid Duration**: Gentle validation with helpful messages
- **Empty Blocklist**: Allow sessions without blocking (user choice)
- **Network Issues**: Graceful degradation for website blocking

## Testing Strategy

### Unit Testing
- **Session Logic**: Timer accuracy, state transitions
- **Data Persistence**: Core Data operations, UserDefaults
- **Analytics Calculations**: Completion rates, pattern detection
- **Blocking Logic**: App detection, URL validation

### Integration Testing
- **System Permissions**: Automated testing of permission flows
- **Cross-Component Communication**: Session Manager ↔ UI updates
- **Data Migration**: Version compatibility testing

### UI Testing
- **Navigation Flows**: Complete user journeys from setup to reflection
- **Accessibility**: VoiceOver support, keyboard navigation
- **Visual Regression**: Ensure UI consistency across macOS versions

### Manual Testing
- **Real-World Usage**: Extended focus sessions with actual work
- **Blocking Effectiveness**: Test with various apps and websites
- **Performance**: Memory usage during long sessions

## UI Design Specifications

### Typography
- **Primary Font**: Georgia (body text, goals, reflections)
- **Secondary Font**: Georgia Italic (emphasis, quotes)
- **System Font**: SF Pro (UI elements, buttons, labels)
- **Monospace**: SF Mono (timer display, technical data)

### Color Palette
- **Background**: Pure White (#FFFFFF)
- **Primary Text**: Rich Black (#1C1C1E)
- **Secondary Text**: Medium Gray (#8E8E93)
- **Accent Color**: Deep Blue (#007AFF) - following macOS system accent
- **Success**: Forest Green (#34C759)
- **Warning**: Amber (#FF9500)

### Layout Principles
- **Generous Whitespace**: Following Apple's design philosophy
- **Clear Hierarchy**: Distinct visual levels for different content types
- **Consistent Spacing**: 8pt grid system for all measurements
- **Responsive Design**: Adapts to different window sizes gracefully

### Interactive Elements
- **Buttons**: Rounded rectangles with subtle shadows
- **Text Areas**: Clean borders with focus states
- **Toggles**: Native macOS switches and checkboxes
- **Progress Indicators**: Circular progress rings with smooth animations

### Emoji Usage
- **Contextual Enhancement**: 🎯 for goals, ⏱️ for timer, 📊 for insights
- **Emotional Support**: 🎉 for completions, 💪 for encouragement
- **Visual Hierarchy**: Used sparingly to avoid clutter

### Animations and Transitions
- **Smooth Transitions**: 0.3s ease-in-out for view changes
- **Timer Updates**: Smooth countdown with subtle pulsing
- **Success Celebrations**: Gentle confetti or checkmark animations
- **Loading States**: Elegant progress indicators for system operations

## Security and Privacy

### Data Protection
- **Local Storage Only**: No cloud sync to protect user privacy
- **Encrypted Preferences**: Sensitive settings stored in Keychain
- **Minimal Data Collection**: Only essential information for functionality

### System Integration Security
- **Sandboxing**: Proper entitlements for required system access
- **Permission Requests**: Clear explanations for each system permission
- **Secure Blocking**: No logging of blocked content or user activity

## Performance Considerations

### Memory Management
- **Efficient Timer**: Minimal CPU usage during active sessions
- **Image Optimization**: Proper asset management for app icons
- **Background Processing**: Minimal impact when app is not active

### Startup Performance
- **Fast Launch**: Under 2 seconds from click to usable interface
- **State Restoration**: Quick recovery of previous session state
- **Lazy Loading**: Load insights data only when needed

### Scalability
- **Session History**: Efficient querying of large session datasets
- **App Detection**: Cached application lists for quick blocklist setup
- **Analytics Processing**: Background computation of insights data