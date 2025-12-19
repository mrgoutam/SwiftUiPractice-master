//
//  ProtocolBootcamp.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 19/12/25.
//

import SwiftUI
internal import Combine

/*
 Full SwiftUI Protocol Example
 Use Case: Login Screen with Protocol-Based ViewModel
 This pattern is very common in professional SwiftUI apps.
 1. Define the Protocol (Contract)
 */

protocol LoginViewModelProtocol: ObservableObject {
    var isLoading: Bool { get }
    var statusText: String { get }
    func login()
}
/*
 What this protocol guarantees
 -> Any conforming ViewModel:
 -> Can be observed by SwiftUI
 -> Exposes UI state
 -> Implements login()
 */

//2. Real ViewModel (Production Implementation)
final class LoginViewModel: LoginViewModelProtocol {
    @Published var isLoading: Bool = false
    @Published var statusText: String = "Not Logged In"

    func login() {
        isLoading = true
        statusText = "Logging in..."

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.statusText = "Login Successful"
        }
    }
}

//3. Mock ViewModel (For Preview & Testing)
final class MockLoginViewModel: LoginViewModelProtocol {

    @Published var isLoading: Bool = false
    @Published var statusText: String = "Mock Mode"

    func login() {
        statusText = "Mock Login Triggered"
    }
}
/*
 ✔ Same protocol
 ✔ No code duplication
 ✔ Swap implementations easily
 
 
 4. SwiftUI View Using Protocol (Generic Injection)
 */
struct LoginView<VM: LoginViewModelProtocol>: View {

    @StateObject var viewModel: VM

    var body: some View {
        VStack(spacing: 20) {

            Text(viewModel.statusText)
                .font(.headline)

            if viewModel.isLoading {
                ProgressView()
            }

            Button("Login") {
                viewModel.login()
            }
        }
        .padding()
    }
}

/*
 Why Generics Are Required
 -> LoginViewModelProtocol has ObservableObject
 -> Protocols with associated types cannot be used directly
 -> Generic constraint solves this cleanly
 
 5. App Entry Point
 */

/*
 @main
 struct ProtocolExampleApp: App {
     var body: some Scene {
         WindowGroup {
             LoginView(viewModel: LoginViewModel())
         }
     }
 }
 */

//6. SwiftUI Preview with Mock (Huge Benefit)
#Preview {
    LoginView(viewModel: MockLoginViewModel())
}

/*
 This is exactly how professionals use protocols in SwiftUI.
 7. What You Gained from This Pattern
 ✔ Loose coupling
 ✔ Easy testing
 ✔ Preview-friendly
 ✔ No inheritance
 ✔ Strong compile-time safety
 8. Why NOT Use This (Anti-Pattern)
 ❌
@StateObject var viewModel: LoginViewModel
Problems:
Tightly coupled
Hard to test
No mocking
Harder to refactor
 */

/*
 Protocols in SwiftUI (Practical, Not Abstract):
 Protocols are contracts that define what a type must do, not how it does it.
 SwiftUI relies heavily on protocols to achieve declarative UI, composition, and type safety.
 
 1. Why Protocols Matter in SwiftUI
 SwiftUI is built on:
 -> View
 -> ObservableObject
 -> PreferenceKey
 -> Shape
 -> ButtonStyle
 -> ViewModifier
 All of these are protocols.
 Understanding protocols = understanding SwiftUI architecture.
 
 2. The Most Important SwiftUI Protocol: View
 protocol View {
     associatedtype Body: View
     @ViewBuilder var body: Body { get }
 }
 Key takeaways
 -> Every SwiftUI screen is a View
 -> Body is an associatedtype
 -> This is why:
    => You cannot write let v: View
    => You must use some View
 
 3. Basic Custom Protocol (SwiftUI-Friendly)
 
 Example: Screen Contract
 protocol Screen {
     var title: String { get }
 }
 
 Usage:
 struct HomeView: View, Screen {
     let title = "Home"

     var body: some View {
         Text(title)
     }
 }
 
 Protocols allow behavior sharing without inheritance.
 
 4. Protocol + associatedtype (Very Common in SwiftUI)
 
 protocol ScreenRenderable {
     associatedtype Content: View
     @ViewBuilder func render() -> Content
 }
 
 Conformance:
 struct ProfileScreen: ScreenRenderable {
     func render() -> some View {
         VStack {
             Text("Profile")
             Image(systemName: "person")
         }
     }
 }
 
 This pattern is common in:
 -> Navigation systems
 -> Flow coordinators
 -> Custom UI frameworks
 
 5. Protocols You Use Daily (Often Without Realizing)
 ObservableObject
 protocol ObservableObject: AnyObject {
     var objectWillChange: ObjectWillChangePublisher { get }
 }
 
 Usage:
 class LoginViewModel: ObservableObject {
     @Published var isLoggedIn = false
 }
 
 This enables automatic UI updates.
 
 PreferenceKey (You already learned)
 protocol PreferenceKey {
     associatedtype Value
     static var defaultValue: Value { get }
     static func reduce(value: inout Value, nextValue: () -> Value)
 }
 
 6. Protocols for Styling (Very Powerful)
 ViewModifier
 protocol ViewModifier {
     associatedtype Body: View
     func body(content: Content) -> Body
 }
 Custom modifier:
 struct CardStyle: ViewModifier {
     func body(content: Content) -> some View {
         content
             .padding()
             .background(Color.white)
             .cornerRadius(12)
             .shadow(radius: 4)
     }
 }
 Usage:
 Text("Hello")
     .modifier(CardStyle())
 ButtonStyle
 struct PrimaryButtonStyle: ButtonStyle {
     func makeBody(configuration: Configuration) -> some View {
         configuration.label
             .padding()
             .background(Color.blue)
             .foregroundColor(.white)
             .scaleEffect(configuration.isPressed ? 0.95 : 1)
     }
 }
 Usage:
 Button("Submit") { }
     .buttonStyle(PrimaryButtonStyle())
 
 7. Protocol-Oriented SwiftUI Architecture
 ViewModel Protocol
 protocol LoginViewModelProtocol: ObservableObject {
     var isLoading: Bool { get }
     func login()
 }
 
 Usage:
 struct LoginView<VM: LoginViewModelProtocol>: View {
     @StateObject var viewModel: VM

     var body: some View {
         ProgressView()
             .opacity(viewModel.isLoading ? 1 : 0)
     }
 }
 
 ✔ Testable
 ✔ Mockable
 ✔ Clean architecture
 
 8. Protocol vs Inheritance (SwiftUI Rule)

 | Feature              | Protocol  | Inheritance |
 | -------------------- | --------- | ----------- |
 | Multiple conformance | ✅         | ❌           |
 | Works with structs   | ✅         | ❌           |
 | SwiftUI-friendly     | ✅         | ❌           |
 | Performance          | Excellent | Slower      |

 9. Common Protocol Errors in SwiftUI
 ❌ “Protocol can only be used as a generic constraint”
 
 Cause:
 -> Protocol has associatedtype
 
 
 Fix:
 
 -> Use generics
 -> Or apply type erasure (AnyView, AnyPublisher)
 
 10. Interview-Ready Explanation
 “SwiftUI heavily relies on protocols with associated types to describe view behavior and data flow. Protocols enable composition, testability, and compile-time safety without inheritance.”
 11. Mental Model (Very Important)
 Protocol = capability
 Struct + Protocol = composition
 associatedtype = protocol-level generic
 SwiftUI = protocol-oriented framework
 
 */
