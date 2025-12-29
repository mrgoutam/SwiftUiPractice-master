//
//  SwiftDataBootcamp.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 26/12/25.
//

import SwiftUI
import SwiftData

/*
 Excellent. We will do this properly, from first principles, without shortcuts or magic.
 This is SwiftData at a professional, architectural level, not a tutorial dump.
 
 SwiftData — Mental Model First (Most Important)
 Before APIs, you must understand what SwiftData actually is doing.
 
 1. What Problem SwiftData Solves
 -> SwiftUI apps need:
 -> Persistent data
 -> Automatic UI updates
 -> Type safety
 -> Minimal boilerplate
 -> Predictable data flow
 
 Before SwiftData, this meant:
 -> Core Data complexity, or
 -> Manual databases, or
 -> Fragile glue code
 
 SwiftData exists to make persistence feel like state.
 
 2. The Core Mental Model (Key Insight)
 SwiftData turns persistent data into a reactive, observable state source for SwiftUI.
 Think of SwiftData as:
 
 Persistent Storage
       ↓
 SwiftData Layer
       ↓
 Observable State
       ↓
 SwiftUI Views
 
 This is why SwiftData feels “natural” in SwiftUI.
 
 3. The Three Pillars of SwiftData
 Everything in SwiftData revolves around three concepts:
 
 1️⃣ @Model — Persistent Identity
 
 A @Model is:
 -> A persistent entity
 -> Observable by default
 -> Identity-based (not value-based)
 */

@Model
class TaskSwiftData {
    var title: String
    var isCompleted: Bool

    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}

/*
 Key points:
 -> class, not struct
 -> Reference semantics matter
 -> Changes are tracked automatically
 */

/*
 2️⃣ ModelContainer — The Database
 The container:
 -> Defines what models exist
 -> Owns the persistent store
 -> Is usually created once per app
 
 let container = try ModelContainer(for: Task.self)

 Think of it as:
 “The database configuration for my app.”
 
 3️⃣ ModelContext — The Transaction Boundary
 The context:
 -> Creates objects
 -> Deletes objects
 -> Saves changes
 
 @Environment(\.modelContext) private var context
 
 Think of ModelContext as:
 “The editing session for my data.”
 
 4. SwiftData + SwiftUI = Reactive Persistence
 SwiftUI views do not fetch manually.
 
 Instead:
 @Query var tasks: [Task]
 
 This means:
 -> SwiftData fetches automatically
 -> View updates automatically
 -> No reload logic
 -> No observers
 
 This is a huge architectural shift.
 
 5. First Minimal App (Clean, Realistic)
 App Entry
 */

/*
 @main
 struct TasksApp: App {

     var body: some Scene {
         WindowGroup {
             TaskListView()
         }
         .modelContainer(for: Task.self)
     }
 }
 */

/*
 Important:
 -> Container injected once
 -> Available everywhere via environment
 
 View (Reading Data)
 */

struct TaskListView: View {

    @Query private var tasks: [TaskSwiftData]
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack {
            Button("Add") {
                addTask()
            }
            
            List {
                ForEach(tasks) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        Button {
                            
                        } label: {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor( task.isCompleted ? .green : .red)
                        }

                    }
                }
            }
        }
    }
    
    private func addTask() {
        let task = TaskSwiftData(title: "New Task")
        context.insert(task)
    }
}

/*
 No fetch.
 No save.
 No reload.
 This is intentional.
 */

#Preview {
    TaskListView()
        .modelContainer(for: TaskSwiftData.self)
}

/*
 6. What Happens Behind the Scenes (Critical)
 When you call:
 
 context.insert(task)

 SwiftData:
 -> Registers the object
 -> Tracks mutations
 -> Writes to disk
 -> Notifies SwiftUI
 -> Triggers view update
 
 All in a controlled, transactional manner.
 
 7. SwiftData and Unidirectional Data Flow
 SwiftData fits UDF naturally:
 
 User Action
     ↓
 ModelContext mutation
     ↓
 Persistent State changes
     ↓
 @Query updates
     ↓
 View re-renders

 Views do not own data.
 They observe data.
 
 8. What NOT to Do (Common Mistakes)
 
 ❌ Treat SwiftData like UserDefaults
 // Wrong mental model
 task.title = "Updated"
 
 This is fine only when done intentionally inside controlled flows.
 
 ❌ Hide SwiftData mutations everywhere
 Avoid:
 -> Random inserts in views
 -> Side effects in computed properties
 
 SwiftData is powerful — misuse leads to chaos.
 
 9. SwiftData vs @State (Important Distinction)
 
 | @State      | SwiftData      |
 | ----------- | -------------- |
 | View-local  | App-wide       |
 | Ephemeral   | Persistent     |
 | Value-based | Identity-based |
 | Resettable  | Durable        |

 10. Senior-Level Rule to Remember
 SwiftData is not a database API.
 It is a persistence-backed state system.
 Once you understand this, everything else makes sense.
 
 Next logical steps:
 -> @Model rules & relationships
 -> @Query filtering and sorting
 -> Mutation rules & transactions
 -> SwiftData + ViewModels (important)
 -> Testing SwiftData code
 -> Performance & pitfalls
 
 
 => @Model rules & relationships:
 Good. We now move into the most important practical layer of SwiftData:
 
 @Model rules, identity, and relationships
 
 This is where most production bugs come from if misunderstood.
 
 @Model — Deep Rules & Mental Model:
 
 1. What @Model Really Means
 When you write:
 
 @Model
 class Task {
     var title: String
     var isCompleted: Bool
 }
 
 SwiftData turns this into:
 -> A persistable entity
 -> An observable reference type
 -> A tracked object with identity
 -> A managed lifecycle object
 
 A @Model is NOT a normal Swift class.
 
 2. Rule #1 — @Model Must Be a class
 This is non-negotiable.
 
 Why?
 Persistence needs stable identity
 SwiftData tracks changes via reference semantics
 
 // ❌ Invalid
 @Model
 struct Task { }

 // ✅ Correct
 @Model
 class Task { }
 
 3. Identity vs Value (Critical Insight)
 Swift Struct (Value)
 
 let a = User(name: "A")
 let b = a
 b.name = "B"
 // a unchanged
 
 SwiftData Model (Identity)
 
 
 let taskA = Task(title: "A")
 let taskB = taskA
 taskB.title = "B"
 // taskA.title == "B"
 There is one object, one identity.
 
 This is why:
 -> SwiftUI updates correctly
 -> Relationships work
 -> Persistence is reliable
 
 4. Default Properties & Initializers
 Rules:
 All stored properties are persisted by default
 You must initialize all non-optional properties
 
 @Model
 class Task {
     var title: String
     var createdAt: Date = .now
     var isCompleted: Bool = false

     init(title: String) {
         self.title = title
     }
 }
 
 Good practice:
 -> Keep models simple
 -> No heavy logic inside models
 
 5. Optional vs Non-Optional (Design Choice)
 Prefer non-optional whenever possible.
 
 var title: String        // Better
 var notes: String?      // Optional when truly optional
 
 Why:
 -> Easier reasoning
 -> Fewer runtime checks
 -> Cleaner queries
 
 6. Relationships — One-to-Many:
 Example: Project → Tasks
 
 @Model
 class Project {
     var name: String
     var tasks: [Task] = []

     init(name: String) {
         self.name = name
     }
 }

 @Model
 class Task {
     var title: String

     init(title: String) {
         self.title = title
     }
 }
 
 SwiftData:
 -> Tracks both sides automatically
 -> Maintains referential integrity
 
 7. Inverse Relationships (Important)
 You should explicitly define inverses for clarity and correctness.
 
 @Model
 class Project {
     var name: String
     @Relationship(inverse: \Task.project)
     var tasks: [Task] = []
 }

 @Model
 class Task {
     var title: String
     var project: Project?

     init(title: String) {
         self.title = title
     }
 }
 
 Now:
 -> Assigning task.project = project
 -> Automatically updates project.tasks
 -> This prevents orphaned data.
 
 8. Deletion Rules (Very Important)
 You must decide what happens when a parent is deleted.
 
 @Relationship(deleteRule: .cascade)
 var tasks: [Task]
 
 Delete rules:
 -> .cascade → delete children
 -> .nullify → set relationship to nil
 -> .deny → prevent deletion
 
 Production apps must define this explicitly.
 
 9. Computed Properties Are NOT Persisted
 
 var displayTitle: String {
     title.uppercased()
 }
 
 This is fine.
 Only stored properties persist.
 
 10. What NOT to Put Inside @Model
 
 Avoid:
 -> Network calls
 -> Business logic
 -> View logic
 -> Validation logic
 
 Models should be:
 Dumb, stable, and persistent
 
 11. Common Production Mistakes
 ❌ Using @Model as ViewModel
 // Bad design
 
 @Model
 class ScreenState { }
 
 SwiftData models are domain data, not UI state.
 
 ❌ Creating models inside computed properties
 var newTask: Task {
     Task(title: "X") // ❌ uncontrolled creation
 }
 
 12. Senior-Level Rule to Remember
 @Model represents real-world entities, not screens.
 If it exists only for UI, it should not be a @Model.
 
 => @Query — how data is fetched, filtered, sorted, and kept in sync
 If you understand this well, you will avoid performance issues, incorrect UI updates, and hidden bugs.
 
 @Query — Deep Mental Model
 1. What @Query Really Is
 When you write:
 @Query var tasks: [Task]
 
 SwiftData does all of this for you:
 -> Creates a fetch request
 -> Observes the persistent store
 -> Re-runs the query when data changes
 -> Triggers SwiftUI view updates
 
 @Query is not a one-time fetch.
 It is a live, reactive query.
 
 2. @Query Is View-Scoped
 Important rule:
 -> @Query lives inside a View
 -> It is tied to the view’s lifecycle
 -> When the view disappears, the query stops
 
 This is by design.
 
 If you need data outside a view:
 -> Fetch manually via ModelContext
 -> Or pass data downward
 
 3. Basic Fetch
 @Query private var tasks: [Task]
 
 This means:
 -> Fetch all Task objects
 -> No filter
 -> No sort
 -> Auto-updating
 
 Use this only for small datasets.
 
 4. Sorting (Always Explicit in Production)
 
 @Query(sort: \Task.createdAt, order: .reverse)
 private var tasks: [Task]
 
 Always define sort order to:
 -> Ensure deterministic UI
 -> Avoid implicit behavior
 
 5. Filtering with #Predicate (Critical)
 Example: Only incomplete tasks
 
 @Query(
     filter: #Predicate<Task> { !$0.isCompleted },
     sort: \Task.createdAt
 )
 private var pendingTasks: [Task]
 
 Key points:
 -> Fully type-safe
 -> Compiler-checked
 -> No string predicates
 
 6. Dynamic Queries (Common Production Pattern)
 You cannot mutate @Query directly.
 Instead, you recreate it using parameters.
 
 struct TaskListView: View {

     @Query private var tasks: [Task]

     init(showCompleted: Bool) {
         _tasks = Query(
             filter: #Predicate<Task> {
                 showCompleted ? true : !$0.isCompleted
             }
         )
     }

     var body: some View {
         List(tasks) { task in
             Text(task.title)
         }
     }
 }
 
 This is intentional and forces predictability.
 
 7. @Query and Relationships
 Example: Tasks of a specific project
 
 @Query(
     filter: #Predicate<Task> { $0.project?.name == "Work" }
 )
 var workTasks: [Task]
 
 SwiftData handles joins automatically.
 
 8. Performance Rules (Very Important)
 ❌ Do NOT fetch everything and filter in memory
 
 let filtered = tasks.filter { $0.isCompleted }
 
 Always filter at the query level.
 
 ❌ Avoid @Query for huge datasets
 For:
 -> Thousands of records
 -> Pagination needs
 
 Use:
 context.fetch(FetchDescriptor<Task>(...))
 
 
 9. @Query vs Manual Fetch
 | Scenario              | Use           |
 | --------------------- | ------------- |
 | Simple lists          | `@Query`      |
 | Dynamic user filters  | `@Query` init |
 | Heavy computation     | Manual fetch  |
 | Background processing | Manual fetch  |

 10. Mutating Data From @Query Results
 This is allowed and safe:
 task.isCompleted.toggle()
 
 Why?
 -> Task is identity-based
 -> Change is tracked
 -> Context handles persistence
 
 But mutation should happen:
 -> Inside explicit user actions
 -> Not during rendering
 
 11. What NOT to Do with @Query
 ❌ Side effects in body
 ForEach(tasks) { task in
     task.isCompleted = true // ❌ very dangerous
 }
 This will cause infinite update loops.
 
 12. Senior-Level Rule
 @Query describes what data the view needs, not how to fetch it.
 This is declarative data access.
 
 => Mutation rules & transactions — when and how data should be modified
 If this is misunderstood, apps become unstable, slow, or corrupt data silently.
 
 SwiftData Mutations & Transactions — Deep Understanding:
 1. The Golden Rule (Memorize This)
 SwiftData mutations must happen intentionally, at well-defined boundaries.
 SwiftData is not free-form mutable state like @State.
 
 2. What Counts as a Mutation
 Any of the following are mutations:
 -> Creating a model
 -> Updating a property
 -> Deleting a model
 -> Modifying a relationship
 
 Examples:
 context.insert(task)
 task.title = "Updated"
 context.delete(task)
 project.tasks.append(task)
 
 All are tracked operations.
 
 3. ModelContext Is the Mutation Gateway
 Every mutation flows through a ModelContext.
 
 @Environment(\.modelContext)
 private var context
 
 Think of ModelContext as:
 A transaction scope
 
 SwiftData:
 -> Tracks changes
 -> Batches writes
 -> Persists automatically
 
 4. Automatic Saves (Important)
 SwiftData auto-saves when:
 -> Run loop is idle
 -> View updates settle
 -> App lifecycle events occur
 
 You normally do not call save().
 This is deliberate.
 
 5. Controlled Mutation Pattern (Correct)
 ❌ Wrong (Mutation during render)
 
 var body: some View {
     if tasks.isEmpty {
         context.insert(Task(title: "Default")) // ❌
     }
 }
 
 Why wrong:
 -> View rendering must be pure
 -> Causes infinite update loops
 
 ✅ Correct (Mutation via user intent)
 
 Button("Add Task") {
     let task = Task(title: "New Task")
     context.insert(task)
 }
 
 Mutations should be driven by:
 -> User actions
 -> Lifecycle events
 -> Explicit functions
 
 6. Grouping Mutations (Transaction Thinking)
 
 func completeAllTasks() {
     tasks.forEach { $0.isCompleted = true }
 }
 
 SwiftData treats this as:
 -> One logical transaction
 -> One persistence cycle
 -> You don’t need manual transaction blocks.
 
 7. Deletion Rules in Practice
 Cascading Delete Example
 
 @Model
 class Project {
     @Relationship(deleteRule: .cascade)
     var tasks: [Task]
 }
 
 Deleting project:
 context.delete(project)
 
 Result:
 -> Tasks automatically deleted
 -> No orphaned rows
 
 8. Relationship Mutations (Subtle but Important)
 task.project = project
 
 This:
 -> Updates both sides
 -> Maintains integrity
 -> Triggers UI updates
 
 Never manually update both sides.
 
 9. Mutations + Unidirectional Data Flow
 Correct flow:
 View Event
     ↓
 Intent Function
     ↓
 ModelContext Mutation
     ↓
 SwiftData Persist
     ↓
 @Query Update
     ↓
 View Re-render
 Never reverse this.
 
 10. Background Mutations (Advanced but Important)
 SwiftData supports background contexts, but:
 UI should only use main context
 Background work must be deliberate
 For now:
 Do all mutations on the main context unless you have a proven need.
 
 10. Background Mutations (Advanced but Important)
 SwiftData supports background contexts, but:
 UI should only use main context
 Background work must be deliberate
 For now:
 Do all mutations on the main context unless you have a proven need.
 
 12. Common Production Bugs
 ❌ Mutating in onAppear
 .onAppear {
     context.insert(Task(title: "Auto")) // risky
 }
 Why risky:
 Can trigger multiple times
 Leads to duplicate data
 
 Better:
 Use one-time flags
 Use app-level logic
 
 13. Senior-Level Rule
 SwiftData mutations should feel boring and predictable.
 If they feel clever, they are wrong.
 
 
 
 => SwiftData + ViewModels — clean architecture without abusing Views
 
 This is where most developers either:
 -> Overuse SwiftData in views
 -> Or over-abstract prematurely
 
 This is where SwiftData meets real architecture.
 
 SwiftData + ViewModels — clean separation without fighting SwiftUI
 
 SwiftData + ViewModels — Professional Architecture::
 
 1. First, the Truth (Important)
 SwiftData was designed to work directly with SwiftUI views.
 
 So the rule is:
 -> You do NOT need ViewModels everywhere.
 
 But…
 -> You DO need ViewModels when logic appears.
 
 2. When You Should Introduce a ViewModel
 Introduce a ViewModel if you have:
 -> Non-trivial business rules
 -> Validation
 -> Conditional logic
 -> Reusable behavior
 -> Side effects
 Do not introduce ViewModels just to “look clean”.
 
 3. The Correct Responsibility Split:
 
 View:
 -> Displays data
 -> Captures user intent
 -> No business logic
 -> No persistence decisions

 ViewModel:
 -> Orchestrates mutations
 -> Enforces rules
 -> Talks to ModelContext
 -> Emits intent-driven methods
 
 SwiftData Model:
 -> Represents domain data
 -> Holds no logic
 
 4. A Clean Production Example
 
 Domain Model:
 @Model
 class Task {
     var title: String
     var isCompleted: Bool

     init(title: String) {
         self.title = title
         self.isCompleted = false
     }
 }
 
 ViewModel:
 final class TaskListViewModel: ObservableObject {

     private let context: ModelContext

     init(context: ModelContext) {
         self.context = context
     }

     func addTask(title: String) {
         guard !title.isEmpty else { return }

         let task = Task(title: title)
         context.insert(task)
     }

     func toggleCompletion(for task: Task) {
         task.isCompleted.toggle()
     }

     func delete(_ task: Task) {
         context.delete(task)
     }
 }
 
 Note:
 -> ViewModel does not own data
 -> It acts upon data
 
 View:
 struct TaskListView: View {

     @Query private var tasks: [Task]
     @Environment(\.modelContext) private var context

     @StateObject private var viewModel: TaskListViewModel

     init() {
         let context = ModelContext.shared // conceptually injected
         _viewModel = StateObject(
             wrappedValue: TaskListViewModel(context: context)
         )
     }

     var body: some View {
         List {
             ForEach(tasks) { task in
                 HStack {
                     Text(task.title)
                     Spacer()
                     Button {
                         viewModel.toggleCompletion(for: task)
                     } label: {
                         Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                     }
                 }
             }
             .onDelete { indexSet in
                 indexSet.map { tasks[$0] }.forEach(viewModel.delete)
             }
         }
         .toolbar {
             Button("Add") {
                 viewModel.addTask(title: "New Task")
             }
         }
     }
 }

 5. Important Design Decision:
 
 Notice:
 -> @Query stays in the View
 -> ViewModel receives models, not arrays
 -> No data duplication
 
 This avoids:
 -> State desynchronization
 -> Double sources of truth
 
 6. Why ViewModels Should NOT Own @Query
 // ❌ Don't do this
 @Query var tasks: [Task]
 Why?
 -> @Query is view-scoped
 -> Breaks SwiftUI lifecycle assumptions
 
 7. Dependency Injection (Clean)
 In real apps:
 -> Inject ModelContext from parent
 -> Or use environment-based factories
 
 Example:
 TaskListView(viewModel: TaskListViewModel(context: context))
 
 8. SwiftData + Unidirectional Data Flow
 
 View
   ↓ intent
 ViewModel
   ↓ mutation
 ModelContext
   ↓ persistence
 SwiftData
   ↓ update
 @Query
   ↓ render
 View
 
 Perfect UDF alignment.
 
 9. Common Anti-Patterns
 ❌ ViewModel holding arrays of models
 @Published var tasks: [Task]
 
 Wrong.
 SwiftData already owns the data.
 
 ❌ Business logic inside model
 func complete() { isCompleted = true }
 Tempting, but dangerous.
 
 10. Senior-Level Rule
 -> SwiftData owns data.
 -> ViewModels own behavior.
 -> Views own presentation.
 
 Stick to this, and apps scale cleanly.
 */
