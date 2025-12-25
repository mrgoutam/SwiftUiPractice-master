//
//  View_Identity_&_Lifecycle.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 25/12/25.
//


/*
 View identity & lifecycle is the concept that makes everything you learned so far click into place.
 Once you understand this, SwiftUI stops feeling random.
 
 View Identity & Lifecycle (SwiftUI Core Concept):
 
 1️⃣ The Most Important Truth (Memorize This)
 SwiftUI views do not have a traditional lifecycle.
 They are value descriptions, not objects.
 
 If you treat SwiftUI views like UIKit view controllers, you will struggle.
 
 2️⃣ What a SwiftUI View Actually Is
 
 struct MyView: View {
     var body: some View {
         Text("Hello")
     }
 }
 
 This is:
 -> A value
 -> A temporary description
 -> Cheap to create
 -> Recreated frequently
 
 SwiftUI does not care if this struct is recreated.
 
 3️⃣ Then What Does SwiftUI Preserve?
 SwiftUI preserves identity, not the struct instance.
 
 Identity is defined by:
 -> Position in the view hierarchy
 -> Type
 -> Explicit id()
 
 4️⃣ Why Views Are Recreated So Often
 Whenever:
 -> State changes
 -> Binding changes
 -> Environment changes
 
 SwiftUI:
 -> Recreates the view struct
 -> Recomputes body
 -> Diffs the result
 -> Updates UI
 
 This is intentional and fast.
 
 
 5️⃣ View Identity Example (Very Important)
 Problematic Code
*/

import SwiftUI

struct ParentView: View {

    @State private var show = false

    var body: some View {
        VStack {
            Button("Toggle") {
                show.toggle()
            }

            if show {
                ChildView3()
            }
        }
    }
}

struct ChildView3: View {
    @State private var count = 0

    var body: some View {
        Button("Count: \(count)") {
            count += 1
        }
    }
}

#Preview {
    ParentView()
}

/*
 What Happens?
 -> Toggle show OFF → ChildView removed
 -> Toggle show ON → New ChildView created
 -> count resets to 0
 
 This is correct behavior.
 
 6️⃣ Identity Is Not Memory
 Do NOT think:
 “SwiftUI destroyed my view”
 
 Think:
 “SwiftUI lost identity, so state reset”
 
 7️⃣ How to Preserve Identity
 Option 1: Keep the View Alive
 
 .opacity(show ? 1 : 0)
 
 Identity remains → state preserved
 
 Option 2: Move State Up
 
 struct ParentView: View {
     @State private var count = 0
 }
 
 Pass via @Binding
 
 Option 3: Explicit id
 
 ChildView()
     .id("child")
 
 This forces identity consistency.
 
 8️⃣ Lists & ForEach (Critical)
 Wrong:
 ForEach(items) { item in
     RowView(item: item)
 }
 If item.id is unstable → bugs.
 
 Correct:
 ForEach(items, id: \.id) { item in
     RowView(item: item)
 }
 
 Identity must be:
 -> Stable
 -> Unique
 -> Predictable
 
 9️⃣ View Lifecycle Hooks (What Exists)
 SwiftUI does NOT have:
 -> viewDidLoad
 -> viewWillAppear
 
 Instead:
 | Modifier       | Purpose                      |
 | -------------- | ---------------------------- |
 | `.onAppear`    | View enters hierarchy        |
 | `.onDisappear` | View leaves hierarchy        |
 | `.task`        | Async work tied to lifecycle |

 Important:
 These are signals, not ownership points.
 
 🔟 State Wrappers Depend on Identity
 | Wrapper           | Identity Sensitive |
 | ----------------- | ------------------ |
 | `@State`          | Yes                |
 | `@StateObject`    | Yes                |
 | `@ObservedObject` | No                 |
 | `@Binding`        | No                 |

 This explains many bugs.
 
 1️⃣1️⃣ Common Bugs Explained
 ❌ “My state keeps resetting”
 → Identity lost
 
 ❌ “@StateObject reinitializes”
 → View identity changed
 
 ❌ “List rows behave strangely”
 → Unstable IDs
 
 1️⃣2️⃣ Professional Mental Model
 Views are descriptions
 Identity anchors state
 State lives outside structs
 SwiftUI reconciles trees

 1️⃣3️⃣ One-Sentence Rule (Very Important)
 If a view disappears from the hierarchy, its local state is gone unless identity is preserved.
 */
