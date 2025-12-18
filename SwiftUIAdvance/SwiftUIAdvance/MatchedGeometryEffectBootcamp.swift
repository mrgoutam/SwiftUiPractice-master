//
//  MatchedGeometryEffectBootcamp.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 18/12/25.
//

import SwiftUI

struct MatchedGeometryEffectBootcamp: View {
    @State private var isClicked: Bool = false
    @Namespace private var namespace
    var body: some View {
        VStack {
            if !isClicked{
                Circle()
                    .matchedGeometryEffect(id: "rectangle", in: namespace)
                    .frame(width: 100, height: 100)
            }
            
            Spacer()
            
            if isClicked{
                RoundedRectangle(cornerRadius: 25)
                    .matchedGeometryEffect(id: "rectangle", in: namespace)
                    .frame(width: 300, height: 200)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.red)
        .onTapGesture {
            withAnimation(.easeInOut) {
                isClicked.toggle()
            }
        }
    }
}

#Preview {
    MatchedGeometryEffectBootcamp()
}

/*
 What it is
 matchedGeometryEffect is a SwiftUI animation API that allows two (or more) views in different parts of the view hierarchy to be animated as if they are the same view transitioning between layouts.
 
 Why it exists
 Normally, SwiftUI animates within the same view tree. When a view disappears and another appears elsewhere, SwiftUI treats them as unrelated.
 
 matchedGeometryEffect tells SwiftUI:
 “These views represent the same logical element—animate geometry between them.”
 
 Core Requirements (Very Important):
 
 1. Shared Namespace
 Both views must reference the same namespace.
 
 @Namespace private var animation
 
 2. Same id
 The id must be identical for SwiftUI to match geometry.
 
 .matchedGeometryEffect(id: "profileImage", in: animation)
 
 3. Conditional Rendering
 Typically used with if / else or navigation state.
 
 Key Parameters
 .matchedGeometryEffect(
     id: String,
     in: Namespace.ID,
     properties: .frame,   // default
     anchor: .center,
     isSource: Bool?       // optional
 )
 
 properties
 .frame (most common)
 .position
 .size
 isSource
 Use when multiple views share the same id to avoid ambiguity.
 */
