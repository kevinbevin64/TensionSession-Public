# Roadmap 1

## What has been completed

The project currently has a well-functioning backend that is capable of persisting user-created workout templates, completed workout sessions and user preferences through a DataDelegate service. For users who have downloaded the Apple Watch app, a Companion service handles communication and sync between the iOS and watchOS apps, so template workout data, completed workout data, and user information remains synced between the two devices. 

## What is left to complete

The backend still requires a TimeKeeper service so users can keep track of their rest-time between sets. This is a core feature of the app. Additionally, HealthKit needs to be integrated, and SwiftData migration needs to be setup. 

Regarding the frontend, the iOS UI is currently in progress, while the watchOS UI is more polished. I recently finished RecordView's exercise list, I am currently working on RecordView's toolbar, which shows a workout selector and buttons for start, pause, and stop. after that, I'll work on the detail view of each Exercise. 

The steps mentioned above, as well as other details, are listed below:

### Frontend 

- [x] RecordView
    - [x] Exercise list 
    - [x] Toolbar items (Date: July 29, 2025) 
        - [x] Workout selector (Date: July 25, 2025)
        - [x] Start button (Date: July 25, 2025) 
        - [x] Pause button (Date: July 29, 2025)
        - [x] Stop button  (Date: July 29, 2025)
    - [x] Exercise detail view
        - [x] Done button  (Date: July 29, 2025)
        - [x] Rep picker  (Date: July 29, 2025)
        - [x] Weight picker  (Date: July 29, 2025)
        - [-] TimeKeeper (Deferred)
        - [x] Set number counter  (Date: July 29, 2025)
- [ ] PlanView 
- [ ] AnalyzeView

### Backend

- [ ] TimeKeeper
- [ ] HealthKit integration 
- [ ] SwiftData migration 
