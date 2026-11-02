import SwiftUI

struct HomeView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(Router.self) private var router
    @State private var showSettings = false

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(completedLessons) of \(Curriculum.lessons.count) lessons")
                            .font(.headline)
                        ProgressView(
                            value: Double(completedLessons),
                            total: Double(max(Curriculum.lessons.count, 1))
                        )
                        Text("\(progress.mastered.count) of \(Curriculum.allQuestions.count) questions mastered")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if !progress.hasAnyAnswer {
                            Text("Lessons are short. The quiz is the point. A miss comes back later.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    if let next = progress.continueLesson() {
                        NavigationLink(value: Route.lesson(next.id)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(progress.hasAnyAnswer ? "Continue" : "Start")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(next.title)
                                    .font(.body.weight(.semibold))
                                Text(Curriculum.chapterTitle(next.chapterID))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Text("Course complete. Quiz me keeps it fresh.")
                            .foregroundStyle(.secondary)
                    }

                    if let reviewTitle {
                        NavigationLink(value: Route.quiz(.review)) {
                            Text(reviewTitle)
                        }
                    }

                    NavigationLink(value: Route.quiz(.drill)) {
                        Text("Quiz me")
                    }
                }

                ForEach(Curriculum.chapters) { chapter in
                    Section(chapter.title) {
                        ForEach(Curriculum.lessons(in: chapter.id)) { lesson in
                            NavigationLink(value: Route.lesson(lesson.id)) {
                                HStack(alignment: .center, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(lesson.title)
                                        Text(progress.detail(for: lesson))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer(minLength: 8)
                                    if progress.isComplete(lesson) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Theme.rust)
                                            .accessibilityLabel("Complete")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Rust Sensei")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .lesson(let id):
                    LessonView(lessonID: id)
                case .quiz(let kind):
                    QuizView(kind: kind)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var completedLessons: Int {
        Curriculum.lessons.filter { progress.isComplete($0) }.count
    }

    private var reviewTitle: String? {
        let count = progress.missedQuestions.count
        guard count > 0 else { return nil }
        let take = min(8, count)
        if count > take { return "Review \(take) of \(count) missed" }
        return "Review \(count) missed"
    }
}
