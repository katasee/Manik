# Firebase SDK

The Firebase iOS SDK is a normal remote Swift package dependency
(`https://github.com/firebase/firebase-ios-sdk`, "Up to Next Major Version"), providing the
`FirebaseAuth` and `FirebaseFirestore` products to the `Manik` target. Requires Xcode 16.3+ (Swift
tools version 6.1); the project now builds on Xcode 16.4. (Earlier this was a local Swift package
reference pointing at a machine-specific `~/Developer/firebase-ios-sdk` checkout, needed because
Firebase >= 12.15.0 requires Swift tools 6.1 and the project was still on Xcode 16.1 — that
workaround is gone now that Xcode is updated.)

`GoogleService-Info.plist` is gitignored (regenerate from Firebase Console per environment) but
must exist on disk in `Manik/Manik/` for the app to run — Xcode's synchronized-folder project
format (`PBXFileSystemSynchronizedRootGroup`) means any file dropped into that directory tree is
picked up automatically, no manual "Add Files" step needed.
