import Foundation

enum Curriculum {
    static let chapters: [Chapter] = [
        Chapter(id: "language", title: "The language"),
        Chapter(id: "ownership", title: "Ownership"),
        Chapter(id: "borrowing", title: "Borrowing"),
        Chapter(id: "control", title: "Control"),
        Chapter(id: "data", title: "Data"),
        Chapter(id: "collections", title: "Collections"),
        Chapter(id: "traits", title: "Traits"),
        Chapter(id: "errors", title: "Errors"),
        Chapter(id: "lifetimes", title: "Lifetimes"),
        Chapter(id: "everyday", title: "Everyday Rust"),
    ]

    static let lessons: [Lesson] =
        languageLessons
        + ownershipLessons
        + borrowingLessons
        + controlLessons
        + dataLessons
        + collectionLessons
        + traitLessons
        + errorLessons
        + lifetimeLessons
        + everydayLessons

    static var allQuestions: [Question] { lessons.flatMap(\.questions) }

    static func lessons(in chapterID: String) -> [Lesson] {
        lessons.filter { $0.chapterID == chapterID }
    }

    static func lesson(_ id: String) -> Lesson? {
        lessons.first { $0.id == id }
    }

    static func chapterTitle(_ id: String) -> String {
        chapters.first { $0.id == id }?.title ?? ""
    }

    static func after(_ id: String) -> Lesson? {
        guard let index = lessons.firstIndex(where: { $0.id == id }) else { return nil }
        let next = lessons.index(after: index)
        return next < lessons.endIndex ? lessons[next] : nil
    }

    static func validate() {
        var seen = Set<String>()
        assert(Set(chapters.map(\.id)).count == chapters.count, "duplicate chapter")
        let chapterIDs = Set(chapters.map(\.id))
        for chapter in chapters {
            assert(lessons.contains { $0.chapterID == chapter.id }, "empty \(chapter.id)")
        }
        for item in lessons {
            assert(chapterIDs.contains(item.chapterID), "chapter \(item.id)")
            assert(seen.insert(item.id).inserted, "dup lesson \(item.id)")
            assert(!item.title.isEmpty && item.minutes > 0, item.id)
            assert(!item.blocks.isEmpty, item.id)
            assert(item.questions.count == 3, "\(item.id) questions")
            for question in item.questions {
                assert(seen.insert(question.id).inserted, "dup \(question.id)")
                assert(question.choices.count == 4, "\(question.id) choices")
                assert(Set(question.choices).count == 4, "\(question.id) dup choice")
                assert(question.choices.indices.contains(question.answer), "\(question.id) answer")
                assert(question.choices.allSatisfy { !$0.isEmpty }, question.id)
                assert(!question.prompt.isEmpty && !question.why.isEmpty, question.id)
            }
        }
    }
}
