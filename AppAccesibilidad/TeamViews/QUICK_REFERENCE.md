# Quick Reference Guide

## How to Use the Team Selection Feature

### For Users:

**Selecting a Team:**
1. In HomeView, tap either "Equipo 1" or "Equipo 2" card
2. Browse through the leagues or scroll to "Mis Equipos Creados"
3. Tap any team to select it
4. The view will automatically close and your selection will appear in HomeView

**Creating a Custom Team:**
1. In TeamSelectionView, tap the "+" button in the top right
2. Fill in:
   - Team name (required)
   - Country (optional, defaults to Mexico)
   - Division (optional, defaults to Liga MX)
   - Logo (optional, tap to select from photos)
3. Tap the blue checkmark to save
4. Your team appears in "Mis Equipos Creados"
5. Tap it to select it for the current team slot

**Deleting a Custom Team:**
1. In "Mis Equipos Creados", tap the trash icon on any custom team
2. Confirm deletion in the alert

---

## For Developers:

### Key Files Modified:

1. **SelectedTeamData.swift** (NEW)
   - Data model for selected teams
   - TeamSelectionManager class

2. **HomeView.swift**
   - Manages TeamSelectionManager
   - Passes to TeamSelectionView
   - Displays selected teams

3. **TeamSelectionView.swift**
   - Receives selectionManager and teamSlot
   - Handles team selection
   - Dismisses after selection

4. **TeamGlassLargeCard.swift**
   - Supports both image names and image data
   - Shows placeholder when no team selected

5. **TeamRowComponentView.swift**
   - Added tap gesture handling
   - Calls selection callback

### Adding Team Selection to a New View:

```swift
import SwiftUI

struct YourView: View {
    @State private var teamManager = TeamSelectionManager()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Show selected team
                if let team1 = teamManager.team1 {
                    Text("Team 1: \(team1.name)")
                }
                
                // Navigate to selection
                NavigationLink(
                    destination: TeamSelectionView(
                        selectionManager: teamManager,
                        teamSlot: 1
                    )
                ) {
                    Text("Select Team")
                }
            }
        }
    }
}
```

### Accessing Selected Team Data:

```swift
// In your view with TeamSelectionManager
if let team1 = teamSelectionManager.team1 {
    // Team 1 is selected
    print("Team 1: \(team1.name)")
    
    // Check if it's a predefined team
    if let imageName = team1.imageName {
        // Use imageName to load from assets
        Image(imageName)
    }
    
    // Check if it's a custom team with logo
    if let imageData = team1.imageData,
       let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
    }
    
    // Check if it's a custom team (has country/division)
    if let country = team1.country {
        print("Country: \(country)")
    }
}
```

### Architecture Pattern:

```
ObservableObject Pattern with @Observable:
- TeamSelectionManager is @Observable
- Automatically updates all views observing it
- No need for manual @Published properties
- Works with @State in SwiftUI

State Management:
- HomeView owns the TeamSelectionManager
- Passed by reference to TeamSelectionView
- Changes in TeamSelectionView reflect immediately in HomeView
- No need for callbacks or delegates
```

### Common Issues & Solutions:

**Issue**: Selection doesn't update in HomeView
**Solution**: Make sure you're passing the same teamSelectionManager instance, not creating a new one

**Issue**: Custom team logo doesn't show
**Solution**: Check that logoImageData is being saved correctly in NewTeamView

**Issue**: Can't tap teams to select them
**Solution**: Verify onTeamSelected callback is being passed through all the way to TeamCardView

**Issue**: Preview crashes
**Solution**: Make sure preview provides required parameters (selectionManager and teamSlot)

### Testing in Xcode Previews:

```swift
#Preview {
    // Create a mock selection manager
    let manager = TeamSelectionManager()
    manager.team1 = SelectedTeamData(name: "Test Team", imageName: "testlogo")
    
    return HomeView()
}
```

---

## Architecture Diagram:

```
┌─────────────────────────────────────────────────────────┐
│                        HomeView                          │
│  ┌────────────────────────────────────────────────┐    │
│  │     TeamSelectionManager (@State)              │    │
│  │     ├─ team1: SelectedTeamData?                │    │
│  │     └─ team2: SelectedTeamData?                │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  ┌─────────────────┐      ┌──────────────────┐         │
│  │  Team 1 Card    │      │  Team 2 Card     │         │
│  │  (displays      │      │  (displays       │         │
│  │   team1 name)   │      │   team2 name)    │         │
│  └────────┬────────┘      └────────┬─────────┘         │
└───────────┼──────────────────────────┼──────────────────┘
            │                          │
            │ NavigationLink           │ NavigationLink
            │ (passes manager          │ (passes manager
            │  + teamSlot: 1)          │  + teamSlot: 2)
            │                          │
            ▼                          ▼
┌───────────────────────────────────────────────────────┐
│              TeamSelectionView                         │
│  ┌─────────────────────────────────────────────┐     │
│  │  var selectionManager: TeamSelectionManager │     │
│  │  var teamSlot: Int                          │     │
│  └─────────────────────────────────────────────┘     │
│                                                        │
│  ┌──────────────────┐  ┌─────────────────────┐      │
│  │ Custom Teams     │  │ Predefined Teams     │      │
│  │ Section          │  │ Sections             │      │
│  │                  │  │                      │      │
│  │ CustomTeamCard   │  │ TeamRowComponent     │      │
│  │   ├─ onTap:      │  │   ├─ onTap:         │      │
│  │   └─ select      │  │   └─ select         │      │
│  └────────┬─────────┘  └──────────┬──────────┘      │
│           │                       │                  │
│           └───────────┬───────────┘                  │
│                       ▼                              │
│            selectTeam() / selectCustomTeam()         │
│                       │                              │
│                       ├─ Update selectionManager     │
│                       └─ dismiss()                   │
└───────────────────────────────────────────────────────┘
            │
            │ Updates propagate automatically
            │ due to @Observable
            ▼
┌───────────────────────────────────────────────────────┐
│                    HomeView                            │
│              (UI updates automatically)                │
└───────────────────────────────────────────────────────┘
```

## Summary

The implementation uses SwiftUI's modern state management with:
- `@Observable` for automatic UI updates
- Reference passing for shared state
- Navigation-based flow
- Callbacks for event handling

Everything is type-safe, follows SwiftUI best practices, and provides a smooth user experience!
