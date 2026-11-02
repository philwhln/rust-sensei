import Foundation

let lifetimeLessons: [Lesson] = [
    lesson("why-life", "lifetimes", "Why lifetimes exist", minutes: 4, [
        .prose("A reference does not own its target. Something else does, and that something has to still be alive. The compiler checks. When a signature is ambiguous, the check has a name: a lifetime."),
        .prose("Most functions never write one. The rule is the one you already met. This function does not compile. The compiler often starts with `missing lifetime specifier`. Name a lifetime, and the real error comes through: the reference points at a local."),
        .code("""
        fn bad<'a>() -> &'a str {
            let s = String::from("hi");
            &s
        }
        """),
        .prose("`s` dies at the end of `bad`. The returned reference would point at freed memory. Naming `'a` does not keep `s` alive. It only labels the borrow. The fix is to return an owned `String`, or to borrow from the caller."),
        .code("""
        fn good(s: &str) -> &str {
            s
        }
        """),
        .prose("Here the reference comes in from the caller. The caller owns the text, or borrowed it from someone who does. The function hands the same borrow back. No local is left behind."),
        .note("A lifetime is checked at compile time and then erased. The running program does not carry lifetime data, and it does not check the rule again. A lifetime is not a value you construct, and it is not a timer."),
    ], [
        ask(
            "why-life-1",
            "Why is `bad` rejected, even after a lifetime is written on the signature?",
            [
                "&str is not allowed as a return type",
                "The reference would point at a local that is about to be dropped",
                "String cannot be borrowed",
                "Functions are not allowed to return references",
            ],
            1,
            "The local `String` is dropped when the function returns. A reference to it would dangle. A lifetime name does not extend the local. Return a `String`, or return a borrow of an argument."
        ),
        ask(
            "why-life-2",
            "When do lifetime checks run?",
            [
                "On every read, while the program runs",
                "At compile time. After that they are gone, and they cost nothing at run time",
                "Only when cargo test runs",
                "When the String is dropped",
            ],
            1,
            "Lifetimes are a compile-time proof. The compiler erases them. The binary does not store them, and it does not re-check them on each read."
        ),
        ask(
            "why-life-3",
            "What is a lifetime?",
            [
                "A value you build with a constructor",
                "A name for how long a borrow is valid",
                "A thread",
                "The capacity field of a String",
            ],
            1,
            "A lifetime connects a reference to the borrow it came from. It tells the compiler which owner has to stay alive. It is not a run-time object."
        ),
    ]),

    lesson("elision", "lifetimes", "Naming a lifetime", minutes: 5, [
        .prose("`good` did not name a lifetime. The compiler filled one in. That is elision. The rule you use most: one input reference lends its lifetime to the output references."),
        .code("""
        fn good<'a>(s: &'a str) -> &'a str {
            s
        }
        """),
        .prose("That is the signature the compiler writes for you. `'a` means the borrow of `s`. The returned `&str` is valid for as long as that borrow."),
        .prose("Two input references are ambiguous. This does not compile, because the result might be either argument:"),
        .code("""
        fn longest(x: &str, y: &str) -> &str {
            if x.len() > y.len() { x } else { y }
        }
        """),
        .prose("You name one lifetime and tie all three together. The caller then has to keep both arguments alive for as long as they use the result. The function might return either one, so the honest promise is the overlap of the two borrows."),
        .code("""
        fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
            if x.len() > y.len() { x } else { y }
        }
        """),
        .prose("A method with `&self` gets one more elision rule. An output reference takes the lifetime of `self`, unless you write something else."),
        .code("""
        struct User {
            name: String,
        }

        impl User {
            fn name(&self) -> &str {
                &self.name
            }
        }
        """),
        .note("`'a` does not mean long or short by itself. It connects positions in one signature. The same name means these borrows are one stretch. A second, independent borrow would get a second name."),
    ], [
        ask(
            "elision-1",
            "A function takes one `&str` and returns a `&str` borrowed from that argument. Do you have to write a lifetime?",
            [
                "Yes, on every function that returns a reference",
                "No. The single input lifetime is used for the output",
                "Yes, unless the function is main",
                "No. Every returned reference is 'static",
            ],
            1,
            "Elision applies when there is exactly one input lifetime. The compiler assigns it to every output reference. You write the name yourself when more than one input makes the output ambiguous."
        ),
        ask(
            "elision-2",
            "Why does `longest` need an explicit lifetime?",
            [
                "Because len can panic",
                "Two inputs could each be the output, so you have to say how the borrows connect",
                "Because &str is an owned type",
                "Because the body uses if, and if requires a lifetime",
            ],
            1,
            "The returned reference might be `x` or `y`. With two input lifetimes, elision will not choose. One lifetime on both inputs and the output says the result is valid only while both arguments are."
        ),
        ask(
            "elision-3",
            "In `fn name(&self) -> &str` that returns a borrow of `self.name`, what does the result borrow?",
            [
                "A new String allocated inside the method",
                "The User behind self. The reference cannot outlive that borrow",
                "A 'static literal stored in the binary",
                "Nothing. The characters are copied into the reference",
            ],
            1,
            "Elision ties the output to `&self`. The `&str` borrows the `User`'s `name` field. When the borrow of the `User` ends, the `&str` must have ended too. It does not allocate, and it is not `'static`."
        ),
    ]),

    lesson("static-life", "lifetimes", "'static, and when to own", minutes: 4, [
        .prose("`\'static` is the lifetime of the whole program. String literals are `&'static str`. The bytes are in the binary. That borrow cannot dangle."),
        .code("""
        let s: &'static str = "hello";
        """),
        .prose("A bound `T: 'static` does not mean this value lives forever. It means the type contains no shorter borrow. An owned `String` satisfies `'static`, because a `String` does not borrow anything. A local `String` can still be dropped at the end of its scope. The bound is about the type, not about pinning one value in memory until exit."),
        .prose("`&'a str` satisfies `T: 'static` only when `'a` itself is `'static`. A borrow of a local does not qualify."),
        .prose("When a lifetime error gets tangled, the practical move is often to own the data. Return a `String` instead of a `&str`. Clone at the boundary between components. Borrowing is the right default inside a function. Ownership is the right boundary when the result has to leave."),
        .prose("Marking the return type `&'static str` does not save a reference to a local. `'static` is a promise the reference lives for the whole program. A local cannot keep that promise, so the function still fails."),
        .code("""
        fn bad() -> &'static str {
            let s = String::from("hi");
            &s
        }
        """),
        .note("Use `'static` on a reference when the data really is in the binary, or was leaked for the whole process. Use an owned `String` or `Vec` when the data is built at run time and has to outlive the function that built it."),
    ], [
        ask(
            "static-1",
            "What is the type of the literal `hello` written in double quotes?",
            [
                "String",
                "&'static str",
                "&String",
                "str, with no reference",
            ],
            1,
            "A string literal is `&'static str`. The text is in the binary, and the borrow lasts as long as the program. `String::from` or `.to_string()` is what makes an owned `String`."
        ),
        ask(
            "static-2",
            "A function asks for `T: 'static`. Can you pass a local `String`?",
            [
                "No. A local value is never 'static",
                "Yes. String holds no borrow, so the type fits. The value can still be dropped",
                "Yes, and that String is then kept until the process exits",
                "No. Only string literals satisfy 'static",
            ],
            1,
            "`T: 'static` means the type contains no non-`'static` reference. `String` owns its buffer, so it qualifies, including a `String` that is about to go out of scope. The bound does not keep that value alive."
        ),
        ask(
            "static-3",
            "Does writing the return type as `&'static str` make a reference to a local `String` compile?",
            [
                "Yes. 'static extends the local to the end of the program",
                "Yes, if the local is also mut",
                "No. The local still dies, and 'static is a promise it cannot keep",
                "No. 'static is only legal on integers",
            ],
            2,
            "The annotation is a claim that the reference is valid forever. The local is dropped at the end of the function. The claim is false, so the code does not compile. Return the `String` itself if the caller should own it."
        ),
    ]),
]
