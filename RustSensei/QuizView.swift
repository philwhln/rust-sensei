import SwiftUI
import UIKit

struct QuizView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(Router.self) private var router
    let kind: QuizKind

    @State private var questions: [Question] = []
    @State private var index = 0
    @State private var picked: Int?
    @State private var correctCount = 0
    @State private var finished = false
    @State private var loaded = false

    var body: some View {
        Group {
            if !loaded {
                ProgressView()
            } else if questions.isEmpty {
                emptyState
            } else if finished {
                summary
            } else {
                questionBody(questions[index])
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !loaded { load() }
        }
    }

    private var title: String {
        switch kind {
        case .lesson(let id):
            Curriculum.lesson(id)?.title ?? "Quiz"
        case .review:
            "Review"
        case .drill:
            "Quiz me"
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(title, systemImage: "questionmark.circle")
        } description: {
            Text(emptyMessage)
        } actions: {
            if case .drill = kind, let first = Curriculum.lessons.first {
                Button("Start the first lesson") {
                    router.showLesson(first.id)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var emptyMessage: String {
        switch kind {
        case .drill:
            "Quiz me draws from questions you have already gotten right. Finish a lesson first."
        case .review:
            "No missed questions."
        case .lesson:
            "This lesson has no questions."
        }
    }

    private func questionBody(_ question: Question) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Question \(index + 1) of \(questions.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                RichText(text: question.prompt)
                    .font(.title3)
                if let code = question.code {
                    CodeBlock(source: code)
                }
                ForEach(Array(question.choices.enumerated()), id: \.offset) { choiceIndex, choice in
                    choiceButton(choiceIndex, choice, question)
                }
                if picked != nil {
                    explanation(question)
                    Button(action: advance) {
                        Text(index + 1 == questions.count ? "See results" : "Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding()
        }
    }

    private func choiceButton(_ choiceIndex: Int, _ choice: String, _ question: Question) -> some View {
        Button {
            pick(choiceIndex, question)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                RichText(text: choice)
                Spacer(minLength: 8)
                if let picked {
                    if choiceIndex == question.answer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if choiceIndex == picked {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(14)
            .background(choiceColor(choiceIndex, question))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .allowsHitTesting(picked == nil)
    }

    private func choiceColor(_ choiceIndex: Int, _ question: Question) -> Color {
        guard let picked else { return Color(.secondarySystemBackground) }
        if choiceIndex == question.answer { return Color.green.opacity(0.22) }
        if choiceIndex == picked { return Color.red.opacity(0.18) }
        return Color(.secondarySystemBackground)
    }

    private func explanation(_ question: Question) -> some View {
        let correct = picked == question.answer
        return VStack(alignment: .leading, spacing: 6) {
            Text(correct ? "Correct" : "Not quite")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(correct ? Color.green : Color.red)
            RichText(text: question.why)
                .font(.subheadline)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background((correct ? Color.green : Color.red).opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(correctCount) of \(questions.count)")
                .font(.largeTitle.weight(.bold))
            Text(summaryLine)
                .font(.body)
                .foregroundStyle(.secondary)
            buttons
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var buttons: some View {
        if shouldRetry {
            wideButton("Retry missed", prominent: true) { load() }
            if let nextID {
                wideButton("Next lesson", prominent: false) { router.showLesson(nextID) }
            }
            wideButton("Back to course", prominent: false) { router.home() }
        } else if let nextID {
            wideButton("Next lesson", prominent: true) { router.showLesson(nextID) }
            wideButton("Back to course", prominent: false) { router.home() }
        } else {
            wideButton("Back to course", prominent: true) { router.home() }
        }
    }

    @ViewBuilder
    private func wideButton(_ title: String, prominent: Bool, action: @escaping () -> Void) -> some View {
        if prominent {
            Button(action: action) {
                Text(title).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        } else {
            Button(action: action) {
                Text(title).frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var shouldRetry: Bool {
        guard case .lesson(let id) = kind, let lesson = Curriculum.lesson(id) else { return false }
        return !progress.isComplete(lesson)
    }

    private var nextID: String? {
        guard case .lesson(let id) = kind else { return nil }
        return Curriculum.after(id)?.id
    }

    private var summaryLine: String {
        switch kind {
        case .lesson(let id):
            guard let lesson = Curriculum.lesson(id) else { return "" }
            return progress.isComplete(lesson)
                ? "Lesson complete."
                : "Not yet. Retry the ones you missed."
        case .review:
            let left = progress.missedQuestions.count
            return left == 0 ? "No missed questions left." : "\(left) still missed."
        case .drill:
            return correctCount == questions.count
                ? "Still solid."
                : "A miss goes back to review."
        }
    }

    private func load() {
        questions = Self.questions(for: kind, progress: progress)
        index = 0
        picked = nil
        correctCount = 0
        finished = false
        loaded = true
    }

    private func pick(_ choice: Int, _ question: Question) {
        guard picked == nil else { return }
        picked = choice
        let correct = choice == question.answer
        if correct { correctCount += 1 }
        progress.record(questionID: question.id, correct: correct)
        UINotificationFeedbackGenerator().notificationOccurred(correct ? .success : .error)
    }

    private func advance() {
        picked = nil
        if index + 1 >= questions.count {
            finished = true
        } else {
            index += 1
        }
    }

    private static func questions(for kind: QuizKind, progress: ProgressStore) -> [Question] {
        switch kind {
        case .lesson(let id):
            guard let lesson = Curriculum.lesson(id) else { return [] }
            let pending = lesson.questions.filter { !progress.mastered.contains($0.id) }
            return pending.isEmpty ? lesson.questions : pending
        case .review:
            return Array(progress.missedQuestions.prefix(8))
        case .drill:
            return progress.drillQuestions(limit: 5)
        }
    }
}
