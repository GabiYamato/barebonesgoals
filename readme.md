# Daily Tracker - Neobrutalist Habit Tracker

A Flutter-based daily habit tracker app with a **neobrutalist design style** featuring a GitHub-style contribution grid layout.

## Design Philosophy

This app follows strict neobrutalist design principles:

- **White backgrounds** everywhere
- **Black borders** (2-3px thick)
- **Bold typography** with no thin fonts
- **No gradients** or rounded corners
- **Flat colors** for completed states
- **Minimal shadows** - essentially none
- **Rigid, boxy structure**

## Features

### 1. Top Bar
- Fixed position at top of screen
- Displays app title: "DAILY TRACKER"
- Shows streak counter with fire icon
- Streak counts consecutive days with >70% task completion

### 2. Task Grid (GitHub-style)
- Each row represents one task
- 30 columns showing the last 30 days
- GitHub-style square cells (16x16px with 1.5-2px borders)
- **Tap to toggle**: empty (white) → completed (green) → empty
- Horizontal scrolling for day columns
- Task name boxes with inline remove button

### 3. Add/Remove Tasks
- "ADD TASK" button opens neobrutalist modal
- Single text input for task name
- Each task row has "X" button to remove
- Removal deletes task and all its history

### 4. Completion Chart
- Bar chart showing daily completion percentages
- Last 30 days visible
- Y-axis: 0-100%
- Flat blue bars with black borders
- Updates dynamically on completion changes

### 5. History Screen
- Accessible via "HISTORY" button
- Shows past 3 months in compressed calendar view
- 7-column layout (Sun-Sat)
- Color intensity reflects completion percentage
- Full neobrutalist styling

### 6. Data Persistence
- All data persists across app restarts
- Uses `shared_preferences` for local storage
- Stores tasks and completion records as JSON

## File Structure

```
lib/
├── main.dart                    # App entry point, main screen
├── models/
│   ├── task.dart                # Task data model
│   └── tracker_data.dart        # Main data container
├── services/
│   └── storage_service.dart     # Local persistence
├── theme/
│   └── neo_brutalist_theme.dart # Design constants
├── widgets/
│   ├── top_bar.dart             # App header with streak
│   ├── task_grid.dart           # GitHub-style grid
│   ├── add_task_modal.dart      # Task creation modal
│   └── completion_chart.dart    # Bar chart widget
└── screens/
    └── history_screen.dart      # Past months view
```

## Interaction Summary

| Action | Result |
|--------|--------|
| Tap grid cell | Toggle completed/uncompleted state |
| Tap "ADD TASK" | Opens modal to create new task |
| Tap "X" on task | Deletes task and history |
| Scroll grid horizontally | Navigate through 30 days |
| Tap "HISTORY" | Open history screen |

## Colors

| Element | Color |
|---------|-------|
| Background | `#FFFFFF` (white) |
| Borders | `#000000` (black) |
| Completed cells | `#00C853` (green) |
| Chart bars | `#2979FF` (blue) |
| Accent | `#FFD600` (yellow) |

## Running the App

```bash
cd app_files
flutter pub get
flutter run
```

## Dependencies

- `shared_preferences` - Local data persistence
