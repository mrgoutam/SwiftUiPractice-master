//
//  SwiftDataBootcampProduction.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 29/12/25.
//

/*
 Below is a production-style, end-to-end SwiftData example that follows Clean Architecture + Unidirectional Data Flow, without abusing SwiftUI or SwiftData.
 
 This is not a demo. This is how you would design a real app feature.
 
 I will explicitly show:
 -> Responsibilities
 -> Boundaries
 -> Why each piece exists
 -> Where SwiftData fits (and where it must NOT)
 
 Example Domain:
 Task Management Feature (realistic, non-trivial, scalable)
 
 We will model:
 -> Tasks
 -> Validation
 -> Business rules
 -> Persistence
 -> UI updates
 -> Clean separation
 
 1️⃣ Domain Layer (Pure Business Model)
 SwiftData Model (Persistence Entity)
 */

import SwiftUI
import SwiftData

@Model
final class TaskProd {
    var title: String
    var isCompleted: Bool
    var createdAt: Date

    init(title: String) {
        self.title = title
        self.isCompleted = false
        self.createdAt = .now
    }
}

/*
 Why this is correct
 -> No UI logic
 -> No validation
 -> No behavior
 -> Represents real domain data
 Rule: @Model = data, not intelligence
 
 2️⃣ Repository Layer (Abstraction Over SwiftData)
 This is critical for clean architecture.
 Protocol (Abstraction)
 */

protocol TaskRepository {
    func addTask(title: String)
    func toggleTask(_ task: TaskProd)
    func deleteTask(_ task: TaskProd)
}

/*
 Why:
 -> ViewModel does not depend on SwiftData
 -> Testable
 -> Replaceable later
 
 SwiftData Implementation
 */

final class SwiftDataTaskRepository: TaskRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func addTask(title: String) {
        let task = TaskProd(title: title)
        context.insert(task)
    }

    func toggleTask(_ task: TaskProd) {
        task.isCompleted.toggle()
    }

    func deleteTask(_ task: TaskProd) {
        context.delete(task)
    }
}

/*
 Why this is professional
 -> All mutations are centralized
 -> SwiftData usage is isolated
 -> Business logic stays clean
 
 3️⃣ Use Case Layer (Business Rules)
 This layer enforces rules, not storage.
 Use Case Protocol
 */

protocol AddTaskUseCase {
    func execute(title: String)
}

// Implementation
final class AddTaskUseCaseImpl: AddTaskUseCase {

    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)

        guard trimmed.count >= 3 else {
            return // business rule
        }

        repository.addTask(title: trimmed)
    }
}

/*
 Why this matters:
 -> Validation rules live here
 -> SwiftUI never sees business logic
 -> Easy to change rules later
 */

/*
 4️⃣ ViewModel Layer (Application Logic)
 ViewModel
 */

import Foundation
internal import Combine

@MainActor
final class TaskListViewModel: ObservableObject {

    // UI State
    @Published var newTaskTitle: String = ""

    // Use cases
    private let addTaskUseCase: AddTaskUseCase
    private let repository: TaskRepository

    init(
        addTaskUseCase: AddTaskUseCase,
        repository: TaskRepository
    ) {
        self.addTaskUseCase = addTaskUseCase
        self.repository = repository
    }

    // MARK: - Intents

    func addTask() {
        addTaskUseCase.execute(title: newTaskTitle)
        newTaskTitle = ""
    }

    func toggleTask(_ task: TaskProd) {
        repository.toggleTask(task)
    }

    func deleteTask(_ task: TaskProd) {
        repository.deleteTask(task)
    }
}

/*
 Key Observations:
 -> ViewModel does not fetch data
 -> ViewModel does not store arrays
 -> ViewModel only coordinates actions
 -> SwiftData is invisible here
 
 This is correct UDF.
 */

/*
 5️⃣ SwiftUI View Layer (Declarative UI)
 View
 */

struct SwiftDataBootcampProduction: View {
    // SwiftData
    @Query(sort: \TaskProd.createdAt, order: .reverse)
    private var tasks: [TaskProd]
    
    @Environment(\.modelContext)
    private var context
    
    // ViewModel
    @StateObject
    private var viewModel: TaskListViewModel
    
    init(context: ModelContext) {
        let repository = SwiftDataTaskRepository(context: context)
        let addTaskUseCase = AddTaskUseCaseImpl(repository: repository)
        
        _viewModel = StateObject(
            wrappedValue: TaskListViewModel(
                addTaskUseCase: addTaskUseCase,
                repository: repository
            )
        )
    }
    
    var body: some View {
        VStack {
            inputSection
            listSection
        }
        .padding()
    }
    
    private var inputSection: some View {
        HStack {
            TextField("New task", text: $viewModel.newTaskTitle)
                .textFieldStyle(.roundedBorder)
            
            Button("Add") {
                viewModel.addTask()
            }
        }
    }
    
    private var listSection: some View {
        List {
            ForEach(tasks) { task in
                HStack {
                    Text(task.title)
                    Spacer()
                    Button {
                        viewModel.toggleTask(task)
                    } label: {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    }
                }
            }
            .onDelete { indexSet in
                indexSet
                    .map { tasks[$0] }
                    .forEach(viewModel.deleteTask)
            }
        }
    }
}

/*
 6️⃣ App Entry Point
 @main
 struct TasksApp: App {

     var body: some Scene {
         WindowGroup {
             TaskListView(context: sharedModelContext)
         }
         .modelContainer(for: Task.self)
     }

     private var sharedModelContext: ModelContext {
         ModelContext(ModelContainer(for: Task.self))
     }
 }
 (In real apps, this would be injected once and reused.)
 */

#Preview {
    // Safely create a ModelContainer for previews. ModelContainer(for:) throws in newer SDKs.
    let container = (try? ModelContainer(for: TaskProd.self)) ?? {
        // Fallback to an in-memory container if needed
        let schema = Schema([TaskProd.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    let context = ModelContext(container)

    return SwiftDataBootcampProduction(context: context)
        .modelContainer(container)
}


/*
 7️⃣ Data Flow (Very Important)
 User Input
    ↓
 ViewModel Intent
    ↓
 Use Case (rules)
    ↓
 Repository
    ↓
 ModelContext mutation
    ↓
 SwiftData persistence
    ↓
 @Query updates
    ↓
 SwiftUI re-renders
 This is textbook Unidirectional Data Flow.
 */


/*
 8️⃣ Why This Architecture Is Production-Grade
 ✔ No duplicate state
 ✔ No SwiftData in business logic
 ✔ No logic in Views
 ✔ Testable ViewModel
 ✔ Replaceable persistence
 ✔ Predictable mutations
 ✔ Scales to multiple features
 This is senior-level SwiftUI + SwiftData architecture.
 
 9️⃣ What You Should Now Clearly Understand
 After this example, you should see clearly:
 -> Why @Query stays in Views
 -> Why ViewModels never own arrays
 -> Why SwiftData models stay dumb
 -> Why repositories matter
 -> How UDF naturally emerges
 -> How SwiftData replaces fetch controllers
 */
