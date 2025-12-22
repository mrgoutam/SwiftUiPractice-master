//
//  DependencyInjectionBootcamp.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 22/12/25.
//

/*
 Below is a production-level SwiftUI Dependency Injection example that mirrors how real iOS apps are structured in companies.
 This is not a demo toy—it is an architecture you can scale.

 I will clearly separate layers, responsibilities, and DI boundaries.
 
 Architecture: SwiftUI + MVVM + Protocol-Driven DI
 
 🧱 Architecture Overview (Mental Model Applied)
 
 View
  ↓
 ViewModel (ObservableObject)
  ↓
 UseCase / Service Protocol
  ↓
 Concrete Service (API / DB / Mock)
 
 DI happens only at boundaries, never inside business logic.
 
 1️⃣ Domain Layer (Protocols – Business Rules)
 Auth Use Case Protocol
 */

protocol AuthUseCase {
    func login(
        username: String,
        password: String
    ) async throws -> User
}


// Domain Model
struct User: Identifiable {
    let id: UUID
    let name: String
}

// ✔ No SwiftUI
// ✔ No networking
// ✔ Pure business contract

// 2️⃣ Data Layer (Concrete Implementations)
// Network Service (Production)
final class AuthAPIService: AuthUseCase {

    func login(
        username: String,
        password: String
    ) async throws -> User {

        try await Task.sleep(nanoseconds: 1_500_000_000)

        return User(
            id: UUID(),
            name: "Goutam Das"
        )
    }
}


// Mock Service (Preview / Testing)
final class MockAuthService: AuthUseCase {

    func login(
        username: String,
        password: String
    ) async throws -> User {

        return User(
            id: UUID(),
            name: "Mock User"
        )
    }
}
// ✔ Same protocol
// ✔ Zero changes in View / ViewModel

// 3️⃣ Presentation Layer (ViewModel)
// ViewModel (Business Logic Lives Here)
@MainActor
final class DILoginViewModel: ObservableObject {
    
    // UI State
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?

    // Dependency
    private let authUseCase: AuthUseCase

    // DI via initializer
    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            user = try await authUseCase.login(
                username: username,
                password: password
            )
        } catch {
            errorMessage = "Login failed"
        }

        isLoading = false
    }
}
// ✔ No concrete service knowledge
// ✔ Fully testable
// ✔ Async-await ready

import SwiftUI
internal import Combine

struct DependencyInjectionBootcamp: View {
    @StateObject private var viewModel: DILoginViewModel

        init(viewModel: DILoginViewModel) {
            _viewModel = StateObject(wrappedValue: viewModel)
        }

        var body: some View {
            VStack(spacing: 16) {

                if let user = viewModel.user {
                    Text("Welcome, \(user.name)")
                        .font(.title)
                }

                if viewModel.isLoading {
                    ProgressView()
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                Button("Login") {
                    Task {
                        await viewModel.login(
                            username: "test",
                            password: "1234"
                        )
                    }
                }
            }
            .padding()
        }
}

// ✔ View knows only ViewModel
// ✔ No service creation
// ✔ Clean state rendering

// 5️⃣ Composition Root (MOST IMPORTANT)
// App Entry Point – Where DI Happens

/*
 @main
 struct ProductionDIApp: App {

     var body: some Scene {
         WindowGroup {
             let authService = AuthAPIService()
             let viewModel = DILoginViewModel(
                 authUseCase: authService
             )

             DependencyInjectionBootcamp(viewModel: viewModel)
         }
     }
 }
 */
// ⚠️ This is the ONLY place concrete types are created
// This is called the Composition Root.

#Preview {
    let authService = AuthAPIService()
    let mockService = MockAuthService()
    let viewModel = DILoginViewModel(
        authUseCase: mockService
    )
    DependencyInjectionBootcamp(viewModel: viewModel)
}
