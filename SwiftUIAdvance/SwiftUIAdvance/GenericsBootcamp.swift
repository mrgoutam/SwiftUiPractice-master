//
//  GenericsBootcamp.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 18/12/25.
//

import SwiftUI
internal import Combine

struct StringModel {
    let info: String?
    func removeInfo() -> StringModel {
        StringModel(info: nil)
    }
}
struct BoolModel {
    let info: Bool?
    func removeInfo() -> BoolModel {
        BoolModel(info: nil)
    }
}
struct GenericModel<T> {
    let info: T?
    func removeInfo() -> GenericModel {
        GenericModel(info: nil)
    }
}

class GenericsViewModel: ObservableObject {
    
    @Published var stringModel = StringModel(info: "Hello, world!")
    @Published var boolModel = BoolModel(info: true)
    
    @Published var genericStringModel = GenericModel(info: "Hello, world!")
    @Published var genericBoolModel = GenericModel(info: true)
    
    func removeData() {
        stringModel = stringModel.removeInfo()
        boolModel = boolModel.removeInfo()
        genericStringModel = genericStringModel.removeInfo()
        genericBoolModel = genericBoolModel.removeInfo()
    }
    
}

struct GenericView<T:View> : View {
    
    let content: T
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
            content
        }
    }
    
}

struct GenericsBootcamp: View {
    
    @StateObject private var vm = GenericsViewModel()
    
    var body: some View {
        VStack {
            GenericView(content: Text("custom content"), title: "new view!")
            //GenericView(title: "New view!")
            
            Text(vm.stringModel.info ?? "no data")
            Text(vm.boolModel.info?.description ?? "no data")
            Text(vm.genericStringModel.info ?? "no data")
            Text(vm.genericBoolModel.info?.description ?? "no data")
        }
        .onTapGesture {
            vm.removeData()
        }

    }
}

#Preview {
    GenericsBootcamp()
}


/*
 What Generics Are
 Generics allow you to write type-safe, reusable code that works with any type, while still preserving compile-time guarantees.
 
 In simple terms:
 Generics let you write code once and use it with many types—without losing type safety.
 
 Why Generics Matter in SwiftUI
 SwiftUI is built on generics. Almost every SwiftUI concept relies on them:
 - View protocol
 - some View
 - NavigationStack
 - ForEach
 - ViewBuilder
 If you understand generics, SwiftUI stops feeling “magical” and becomes predictable.
 
 Generic Types (Struct / Class)
 struct Box<T> {
     let value: T
 }
 
 Usage:
 let intBox = Box(value: 10)
 let stringBox = Box(value: "Swift")
 
 Example:
 struct CardView<Content: View>: View {
     let content: Content

     init(@ViewBuilder content: () -> Content) {
         self.content = content()
     }

     var body: some View {
         RoundedRectangle(cornerRadius: 12)
             .fill(Color.white)
             .overlay(content)
     }
 }
 
 Usage:
 CardView {
     Text("Hello")
     Image(systemName: "star")
 }
 */
