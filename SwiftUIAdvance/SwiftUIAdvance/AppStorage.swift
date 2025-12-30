//
//  AppStorage.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 30/12/25.
//

import SwiftUI

struct AppStorage: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    AppStorage()
}

/*
 @AppStorage — Deep Understanding
 1. Mental Model (Most Important)
 
 @AppStorage is:
 A SwiftUI-native, reactive wrapper over UserDefaults
 
 Key properties:
 -> Persists small values
 -> Automatically updates views
 -> Requires zero boilerplate
 -> Integrates with Environment + state system
 
 Think of it as:
 
 UserDefaults
    ↓
 @AppStorage
    ↓
 SwiftUI View invalidation
 
 When the value changes:
 ✔ Stored permanently
 ✔ UI updates automatically
 ✔ No manual refresh
 
 2. What @AppStorage Is Meant For
 
 Use it for:
 -> Theme selection (light / dark / system)
 -> Language preference
 -> Onboarding completion flag
 -> Feature toggles
 -> User preferences
 
 Do NOT use it for:
 -> Large data
 -> Sensitive data (use Keychain)
 -> Business domain models
 
 3. Basic Example (Pure)
 
 @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
 
 This:
 -> Reads from UserDefaults.standard["isLoggedIn"]
 -> Writes automatically
 -> Re-renders view on change
 
 4. Production Example — App Theme
 
 Step 1: Theme enum
 enum AppTheme: String, CaseIterable, Identifiable {
     case system
     case light
     case dark

     var id: String { rawValue }
 }
 
 Step 2: Store preference
 @AppStorage("appTheme") private var appTheme: AppTheme = .system
 
 SwiftUI automatically encodes/decodes RawRepresentable.
 
 Step 3: Apply globally
 @main
 struct MyApp: App {

     @AppStorage("appTheme") private var appTheme: AppTheme = .system

     var body: some Scene {
         WindowGroup {
             RootView()
                 .preferredColorScheme(colorScheme)
         }
     }

     private var colorScheme: ColorScheme? {
         switch appTheme {
         case .system: return nil
         case .light:  return .light
         case .dark:   return .dark
         }
     }
 }
 
 ✔ System override supported
 ✔ No duplication
 ✔ Single source of truth
 
 
 5. Settings Screen (Real App Pattern)
 struct SettingsView: View {

     @AppStorage("appTheme") private var appTheme: AppTheme = .system

     var body: some View {
         Form {
             Picker("Theme", selection: $appTheme) {
                 ForEach(AppTheme.allCases) { theme in
                     Text(theme.rawValue.capitalized)
                         .tag(theme)
                 }
             }
         }
         .navigationTitle("Settings")
     }
 }
 ✔ Changes persist
 ✔ UI updates instantly
 ✔ App restarts not required
 
 6. Why @AppStorage Beats Manual UserDefaults
 ❌ Old Way
 UserDefaults.standard.set(true, forKey: "flag")
 let flag = UserDefaults.standard.bool(forKey: "flag")
 
 Problems:
 -> Not reactive
 -> Boilerplate
 -> Error-prone
 
 ✅ Modern Way
 @AppStorage("flag") var flag = false
 
 7. @AppStorage vs Other Property Wrappers
 
 | Wrapper              | Purpose                |
 | -------------------- | ---------------------- |
 | `@State`             | View-local state       |
 | `@Binding`           | Pass state down        |
 | `@Environment`       | System values          |
 | `@EnvironmentObject` | Shared runtime state   |
 | `@AppStorage`        | Persistent preferences |

 @AppStorage bridges runtime state and persistence
 
 11. Professional Rule of Thumb:
 If a value must survive app restart and change UI immediately, use @AppStorage.
 */
