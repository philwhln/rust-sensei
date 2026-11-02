import SwiftUI

enum Theme {
    static let rust = Color(red: 0.890, green: 0.518, blue: 0.227)
    static let codeBackground = Color(red: 0.105, green: 0.086, blue: 0.075)
    static let codeText = Color(red: 0.953, green: 0.937, blue: 0.910)
    static let comment = Color(red: 0.580, green: 0.541, blue: 0.486)
    static let codeString = Color(red: 0.655, green: 0.769, blue: 0.557)
    static let keyword = Color(red: 0.910, green: 0.580, blue: 0.345)
    static let typeName = Color(red: 0.780, green: 0.745, blue: 0.540)

    private static let keywords: Set<String> = [
        "as", "async", "await", "break", "const", "continue", "crate", "else", "enum",
        "extern", "false", "fn", "for", "if", "impl", "in", "let", "loop", "match",
        "mod", "move", "mut", "pub", "ref", "return", "self", "Self", "static",
        "struct", "super", "trait", "true", "type", "unsafe", "use", "where", "while",
        "dyn",
    ]

    private static let types: Set<String> = [
        "i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128",
        "usize", "f32", "f64", "bool", "char", "str", "String", "Vec", "Option",
        "Result", "Ok", "Err", "Some", "None", "Box", "HashMap",
    ]

    static func highlight(_ source: String) -> AttributedString {
        var result = AttributedString()
        let chars = Array(source)
        var index = 0

        func emit(_ text: String, _ color: Color) {
            guard !text.isEmpty else { return }
            var part = AttributedString(text)
            part.foregroundColor = color
            result += part
        }

        while index < chars.count {
            if chars[index] == "/", index + 1 < chars.count, chars[index + 1] == "/" {
                let start = index
                index += 2
                while index < chars.count, chars[index] != "\n" { index += 1 }
                emit(String(chars[start..<index]), comment)
                continue
            }
            if chars[index] == "\"" {
                let start = index
                index += 1
                while index < chars.count {
                    if chars[index] == "\\" {
                        index = min(index + 2, chars.count)
                        continue
                    }
                    if chars[index] == "\"" {
                        index += 1
                        break
                    }
                    index += 1
                }
                emit(String(chars[start..<index]), codeString)
                continue
            }
            if chars[index].isLetter || chars[index] == "_" {
                let start = index
                index += 1
                while index < chars.count,
                      chars[index].isLetter || chars[index].isNumber || chars[index] == "_" {
                    index += 1
                }
                let word = String(chars[start..<index])
                if keywords.contains(word) {
                    emit(word, keyword)
                } else if types.contains(word) {
                    emit(word, typeName)
                } else {
                    emit(word, codeText)
                }
                continue
            }
            emit(String(chars[index]), codeText)
            index += 1
        }
        return result
    }
}

struct RichText: View {
    let text: String

    var body: some View {
        styled
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
    }

    private var styled: Text {
        let parts = text.components(separatedBy: "`")
        var out = Text(verbatim: "")
        for (index, part) in parts.enumerated() {
            if index.isMultiple(of: 2) {
                out = out + Text(verbatim: part)
            } else {
                out = out + Text(verbatim: part)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(Theme.rust)
            }
        }
        return out
    }
}

struct CodeBlock: View {
    let source: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(Theme.highlight(source))
                .font(.system(.subheadline, design: .monospaced))
                .lineSpacing(4)
                .padding(14)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.codeBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct NoteBlock: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Watch for")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.rust)
            RichText(text: text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.rust.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
