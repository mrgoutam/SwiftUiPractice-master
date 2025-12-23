//
//  EnvironmentBootcamp.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 23/12/25.
//

import SwiftUI

/*
 Environment & EnvironmentObject:
 
 1️⃣ What Problem Do They Solve?
 SwiftUI views are:
 -> Value types (struct)
 -> Recreated frequently
 -> Not meant to hold global mutable state
 
 The problem:
 How do we share data deep in the view hierarchy without passing it manually through every initializer?
 That is exactly what Environment solves.
 
 2️⃣ Mental Model (Very Important)
 Environment = Read-only global context for a view tree
 
 Think of it as:
 -> A dictionary of values
 -> Scoped to a view hierarchy
 -> Automatically propagated downward
 
 Each view reads, not owns.
 
 3️⃣ @Environment (Reading Values)
 What It Is:
 @Environment reads a value that already exists in the environment.
 
 Example: System Environment Value
 
 struct ContentView: View {
     @Environment(\.colorScheme) var colorScheme

     var body: some View {
         Text(colorScheme == .dark ? "Dark" : "Light")
     }
 }
 
 Key points:
 -> You are not creating colorScheme
 -> SwiftUI injects it
 -> Value changes trigger view update
 
 4️⃣ Custom Environment Values
 When You Need This
 
 When you want:
 -> Global configuration
 -> Feature flags
 -> Read-only shared values
 
 Step 1: Define the Key
 private struct AppThemeKey: EnvironmentKey {
     static let defaultValue = "Blue"
 }
 		
 Step 2: Extend EnvironmentValues
 extension EnvironmentValues {
     var appTheme: String {
         get { self[AppThemeKey.self] }
         set { self[AppThemeKey.self] = newValue }
     }
 }
 
 Step 3: Inject Value
 ContentView()
     .environment(\.appTheme, "Green")
 
 Step 4: Read Value
 @Environment(\.appTheme) var theme
 
 5️⃣ Key Rule About Environment
 Environment values are best for configuration, not business state.
 
 Good use cases:
 -> Theme
 -> Locale
 -> Feature toggles
 -> App-wide settings
 
 Bad use cases:
 -> User profile data
 -> Network state
 -> Mutable app logic
 
 This leads us to EnvironmentObject.
 
 6️⃣ @EnvironmentObject (Shared Observable State)
 What Problem It Solves:
 How do we share mutable, observable state across many views without passing it everywhere?
 That is EnvironmentObject.
 
 7️⃣ Mental Model
 EnvironmentObject = Shared reference injected at the root
 -> It is a class
 -> Conforms to ObservableObject
 -> SwiftUI subscribes automatically
 -> All child views can access it
 
 8️⃣ Basic Example
 
 Step 1: Create Shared Object
 class AppSession: ObservableObject {
     @Published var isLoggedIn = false
 }
 
 Step 2: Inject at Root
 @main
 struct MyApp: App {
     @StateObject private var session = AppSession()

     var body: some Scene {
         WindowGroup {
             ContentView()
                 .environmentObject(session)
         }
     }
 }
 
 Step 3: Read Anywhere Below
 struct ProfileView: View {
     @EnvironmentObject var session: AppSession

     var body: some View {
         Text(session.isLoggedIn ? "Logged In" : "Logged Out")
     }
 }
 
 9️⃣ Important Rules (Professional-Level)
 Rule 1: @EnvironmentObject Must Be Injected
 If not injected → runtime crash.
 
 This is intentional:
 -> SwiftUI wants you to fail fast
 
 Rule 2: Use @StateObject at the Injection Point
 Why?
 @StateObject var session = AppSession()
 -> Owns lifecycle
 -> Prevents re-creation
 -> Ensures stable reference
 
 Rule 3: EnvironmentObject Is a Dependency
 Treat it like Dependency Injection, not a global variable.
 
 Bad mindset:
 -> “I’ll just put everything in one environment object”
 
 Good mindset:
 -> “This view depends on X capability”
 
 🔟 Environment vs EnvironmentObject (Critical Comparison)
 | Feature       | Environment | EnvironmentObject |
 | ------------- | ----------- | ----------------- |
 | Type          | Value       | Reference         |
 | Mutability    | Read-only   | Mutable           |
 | Observability | Automatic   | via @Published    |
 | Use case      | Config      | App state         |
 | Ownership     | System      | App               |

 1️⃣1️⃣ Common Mistakes (Very Important)
 ❌ Putting Business Logic in Environment
 Leads to:
 -> Hidden dependencies
 -> Hard testing
 -> Tight coupling
 
❌ Using EnvironmentObject Everywhere
 Leads to:
 -> Global state abuse
 -> Unpredictable updates
 -> Performance issues
 
 ✅ Correct Pattern
 -> Small EnvironmentObjects
 -> Injected at meaningful boundaries
 -> Clear responsibility
 
 1️⃣2️⃣ Why This Matters for Combine (Preview)
 @EnvironmentObject:
 -> Uses Combine internally
 -> Subscribes to objectWillChange
 -> Triggers view invalidation
 Understanding this now will make Combine much easier later.
 
 Final Mental Model (Lock This In):
 - Environment = context
 - EnvironmentObject = shared state
 - Views = readers, not owners
 
 Below is a pure, minimal, production-style example that shows exactly what @Environment and @EnvironmentObject are meant for — no extra abstractions, no Combine noise, no shortcuts.
 
 Read it top-to-bottom once, then re-read slowly.
 
 PURE SWIFTUI EXAMPLE @Environment + @EnvironmentObject:
 
 Scenario (Realistic & Clean)
 We will build:
 - App Theme → configuration → @Environment
 - User Session → mutable app state → @EnvironmentObject
 
 This separation is intentional and correct.
 
 
 1️⃣ @Environment — App Configuration (Value)
 -> Use Case
 -> Theme
 -> App mode
 -> Feature flags
 -> Read-only context
 
 Step 1: Define Environment Key
 private struct AppThemeKey: EnvironmentKey {
     static let defaultValue: String = "Blue"
 }
 
 Step 2: Extend EnvironmentValues
 extension EnvironmentValues {
     var appTheme: String {
         get { self[AppThemeKey.self] }
         set { self[AppThemeKey.self] = newValue }
     }
 }
 
 Step 3: Inject at Root
 @main
 struct EnvironmentDemoApp: App {

     var body: some Scene {
         WindowGroup {
             ContentView()
                 .environment(\.appTheme, "Green")
         }
     }
 }
 
 Step 4: Read Anywhere
 struct ContentView: View {
     @Environment(\.appTheme) private var theme

     var body: some View {
         Text("Theme: \(theme)")
             .font(.title)
     }
 }
 
 Key Observations:
 -> ContentView does not own the theme
 -> Theme flows downward
 -> No class, no lifecycle issues
 
 2️⃣ @EnvironmentObject — Shared App State (Reference)
 Use Case
 -> Login state
 -> User profile
 -> Cart data
 -> Session state
 
 Step 1: Create ObservableObject
 final class UserSession: ObservableObject {
     @Published var isLoggedIn: Bool = false
 }
 
 Step 2: Inject at App Root (Correct Ownership)
 @main
 struct EnvironmentObjectDemoApp: App {

     @StateObject private var session = UserSession()

     var body: some Scene {
         WindowGroup {
             RootView()
                 .environmentObject(session)
         }
     }
 }
 
 Step 3: Root View (No Passing Needed)
 struct RootView: View {
     var body: some View {
         NavigationStack {
             HomeView()
         }
     }
 }
 
 Step 4: Consume Deep in Hierarchy
 struct HomeView: View {
     @EnvironmentObject private var session: UserSession

     var body: some View {
         VStack(spacing: 20) {
             Text(session.isLoggedIn ? "Welcome Back" : "Please Log In")

             Button("Toggle Login") {
                 session.isLoggedIn.toggle()
             }

             NavigationLink("Go to Profile", destination: ProfileView())
         }
         .padding()
     }
 }
 
 Step 5: Another Deep Child View
 struct ProfileView: View {
     @EnvironmentObject private var session: UserSession

     var body: some View {
         Text(session.isLoggedIn ? "User Profile" : "Guest Profile")
             .font(.headline)
     }
 }
 
 3️⃣ What This Example Demonstrates (Critical)
 @Environment
 -> Value-based
 -> Configuration
 -> No ownership
 -> No mutation responsibility
 
 @EnvironmentObject
 -> Reference-based
 -> Shared mutable state
 -> Owned at root
 -> Observed automatically
 
 4️⃣ What Happens Internally (Simplified)
 UserSession changes
 ↓
 objectWillChange fires
 ↓
 SwiftUI invalidates dependent views
 ↓
 body recomputed
 
 You did nothing manually — SwiftUI + Combine handled it.
 */







struct EnvironmentBootcamp: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    EnvironmentBootcamp()
}
