//
//  BingingBootcamp.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 24/12/25.
//


/*
 @Binding is small in syntax but huge in meaning.
 
 Once you understand this, SwiftUI stops feeling “magical”.
 
 We will go pure → practical → rules.
 
 @Binding — Two-Way Data Flow in SwiftUI:
 
 1️⃣ The Problem @Binding Solves:
 
 SwiftUI enforces this rule:
 - A view should not own state it does not create.
 
 But sometimes:
 A child view needs to read and modify a parent’s state
 
 How do we do that without copying or owning it?
 That is exactly what @Binding solves.
 
 2️⃣ Mental Model (Critical)
 @Binding = A reference to someone else’s state
 -> No ownership
 -> No storage
 -> Just a connection
 
 Think of it as:
 -> Parent owns state
 -> Child gets a handle
 
 3️⃣ Pure Example (Minimal)
 */

import SwiftUI

struct BingingBootcamp: View {
    @State private var isOn = false
    
    var body: some View {
        VStack {
            Toggle("Parent Toggle", isOn: $isOn)
            ChildView(isOn: $isOn)
        }
    }
}

struct ChildView: View {

    @Binding var isOn: Bool

    var body: some View {
        Button(isOn ? "Turn Off" : "Turn On") {
            isOn.toggle()
        }
    }
}

#Preview {
    BingingBootcamp()
}

/*
 4️⃣ What Is Actually Happening
 
 $isOn
 
 This means:
 -> “Give me a binding to isOn”
 -> Not the value
 -> The connection
 
 So:
 -> Parent owns the storage
 -> Child mutates through binding
 -> SwiftUI handles updates
 
 5️⃣ Why Not Pass Bool Directly?
 ❌ This Fails Conceptually
 
 struct ChildView {
     var isOn: Bool
 }
 
 Child gets:
 -> A copy
 -> No mutation allowed
 -> This breaks unidirectional data flow.
 
 6️⃣ Binding With ObservableObject
 */

internal import Combine

final class SettingsViewModel: ObservableObject {
    @Published var isEnabled = false
}

private struct ChildView2: View {
    @Binding var isOn: Bool
    var body : some View {
        Button(isOn ? "Turn Off" : "Turn On") {
            isOn.toggle()
        }
    }
}

private struct ParentView2: View {

    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        ChildView2(isOn: $viewModel.isEnabled)
    }
}

#Preview{
    ParentView2()
}

/*
 7️⃣ $ — The Most Misunderstood Symbol
 
 | Expression | Meaning          |
 | ---------- | ---------------- |
 | `value`    | Current value    |
 | `$value`   | Binding to value |

 
 Think:
 value  → read
 $value → read + write
 
 8️⃣ When to Use @Binding (Rules)
 Use @Binding When:
 -> Child needs to modify parent state
 -> State is owned elsewhere
 -> You want two-way flow
 
 Do NOT Use @Binding When:
 -> Child only reads
 -> State belongs to child
 -> Data is global (use EnvironmentObject)
 
 9️⃣ Binding vs EnvironmentObject (Important):
 
 | Feature    | Binding                | EnvironmentObject  |
 | ---------- | ---------------------- | ------------------ |
 | Scope      | Local (parent → child) | Global (tree-wide) |
 | Ownership  | Parent                 | App                |
 | Mutability | Yes                    | Yes                |
 | Explicit   | Yes                    | Implicit           |

 Rule:
 Prefer @Binding for local communication.
 
 🔟 Custom Bindings (Advanced but Useful)
 
 let binding = Binding<Bool>(
     get: { viewModel.isEnabled },
     set: { viewModel.isEnabled = $0 }
 )
 
 Used when:
 -> You need transformation
 -> You don’t have direct $property
 
 1️⃣1️⃣ Common Mistakes (Very Important)
 ❌ Using @Binding Without Source
 
 @Binding var value: Bool // but not passed → crash
 Bindings must always have a source.
 
 ❌ Using Binding Instead of State
 
 struct View {
     @Binding var count: Int // WRONG if view owns it
 }
 
 If you own it → use @State.
 
 1️⃣2️⃣ Final Mental Model (Lock This)
 @State      → owns
 @Binding    → borrows
 @ObservedObject → observes
 @StateObject → owns reference
 */
