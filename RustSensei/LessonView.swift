import SwiftUI

struct LessonView: View {
    @Environment(ProgressStore.self) private var progress
    let lessonID: String

    var body: some View {
        Group {
            if let lesson = Curriculum.lesson(lessonID) {
                lessonBody(lesson)
            } else {
                ContentUnavailableView("Missing lesson", systemImage: "questionmark")
            }
        }
        .navigationTitle(Curriculum.lesson(lessonID).map { Curriculum.chapterTitle($0.chapterID) } ?? "Lesson")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { progress.markOpened(lessonID) }
    }

    private func lessonBody(_ lesson: Lesson) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(Curriculum.chapterTitle(lesson.chapterID))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.rust)
                Text(lesson.title)
                    .font(.title.weight(.bold))
                Text("\(lesson.minutes) min read")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(Array(lesson.blocks.enumerated()), id: \.offset) { _, block in
                    switch block {
                    case .prose(let text):
                        RichText(text: text)
                    case .code(let source):
                        CodeBlock(source: source)
                    case .note(let text):
                        NoteBlock(text: text)
                    }
                }

                NavigationLink(value: Route.quiz(.lesson(lesson.id))) {
                    Text(quizTitle(lesson))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 8)
            }
            .padding()
        }
    }

    private func quizTitle(_ lesson: Lesson) -> String {
        if progress.isComplete(lesson) { return "Quiz again" }
        let answered = lesson.questions.filter {
            progress.mastered.contains($0.id) || progress.missed.contains($0.id)
        }.count
        if answered == 0 { return "Quiz · \(lesson.questions.count) questions" }
        let left = lesson.questions.filter { !progress.mastered.contains($0.id) }.count
        return "Continue quiz · \(left) left"
    }
}
