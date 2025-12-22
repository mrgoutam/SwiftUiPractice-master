#  Dependency Injection Note

Dependency Injection (DI) in SwiftUI — Complete, Practical Guide
Dependency Injection is a core architectural concept for building testable, scalable, and maintainable SwiftUI apps. SwiftUI already encourages DI through value types and initializer-based design.

1. What Dependency Injection Is
Dependency Injection is the practice of providing an object’s dependencies from the outside instead of creating them internally.

❌ Without DI (Tightly Coupled)
class LoginViewModel: ObservableObject {
    let service = AuthService()   // hard dependency
}

Problems:
- Not testable
- Not replaceable
- Hard to mock

✅ With DI (Loosely Coupled)
class LoginViewModel: ObservableObject {
    let service: AuthServiceProtocol

    init(service: AuthServiceProtocol) {
        self.service = service
    }
}


2. Why DI Is Critical in SwiftUI
SwiftUI apps benefit from DI because:
- Views are structs
- State is injected (@StateObject, @EnvironmentObject)
- Previews need mocks
- Unit testing is expected

3. Core DI Techniques in SwiftUI
1️⃣ Constructor (Initializer) Injection — Preferred
struct LoginView<VM: LoginViewModelProtocol>: View {
    @StateObject var viewModel: VM
}
✔ Compile-time safety
✔ Clear dependencies
✔ Best for most cases


2️⃣ Environment Injection (@EnvironmentObject)
@EnvironmentObject var session: AppSession

Use when:
- Dependency is app-wide
- Many views need it

Avoid for:
- Feature-level services
- Replaceable logic

4. Full Real-World DI Example (End-to-End)
Use Case: Login Flow with Service Injection

Step 1: Service Protocol
protocol AuthServiceProtocol {
    func login(completion: @escaping (Bool) -> Void)
}

Step 2: Real Service
final class AuthService: AuthServiceProtocol {
    func login(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(true)
        }
    }
}

Step 3: Mock Service (Testing & Preview)
final class MockAuthService: AuthServiceProtocol {
    func login(completion: @escaping (Bool) -> Void) {
        completion(false)
    }
}

Step 4: ViewModel Using DI
final class LoginViewModel: ObservableObject {

    @Published var statusText = "Not Logged In"
    @Published var isLoading = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func login() {
        isLoading = true
        statusText = "Logging in..."

        authService.login { success in
            self.isLoading = false
            self.statusText = success ? "Login Successful" : "Login Failed"
        }
    }
}

Step 5: SwiftUI View Injecting ViewModel
struct LoginView: View {

    @StateObject var viewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.statusText)

            if viewModel.isLoading {
                ProgressView()
            }

            Button("Login") {
                viewModel.login()
            }
        }
        .padding()
    }
}

Step 6: App Entry (Production DI)
@main
struct DIExampleApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView(
                viewModel: LoginViewModel(
                    authService: AuthService()
                )
            )
        }
    }
}
Step 7: Preview with Mock (Big Win)
#Preview {
    LoginView(
        viewModel: LoginViewModel(
            authService: MockAuthService()
        )
    )
}


5. DI Container (Optional, Advanced)
Use when:
App grows large
Many services are shared
final class AppContainer {
    let authService: AuthServiceProtocol = AuthService()
}
Injected at app root.

6. DI vs Service Locator (Important Distinction)
| DI                | Service Locator   |
| ----------------- | ----------------- |
| Explicit          | Hidden            |
| Testable          | Hard to test      |
| Compile-time safe | Runtime errors    |
| Preferred         | Avoid if possible |


7. SwiftUI-Specific Best Practices
✔ Prefer initializer injection
✔ Use protocols for services
✔ Use @StateObject only once
✔ Inject dependencies at highest reasonable level
❌ Do not create services inside views

8. Interview-Ready Explanation
“Dependency Injection in SwiftUI is achieved primarily through initializer-based injection and protocol abstraction, enabling loose coupling, testability, and preview-driven development.”

9. Mental Model (Memorize This)
- View → depends on ViewModel
- ViewModel → depends on Protocol
- Protocol → implemented by Service
