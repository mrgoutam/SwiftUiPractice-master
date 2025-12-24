//
//  State_vs_ObservedObject_vs_StateObject.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 24/12/25.
//

import SwiftUI

struct State_vs_ObservedObject_vs_StateObject: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    State_vs_ObservedObject_vs_StateObject()
}

/*
 @State vs @ObservedObject vs @StateObject
 
 One Problem, Three Tools
 - Who owns the data, and who only observes it?
 Everything depends on this question.
 
 1️⃣ @State — View-Owned, Simple Value
 What It Is:
 -> For simple, local, view-only state
 -> Stored outside the struct
 -> Recreated only once per view identity
 
 Pure Example:
 
 struct CounterView: View {

     @State private var count = 0

     var body: some View {
         VStack {
             Text("Count: \(count)")

             Button("Increment") {
                 count += 1
             }
         }
     }
 }
 
 Mental Model:
 -> View owns the state
 -> State belongs to this view only
 
 Rules:
 Use @State when:
 -> The state is simple (Int, Bool, String)
 -> No sharing needed
 -> No business logic
 
 
 2️⃣ ObservableObject — Shared, Reference-Based State
 Before we compare, define the object.
 
 final class CounterViewModel: ObservableObject {
     @Published var count = 0
 }
 
 This is reference type state.
 
 3️⃣ @ObservedObject — View Observes, Does NOT Own
 
 What It Is:
 -> View depends on an object
 -> View does not control lifecycle
 -> Object is created elsewhere
 
 Example (Important):
 
 struct CounterView: View {

     @ObservedObject var viewModel: CounterViewModel

     var body: some View {
         VStack {
             Text("Count: \(viewModel.count)")

             Button("Increment") {
                 viewModel.count += 1
             }
         }
     }
 }
 
 Used Like This:
 
 CounterView(viewModel: CounterViewModel())
 
 ⚠️ Subtle Problem:
 Every time SwiftUI recreates CounterView,
 CounterViewModel() is created again → state resets.
 
 This is NOT a SwiftUI bug.
 This is incorrect ownership.
 
 4️⃣ @StateObject — View Owns the ObservableObject
 
 What It Is:
 -> View creates and owns the object
 -> Lifecycle tied to view identity
 -> Created once, not on every redraw
 
 Correct Example:
 
 struct CounterView: View {

     @StateObject private var viewModel = CounterViewModel()

     var body: some View {
         VStack {
             Text("Count: \(viewModel.count)")

             Button("Increment") {
                 viewModel.count += 1
             }
         }
     }
 }
 
 Mental Model:
 View owns the reference
 SwiftUI preserves it
 
 6️⃣ Parent → Child (Correct Pattern)
 
 Parent (Owner):
 
 struct ParentView: View {

     @StateObject private var viewModel = CounterViewModel()

     var body: some View {
         ChildView(viewModel: viewModel)
     }
 }
 
 Child (Observer):
 
 struct ChildView: View {

     @ObservedObject var viewModel: CounterViewModel

     var body: some View {
         Text("Count: \(viewModel.count)")
     }
 }
 
 This is production-correct SwiftUI.
 
 7️⃣ Comparison Table (Lock This In):
 
 | Property Wrapper  | Ownership | Lifetime      | Use Case                |
 | ----------------- | --------- | ------------- | ----------------------- |
 | `@State`          | View      | View lifetime | Simple local state      |
 | `@StateObject`    | View      | Stable        | Create ObservableObject |
 | `@ObservedObject` | External  | External      | Observe passed object   |

 8️⃣ Common Mistakes (Very Important)
 ❌ Using @ObservedObject to Create State
 
 @ObservedObject var vm = ViewModel() // WRONG
 
 This recreates the object repeatedly.
 
 ❌ Using @StateObject in Child Views
 
 struct ChildView {
     @StateObject var vm: ViewModel // WRONG
 }
 
 Now the child claims ownership it should not have.
 
 9️⃣ How SwiftUI Thinks (Internal Perspective)
 -> Views are temporary
 -> State must live outside the struct
 -> SwiftUI tracks ownership through wrappers
 
 Once you understand this, SwiftUI becomes predictable.
 
 🔟 Final Mental Model (Memorize This):
 
 @State        → simple, local
 @StateObject  → create & own
 @ObservedObject → receive & observe
 */
