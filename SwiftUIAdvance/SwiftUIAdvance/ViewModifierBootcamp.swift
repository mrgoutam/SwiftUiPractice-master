//
//  ViewModifierBootcamp.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 18/12/25.
//

import SwiftUI

struct ViewModifierBootcamp: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .modifier(TextViewModifier(backgroundColor: .pink)) // method I
            
            Text("Hello, Everyone!")
                .withDefaultTextButtonStyle() // method - II
            
            Text("Hello!")
                .modifier(TextViewModifier(backgroundColor: .brown))
        }
    }
}

struct TextViewModifier: ViewModifier {
    let backgroundColor: Color
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundStyle(.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(10)
            .padding()
    }
}

extension View {
    func withDefaultTextButtonStyle(bgColor: Color = .blue) -> some View {
        self
            .modifier(TextViewModifier(backgroundColor: bgColor))
    }
}

#Preview {
    ViewModifierBootcamp()
}
