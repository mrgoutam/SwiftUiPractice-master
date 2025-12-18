//
//  SomeViewVSAnyView.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 18/12/25.
//

/*
 some View vs AnyView (With Clear Examples):
 This distinction is fundamental to SwiftUI performance, architecture, and correctness.
 Misuse leads to sluggish UI, broken animations, and type errors.
 
 1. some View (Opaque[Not Clear] Return Type)
 Definition :
 some View means:
 “I am returning one specific view type, but I am not exposing what it is.”
 The compiler knows the exact type at compile time.
 Example
 var body: some View {
     Text("Hello")
         .font(.title)
 }
 Although it looks dynamic, this always returns the same concrete type.
 
 
 Conditional Example (Correct Usage):
 var body: some View {
     if isLoggedIn {
         Text("Welcome")
     } else {
         Text("Please Login")
     }
 }
 Why this works:
 Both branches return Text
 The concrete type is the same
 
 ❌ Invalid with some View:
 var body: some View {
     if isLoggedIn {
         Text("Welcome")
     } else {
         Image(systemName: "person")
     }
 }
 Error:
 Function declares an opaque return type, but has different underlying return types
 
 2. AnyView (Type Erasure)
 Definition:
 AnyView:
 Erases the concrete view type
 Stores views dynamically at runtime
 AnyView(Text("Hello"))
 
 Example (Fixing the Above Error)
 var body: some View {
     if isLoggedIn {
         AnyView(Text("Welcome"))
     } else {
         AnyView(Image(systemName: "person"))
     }
 }
 
 This compiles because:
 Both branches return AnyView
 
 Swift no longer needs to know the concrete type
 
 3. Performance Impact (Very Important)
 some View:
 - Compile-time optimized
 - No runtime cost
 - SwiftUI can diff views efficiently
 
 AnyView:
 - Runtime type checking
 - Breaks SwiftUI diffing optimizations
 - Can hurt animations and scrolling performance
 
 Rule:
 Avoid AnyView inside frequently-updating views (e.g., List, ForEach).
 
 
 4. Real-World SwiftUI Examples
 Example 1: Custom View API (Best Practice)
 struct ProfileRow<Content: View>: View {
     let content: Content

     var body: some View {
         HStack {
             Image(systemName: "person")
             content
         }
     }
 }
 Usage:
 ProfileRow(content: Text("Goutam"))
 ✔ Generic
 ✔ Fast
 ✔ Type-safe
 
 
 Example 2: AnyView in Navigation (Acceptable Use)
 func destinationView() -> AnyView {
     switch route {
     case .home:
         return AnyView(HomeView())
     case .profile:
         return AnyView(ProfileView())
     }
 }
 Why acceptable:
 Navigation destinations change infrequently
 Improves API simplicity
 
 7. Rule of Thumb (Memorize This)
 Default to some View.
 Use AnyView only when return types truly differ and generics are impractical.
 
 8. Interview-Ready Explanation
 “some View is an opaque type that preserves compile-time knowledge of the underlying view, enabling SwiftUI optimizations. AnyView erases type information, allowing flexibility at the cost of performance.”
 */
