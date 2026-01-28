

# QuickNote App

## Introduction

QuickNote is a simple and elegant note-taking iOS application built using **Swift** and **Xcode**. It allows users to capture ideas efficiently through **plain text notes** and **voice recordings**, while maintaining a clean UI and smooth user experience.

The app focuses on productivity, intuitive navigation, and seamless audio playback, making it ideal for daily note-taking.

---

## App Flow Overview

### Welcome Screen

* First-launch onboarding screen introducing the core features of QuickNote.
* Guides users smoothly into the subscription or home flow.

### Subscription Screen

* Displays premium features such as unlimited notes and advanced voice recording.
* Clean and focused UI encouraging users to subscribe.
* Seamless transition to the Home Dashboard after successful subscription.

### Home Dashboard

* Displays categorized folders such as **Personal, Work, School, and Travel**.
* Shows a **Recent Notes** timeline combining text and voice notes.
* Integrated **Mini Player View** for voice note playback.
* Quick access to create new notes.

### Add Note Screen

* Central hub for creating notes.
* Allows users to choose between:

  * **Plain Text Note**
  * **Voice Note Recording**

### Plain Note Editor

* Minimal and distraction-free writing interface.
* Custom titles with automatic timestamps.
* Interactive edit and share menu for note management.

### Voice Recorder Screen

* High-performance audio recording interface.
* Real-time waveform visualization.
* Supports play, pause, rewind, and forward controls.

### Folder View Screen

* Displays notes filtered by selected category.
* Supports sorting, editing, and voice note playback.

---

## Features

### Core Data Persistence

* Robust data storage using `CoreDataManager`.
* Notes and folders are stored securely and efficiently.
* Automatic UI updates using `NotificationCenter` when notes are added, edited, or deleted.

### Advanced Voice Recording

* Custom `WaveformLineView` built using `CoreGraphics` to draw real-time audio levels.
* Integrated with `AVFoundation` for high-quality `.m4a` audio recording.
* Smooth and responsive recording experience.

### Global Mini Player

* Persistent **Mini Player View** available on the Home Screen.
* Allows users to **Play**, **Rewind**, and **Stop** voice recordings.
* Enables continuous audio playback while navigating the app.
* Playback state stays in sync with the active voice note.

### Folder Management

* Predefined categories and dynamic custom folders.
* Custom categories stored using `UserDefaults`.
* Long-press gestures for deleting folders safely.

## Note edit & Share Menu

* A contextual Share Menu is available for note actions and edit menu is also present. 
* The share menu adapts dynamically based on the note state.

### Add Note State
* When creating a new note, the share/options menu provides:
* Save Note – Saves the note to local storage.
* Share Note – Allows sharing the note content using the system share sheet.
* Delete option is hidden at this stage to prevent accidental data loss.

### Edit Note State

* When editing an existing note, the menu updates to include:
* Save Changes
* Share Note
* Delete Note – Permanently removes the note after confirmation.


## Prerequisites

* Xcode 14.0 or later
* iOS 15.0 or later
* Swift 5.0 or later

---



##  Contributing

* Contributions are welcome.
* Feel free to submit issues or create pull requests for improvements or bug fixes.

---

##  Support

If you encounter any issues or have questions, please contact the project maintainer at:
**[email protected]**

---

## License

This project is open source and available for learning and development purposes.

---

## Acknowledgements

Special thanks to the Apple developer community and official Apple documentation for **AVFoundation**, **Core Data**, and **UIKit**, which greatly supported the development of this project.

Screenshots

<div style="display: flex; gap: 10px; flex-wrap: wrap;">

  <img src="https://github.com/user-attachments/assets/259e9814-e80c-41ff-a4ff-eac5b41c469e" width="200">
  <img src="https://github.com/user-attachments/assets/caf62b32-aefe-4ec5-bb96-11bedb5e642a" width="200">
  <img src="https://github.com/user-attachments/assets/1b621fb2-b7bc-4abf-ae16-e502fab042c9" width="200">
  <img src="https://github.com/user-attachments/assets/d7b76317-e493-44c7-9b6c-e705fd5b79a7" width="200">
  <img src="https://github.com/user-attachments/assets/42de2e06-6f62-41f7-ad30-fa55fad92d93" width="200">
  <img src="https://github.com/user-attachments/assets/6d3a10df-96ee-4ded-bedb-ef3465d5d0cf" width="200">

</div>

## Demo Video  

(https://go.screenpal.com/watch/cOVujcn30zq) 
