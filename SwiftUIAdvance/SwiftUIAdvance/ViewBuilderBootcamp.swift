//
//  ViewBuilderBootcamp.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 19/12/25.
//

import SwiftUI

struct ViewBuilderBootcamp: View {
    var body: some View {
        VStack {
            HeaderViewRegular(title: "Regular Title", description: "Hello", icon: nil)
            
            HeaderViewRegular(title: "Empty Description Title", description: nil, icon: "heart.fill")
            
            //HeaderViewGeneric(title: "Generic Header", content: Text("Content"))
            
            //HeaderViewGeneric(title: "Generic Header", content: Image(systemName: "person.fill"))
            
            HeaderViewGeneric(title: "Generic Header") {
                Text("View Builder Style Content")
            }
            
            Spacer()
        }
    }
}

struct HeaderViewRegular: View {
    let title: String
    let description: String?
    let icon: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            if let description = description {
                Text(description)
                    .font(.callout)
            }
            
            if let icon = icon {
                Image(systemName: icon)
            }
            
            RoundedRectangle(cornerRadius: 5)
                .frame(height: 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

struct HeaderViewGeneric<Content: View>: View {
    let title: String
    let content: Content
    
    /*
     init(title: String, content: Content) {
         self.title = title
         self.content = content
     }
     */
    
    init(title: String, @ViewBuilder content:()->Content){
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            content
            
            RoundedRectangle(cornerRadius: 5)
                .frame(height: 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

#Preview {
    ViewBuilderBootcamp()
}


/*
 1. @ViewBuilder lets you write multiple View statements where Swift expects one View.
 
 2. Why It Exists:
 Normally, a function can return only one value:
 func makeView() -> View { ... } // ❌ impossible
 
 @ViewBuilder solves this by:
 - Collecting multiple Views
 - Combining them into a single generic type (often a tuple)
 
 3. Basic Example:
 Without @ViewBuilder (❌)
 
 func content() -> some View {
     Text("Hello")
     Text("World") // Error ❌
 }
 
 With @ViewBuilder (✅)
 @ViewBuilder
 func content() -> some View {
     Text("Hello")
     Text("World")
 }
 
 SwiftUI combines these into a single composite view.
 
 4. Where SwiftUI Uses @ViewBuilder Automatically
 You usually do not write it yourself in these cases:
 
 VStack {
     Text("A")
     Text("B")
 }
 Reason:
  VStack initializer already has @ViewBuilder
  init(@ViewBuilder content: () -> Content)
 
 5. Conditional Views (Most Common Use Case)
 @ViewBuilder
 var statusView: some View {
     if isLoading {
         ProgressView()
     } else {
         Text("Loaded")
     }
 }
 Without @ViewBuilder, this would fail due to different return types.
 
 6. @ViewBuilder vs some View
   Concept            Purpose
 - some View          Hides concrete return type
 - @ViewBuilder       Builds a return type from multiple views
 
 7. @ViewBuilder in Custom Components (Best Practice)
 struct Card<Content: View>: View {
     let content: Content

     init(@ViewBuilder content: () -> Content) {
         self.content = content()
     }

     var body: some View {
         RoundedRectangle(cornerRadius: 12)
             .overlay(content)
     }
 }
 
 Usage:
 Card {
     Text("Title")
     Divider()
     Text("Description")
 }
 
 8. How It Works Internally (Conceptual)
 
 Text("A")
 Text("B")
 
 Becomes (conceptually):
 TupleView<(Text, Text)>
 
 SwiftUI then renders this composite view.
 
 9. Limitations You Must Know
 => Maximum 10 Views
 - A single @ViewBuilder block supports up to 10 direct child views
 - More than that causes compile-time errors
 
 Solution:
 - Group using Group { }
 - Extract subviews
 
 10. Rule:
 Prefer @ViewBuilder over AnyView whenever possible.
 
 12. Common Mistakes (Avoid These)
 - Using AnyView instead of @ViewBuilder
 - Writing heavy logic inside builder blocks
 - Exceeding child view limits
 
 13. Mental Model
 - @ViewBuilder = compile-time view composer
 - Produces one concrete view type
 - Zero runtime cost
 */
