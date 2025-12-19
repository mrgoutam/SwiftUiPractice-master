//
//  PreferenceKeyBootcamp.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 19/12/25.
//

import SwiftUI

/*
 Full Working Example: Child Height → Parent Layout Adjustment
 Use Case
 -> Multiple child views report their dynamic heights
 -> Parent calculates the maximum height
 -> Parent uses that value to adjust layout
 
 This pattern is widely used for:
 -> Custom tab bars
 -> Equal-height cards
 -> Sticky headers
 -> Dynamic toolbars
 */

/*
 What Happens Step-by-Step (Critical Understanding)
 
 1. Each ItemCardView measures its height
 2. Each child emits a preference value
 3. reduce combines values → max height
 4. Parent receives final value via .onPreferenceChange
 5. Parent updates its state
 6. All children re-render with equal height
 */
struct PreferenceKeyBootcamp: View {
    @State private var maxHeight: CGFloat = 0

        let items = [
            "Short text",
            "This is a bit longer text",
            "This is a much longer piece of text that will definitely wrap into multiple lines"
        ]

        var body: some View {
            VStack(spacing: 20) {

                Text("Max Child Height: \(Int(maxHeight))")
                    .font(.headline)

                HStack(alignment: .top, spacing: 12) {
                    ForEach(items, id: \.self) { item in
                        ItemCardView(text: item)
                            .frame(height: maxHeight)
                    }
                }
            }
            .padding()
            .onPreferenceChange(MaxHeightPreferenceKey.self) { value in
                maxHeight = value
            }
        }
}


/*
 Important Notes:
 -> GeometryReader measures size
 -> Color.clear avoids layout interference
 -> .preference(...) sends value up
 */
struct ItemCardView: View {

    let text: String

    var body: some View {
        Text(text)
            .padding()
            .background(Color.blue.opacity(0.2))
            .cornerRadius(10)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: MaxHeightPreferenceKey.self,
                            value: geo.size.height*2
                        )
                }
            )
    }
}


/*
 What this does:
 -> Each child reports its height
 -> Parent receives the maximum height
 */
struct MaxHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    PreferenceKeyBootcamp()
}


/*
 PreferenceKey (SwiftUI)
 
 PreferenceKey is an advanced SwiftUI mechanism used to pass data up the view hierarchy—the exact opposite of normal data flow.
 
 In short:
 PreferenceKey allows child views to communicate information to their ancestors.
 This is essential for building custom containers, layouts, and coordinated UI behavior.
 
 1. Why PreferenceKey Exists
 Normal SwiftUI data flow:
 
 Parent → Child (@State, @Binding, @Environment)
 
 But sometimes the parent needs to know:
 -> Child size
 -> Scroll position
 -> Tab selection
 -> Geometry information
 -> Children cannot directly modify parent state.
 PreferenceKey solves this.
 
 2. What a PreferenceKey Is
 A PreferenceKey is:
 -> A type-safe key
 -> Used to collect values from multiple child views
 -> Reduced into a single value for the parent
 
 3. Basic Structure
 
 struct HeightPreferenceKey: PreferenceKey {
     static var defaultValue: CGFloat = 0

     static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
         value = max(value, nextValue())
     }
 }
 
 Important parts:
 | Part           | Purpose                      |
 | -------------- | ---------------------------- |
 | `defaultValue` | Initial value                |
 | `reduce`       | Combine values from children |

 4. Minimal Working Example (Child → Parent)
 Step 1: Define the PreferenceKey
 
 struct ViewHeightKey: PreferenceKey {
     static var defaultValue: CGFloat = 0

     static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
         value = nextValue()
     }
 }

 Step 2: Child sets the preference
 Text("Hello SwiftUI")
     .background(
         GeometryReader { geo in
             Color.clear
                 .preference(key: ViewHeightKey.self,
                             value: geo.size.height)
         }
     )
 
 Step 3: Parent reads the preference
 @State private var height: CGFloat = 0

 VStack {
     Text("Measured height: \(height)")
     ChildView()
 }
 .onPreferenceChange(ViewHeightKey.self) { value in
     height = value
 }
 
 5. Why reduce Is Important
 Multiple child views may emit the same preference.
 
 Example:
 ForEach(items) { item in
     ItemView(item)
 }
 
 Each ItemView sets a preference.
 reduce decides:
 -> Max?
 -> Min?
 -> Sum?
 -> Append to array?
 
 6. Common Real-World SwiftUI Use Cases
 => 1. Custom Tab Bar (You already touched this)
 - Child tab reports its item
 - Parent aggregates all tab items
 
 7. PreferenceKey vs @Environment:
 
 | Feature        | PreferenceKey    | Environment    |
 | -------------- | ---------------- | -------------- |
 | Data direction | Child → Parent   | Parent → Child |
 | Use case       | Layout, geometry | Config & state |
 | Type safety    | Strong           | Strong         |
 | Frequency      | Low              | High           |

 8. Performance Considerations
 Preferences trigger view updates
 Avoid emitting preferences in fast-updating views (e.g., animations)
 Keep values small and simple
 
 9. Common Mistakes (Very Common)
 ❌ Forgetting reduce
 SwiftUI will not know how to merge values.
 
 ❌ Using PreferenceKey for business logic
 This is a layout communication tool, not state management.
 	
 ❌ Emitting preferences from deep List rows
 Can cause performance issues.
 
 10. Mental Model (Memorize This)
 -> Preferences flow up
 -> Environment flows down
 -> State flows down
 -> Binding flows both ways
 
 11. Interview-Ready Explanation
 “PreferenceKey is a SwiftUI mechanism that allows child views to pass data up the view hierarchy, commonly used for geometry, layout coordination, and building custom container views.”
 
 12. When NOT to Use PreferenceKey
 -> App-wide state
 -> Business logic
 -> Simple parent-child communication
 
 Use:
 -> @Binding
 -> @StateObject
 -> @EnvironmentObject
 */
