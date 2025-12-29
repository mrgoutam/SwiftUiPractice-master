//
//  SwiftDataWithAsyncBackgroundWork.swift
//  SwiftUIAdvance
//
//  Created by Mr Goutam D on 29/12/25.
//

import SwiftUI

struct SwiftDataWithAsyncBackgroundWork: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SwiftDataWithAsyncBackgroundWork()
}

/*
 Below is a professional, production-grade explanation of SwiftData + async background work.
 This is an advanced topic, but I will keep it mentally clean and predictable, not “magic-driven”.
 
 SwiftData + Async Background Work
 (Correct, Safe, and Scalable)
 
 First: The Core Truth (Do Not Skip)
 -> SwiftData is UI-centric by default.
 -> Background work is possible, but must be intentional.
 
 SwiftData is not Core Data with free multithreading.
 If you misuse it, you will get:
 -> Data races
 -> Crashes
 -> Silent corruption
 
 1️⃣ The Mental Model You Must Adopt
 SwiftData has contexts, just like Core Data
 -> ModelContext is NOT thread-safe
 -> Each context belongs to one execution context
 -> UI uses the main context
 -> Background work uses separate contexts
 
 Think like this:
 
 Main Actor
  └─ UI ModelContext (SwiftUI, @Query)

 Background Task
  └─ Background ModelContext (async work)

 Never share contexts across threads.
 
 2️⃣ When You Actually Need Background Work
 Use background SwiftData work when:
 -> Importing large datasets
 -> Syncing from a server
 -> Batch updates
 -> Data migration / cleanup
 -> Long-running calculations
 
 Do NOT use background work for:
 -> Simple CRUD
 -> Button taps
 -> UI-triggered small updates
 
 3️⃣ SwiftData’s Rule for Background Contexts
 Each background task must create its own ModelContext.
 
 That context:
 -> Uses the same ModelContainer
 -> Is isolated
 -> Commits independently
 
 4️⃣ Production Pattern: Background Import
 Step 1: Shared ModelContainer (App-Level)
 
 @main
 struct TasksApp: App {

     let container: ModelContainer

     init() {
         container = try! ModelContainer(for: Task.self)
     }

     var body: some Scene {
         WindowGroup {
             TaskListView()
         }
         .modelContainer(container)
     }
 }
 This container is shared, not the context.
 
 5️⃣ Background Worker (Correct Pattern)
 
 final class TaskImporter {

     private let container: ModelContainer

     init(container: ModelContainer) {
         self.container = container
     }

     func importTasks(from titles: [String]) async throws {
         let context = ModelContext(container)

         for title in titles {
             let task = Task(title: title)
             context.insert(task)
         }

         try context.save()
     }
 }
 
 6️⃣ Calling Background Work from UI (Correctly)
 Why this is correct:
 -> New ModelContext
 -> No UI access
 -> Explicit save
 -> Safe isolation
  
 struct TaskListView: View {

     @Environment(\.modelContext)
     private var context

     @Environment(\.modelContainer)
     private var container

     var body: some View {
         Button("Import Tasks") {
             Task {
                 let importer = TaskImporter(container: container)
                 try await importer.importTasks(
                     from: ["One", "Two", "Three"]
                 )
             }
         }
     }
 }

 What Happens
 -> Background context writes to disk
 -> SwiftData merges changes
 -> @Query automatically updates UI
 -> No manual refresh
 
 This is exactly how SwiftData is meant to work.
 
 ✅ CORRECT (re-fetch inside background context)
 func completeAllTasks() async throws {
     let context = ModelContext(container)

     let tasks = try context.fetch(
         FetchDescriptor<Task>()
     )

     tasks.forEach { $0.isCompleted = true }
     try context.save()
 }
 Rule:
 Never pass @Model objects across contexts.
 
 8️⃣ Identity Is Context-Bound (Critical Insight)
 A Task object:
 -> Belongs to one ModelContext
 -> Cannot be safely used in another
 -> Must be refetched by ID if needed
 
 SwiftData enforces this implicitly, not loudly.
 
 9️⃣ SwiftData + async/await Philosophy
 SwiftData works best when:
 async → background compute / IO
 SwiftData mutations → isolated contexts
 UI updates → automatic merge
 Think:
 async task
    ↓
 background ModelContext
    ↓
 save()
    ↓
 SwiftData merge
    ↓
 @Query refresh
 🔟 Error Handling Strategy (Production)
 SwiftData errors are rare but real.
 Best practice:
 Validate inputs before mutation
 Treat persistence failure as fatal for that operation
 Log aggressively
 do {
     try context.save()
 } catch {
     assertionFailure("Persistence failed: \(error)")
 }
 
 12️⃣ Senior-Level Rule (Memorize)
 ModelContainer is shared.
 ModelContext is isolated.
 Models never cross threads.
 If you follow this, SwiftData stays rock-solid.
 */
