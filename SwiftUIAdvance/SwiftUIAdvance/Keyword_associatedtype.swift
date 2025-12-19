//
//  Keyword_associatedtype.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 19/12/25.
//

import SwiftUI

struct Keyword_associatedtype: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    Keyword_associatedtype()
}

/*
 associatedtype (Swift & SwiftUI):
 associatedtype is one of the most important but least understood concepts in Swift—especially in SwiftUI. Once this is clear, many “why SwiftUI works this way” questions disappear.
 
 1. What associatedtype Is
 associatedtype defines a placeholder type inside a protocol.
 
 In plain language:
 A protocol can say “I need a type, but I will not decide what it is. The conforming type will.”
 
 2. Simple Example (Non-SwiftUI)
 protocol Container {
     associatedtype Item
     var items: [Item] { get }
 }
 
 Conforming type:
 
 struct IntContainer: Container {
     var items: [Int]
 }
 
 Here:
 -> Item → Int
 -> The protocol stays generic
 -> The conforming type decides the actual type
 
 3. Why associatedtype Exists
 Without associatedtype, protocols would be very limited:
 -> You could not express relationships between types
 -> You could not model generic behavior
 SwiftUI, Combine, and the Standard Library rely heavily on this.
 
 4. Critical SwiftUI Example: View
 
 protocol View {
     associatedtype Body: View
     @ViewBuilder var body: Self.Body { get }
 }
 
 This explains everything:
 Key implications
 -> Every View has a unique Body type
 -> View cannot be used as a concrete type
 -> some View is required
 
 5. Why You Cannot Write This
 let view: View = Text("Hello") // ❌
 
 Reason:
 -> View has an associatedtype
 -> The compiler does not know what Body is
 
 Protocols with associatedtype are not usable as types.
 
 6. How some View Solves This
 var body: some View {
     Text("Hello")
 }
 
 -> Compiler knows the concrete type
 -> Caller does not
 -> The Body associated type is satisfied
 
 8. Associated Type vs Generics (Very Important)
 Protocol with associatedtype
 protocol Repository {
     associatedtype Model
     func save(_ model: Model)
 }
 Generic constraint usage
 func persist<R: Repository>(_ repo: R, model: R.Model) {
     repo.save(model)
 }
 Key insight:
 Associated types become usable only through generics.
 
 9. SwiftUI Example: Custom Protocol
 protocol Screen {
     associatedtype Content: View
     @ViewBuilder func render() -> Content
 }
 Usage:
 struct HomeScreen: Screen {
     func render() -> some View {
         Text("Home")
     }
 }
 
 11. Interview-Level Explanation
 “associatedtype allows protocols to define placeholder types that are resolved by conforming types. SwiftUI’s View protocol relies on this to represent unique view hierarchies, which is why opaque types like some View are required.”
 
 12. Mental Model (Memorize This)
 -> associatedtype = protocol-level generic
 -> Protocols with associatedtype ≠ concrete types
 -> Use generics to access associated types
 -> Use type erasure only when necessary
 
 14. Why SwiftUI Is Designed This Way
 SwiftUI prioritizes:
 ->Compile-time correctness
 ->Performance
 ->Predictable UI diffing
 associatedtype makes this possible.
 */
