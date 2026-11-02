import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProgressStore.self) private var progress
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Lessons and quizzes stay on this phone. Nothing is sent anywhere.")
                }
                Section {
                    if let url = URL(string: "https://doc.rust-lang.org/book/") {
                        Link("The Rust Book", destination: url)
                    }
                } footer: {
                    Text("The book is the next place to go once a compiler is open. This course is the core language. Async, macros, and unsafe come after it.")
                }
                Section {
                    Button("Reset progress", role: .destructive) {
                        confirmReset = true
                    }
                } footer: {
                    Text("\(progress.mastered.count) questions mastered. \(version)")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Reset progress?",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) { progress.reset() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Clears every answer on this phone.")
            }
        }
    }

    private var version: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return short.map { "Version \($0)." } ?? ""
    }
}
