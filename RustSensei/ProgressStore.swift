import Foundation
import Observation

@MainActor
@Observable
final class ProgressStore {
    private(set) var mastered: Set<String> = []
    private(set) var missed: Set<String> = []
    private(set) var masteredAt: [String: Date] = [:]
    private(set) var lastLessonID: String?

    private static let key = "rust-sensei.progress.v1"

    init() {
        Curriculum.validate()
        let decoder = JSONDecoder()
        // Dates stay seconds since 1970 so a later decode does not change meaning.
        decoder.dateDecodingStrategy = .secondsSince1970
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let snap = try? decoder.decode(Snapshot.self, from: data) else { return }
        mastered = snap.mastered
        missed = snap.missed
        masteredAt = snap.masteredAt
        lastLessonID = snap.lastLessonID
    }

    var hasAnyAnswer: Bool { !mastered.isEmpty || !missed.isEmpty }

    var missedQuestions: [Question] {
        Curriculum.allQuestions.filter { missed.contains($0.id) }
    }

    func isComplete(_ lesson: Lesson) -> Bool {
        lesson.questions.allSatisfy { mastered.contains($0.id) }
    }

    func masteredCount(_ lesson: Lesson) -> Int {
        lesson.questions.filter { mastered.contains($0.id) }.count
    }

    func detail(for lesson: Lesson) -> String {
        let done = masteredCount(lesson)
        let total = lesson.questions.count
        if done == total { return "\(lesson.minutes) min · complete" }
        let attempted = lesson.questions.contains { missed.contains($0.id) }
        if done == 0 && !attempted { return "\(lesson.minutes) min" }
        return "\(lesson.minutes) min · \(done) of \(total)"
    }

    func continueLesson() -> Lesson? {
        if let lastLessonID, let lesson = Curriculum.lesson(lastLessonID), !isComplete(lesson) {
            return lesson
        }
        return Curriculum.lessons.first { !isComplete($0) }
    }

    func drillQuestions(limit: Int) -> [Question] {
        let ranked = Curriculum.allQuestions
            .filter { mastered.contains($0.id) }
            .sorted { lhs, rhs in
                (masteredAt[lhs.id] ?? .distantPast) < (masteredAt[rhs.id] ?? .distantPast)
            }
        return Array(ranked.prefix(limit))
    }

    func markOpened(_ lessonID: String) {
        guard lastLessonID != lessonID else { return }
        lastLessonID = lessonID
        save()
    }

    func record(questionID: String, correct: Bool) {
        var mastered = mastered
        var missed = missed
        var masteredAt = masteredAt
        if correct {
            let isNew = mastered.insert(questionID).inserted
            missed.remove(questionID)
            if isNew { masteredAt[questionID] = Date() }
        } else {
            mastered.remove(questionID)
            missed.insert(questionID)
            masteredAt[questionID] = nil
        }
        self.mastered = mastered
        self.missed = missed
        self.masteredAt = masteredAt
        save()
    }

    func reset() {
        mastered = []
        missed = []
        masteredAt = [:]
        lastLessonID = nil
        UserDefaults.standard.removeObject(forKey: Self.key)
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let snap = Snapshot(
            mastered: mastered,
            missed: missed,
            masteredAt: masteredAt,
            lastLessonID: lastLessonID
        )
        guard let data = try? encoder.encode(snap) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    private struct Snapshot: Codable {
        var mastered: Set<String>
        var missed: Set<String>
        var masteredAt: [String: Date]
        var lastLessonID: String?
    }
}
