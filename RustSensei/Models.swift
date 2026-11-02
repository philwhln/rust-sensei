import SwiftUI

struct Chapter: Identifiable, Hashable {
    let id: String
    let title: String
}

enum Block: Hashable {
    case prose(String)
    case code(String)
    case note(String)
}

struct Question: Identifiable, Hashable {
    let id: String
    let prompt: String
    let choices: [String]
    let answer: Int
    let why: String
    var code: String? = nil
}

struct Lesson: Identifiable, Hashable {
    let id: String
    let chapterID: String
    let title: String
    let minutes: Int
    let blocks: [Block]
    let questions: [Question]
}

enum QuizKind: Hashable {
    case lesson(String)
    case review
    case drill
}

enum Route: Hashable {
    case lesson(String)
    case quiz(QuizKind)
}

func lesson(
    _ id: String,
    _ chapterID: String,
    _ title: String,
    minutes: Int,
    _ blocks: [Block],
    _ questions: [Question]
) -> Lesson {
    Lesson(
        id: id,
        chapterID: chapterID,
        title: title,
        minutes: minutes,
        blocks: blocks,
        questions: questions
    )
}

func ask(
    _ id: String,
    _ prompt: String,
    _ choices: [String],
    _ answer: Int,
    _ why: String,
    code: String? = nil
) -> Question {
    Question(id: id, prompt: prompt, choices: choices, answer: answer, why: why, code: code)
}

@MainActor
@Observable
final class Router {
    var path = NavigationPath()

    func showLesson(_ id: String) {
        path = NavigationPath()
        path.append(Route.lesson(id))
    }

    func home() {
        path = NavigationPath()
    }
}
