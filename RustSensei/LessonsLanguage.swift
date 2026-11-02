import Foundation

let languageLessons: [Lesson] = [
    lesson("why", "language", "What Rust is for", minutes: 4, [
        .prose("Rust is for programs that need to be fast and careful with memory. A server, a game, a command-line tool, a library another language calls. There is no garbage collector. The compiler decides, before the program runs, when memory is freed."),
        .prose("That check is the borrow checker. It rejects programs that would use memory after freeing it, or change the same data from two threads at once without coordination. Those bugs become compile errors. Safe Rust stops data races. It does not stop deadlocks, infinite loops, or ordinary logic bugs."),
        .prose("You will feel the compiler argue with you. Read the first line of the error, then the note under it. It usually says what to change. This course is the core of the language. Async, macros, and unsafe come later. You still want a compiler. Install Rust from rustup.rs, then:"),
        .code("""
        cargo new hello
        cd hello
        cargo run
        """),
        .prose("`cargo new` makes a package. `cargo run` builds it if needed and runs the program. `cargo test` runs the tests. The file you start in is `src/main.rs`."),
        .note("When something fails to compile, the program never got the chance to crash in that way. Keep the error. It is part of the answer."),
    ], [
        ask(
            "why-1",
            "What does the borrow checker do?",
            [
                "It frees memory while the program runs, like a garbage collector",
                "It rejects unsafe memory use before the program runs",
                "It slows the program down to watch every read and write",
                "It checks only the tests you wrote",
            ],
            1,
            "The borrow checker runs during compilation. It refuses programs that would use freed memory or cause a data race. It is not a garbage collector, and those checks are not repeated on every read in the finished binary."
        ),
        ask(
            "why-2",
            "What does `cargo run` do?",
            [
                "It only downloads dependencies",
                "It formats the code and exits",
                "It builds the package if needed, then runs it",
                "It publishes the package to crates.io",
            ],
            2,
            "`cargo run` compiles the current package when the binary is out of date, then runs that binary. Publishing is `cargo publish`. Formatting is `cargo fmt`."
        ),
        ask(
            "why-3",
            "Which bug does safe Rust refuse to compile?",
            [
                "A deadlock between two locks",
                "An infinite loop",
                "A data race on shared mutable state",
                "A wrong answer from a function",
            ],
            2,
            "Safe Rust rejects data races: unsynchronized access to the same data from more than one thread, where at least one access writes. Deadlocks, infinite loops, and ordinary logic bugs still compile."
        ),
    ]),

    lesson("let", "language", "let, mut, and shadowing", minutes: 4, [
        .prose("`let` binds a name to a value. The name is immutable. You can read it. You cannot assign over it."),
        .code("""
        let x = 1;
        // x = 2; // rejected
        let mut n = 0;
        n += 1;
        """),
        .prose("`mut` belongs to the binding, not to the type. `n` is an `i32` either way. `mut` means this name may be assigned again."),
        .prose("Shadowing is a new binding with the same name. The new binding can have a different type. The right-hand side still sees the old binding."),
        .code("""
        let s = "5";
        let s: i32 = s.parse().unwrap();
        """),
        .prose("After that, `s` is the integer 5. The string is gone. This is not mutation. It is a new variable that hides the old one. Use `mut` when the same value changes, such as a counter or a `Vec` you `push` onto. Use shadowing when you want to replace a name, often with a new type."),
        .note("`mut` does not change the type, and it does not let you skip the borrow rules. It only allows assignment through that name."),
    ], [
        ask(
            "let-1",
            "Does this compile?",
            [
                "Yes. Integers can always be assigned",
                "Yes. This is shadowing",
                "No. x was not declared with mut",
                "No. 2 has a different type from 1",
            ],
            2,
            "`let` without `mut` cannot be assigned to. `let mut x = 1;` followed by `x = 2;` would compile. Shadowing would be a second `let`, which this code does not have.",
            code: """
            let x = 1;
            x = 2;
            """
        ),
        ask(
            "let-2",
            "What is `s` after this code?",
            [
                "The string 5",
                "The integer 5",
                "It does not compile. A name cannot change type",
                "It does not compile. parse returns a Result, so unwrap is illegal",
            ],
            1,
            "The second `let` shadows the first. The right-hand side parses the old string. `5` parses, `unwrap` takes the value out of `Ok`, and the new `s` is an `i32`. Shadowing is allowed to change the type.",
            code: """
            let s = "5";
            let s: i32 = s.parse().unwrap();
            """
        ),
        ask(
            "let-3",
            "You want to call `push` twice on one `Vec`. What does that binding need?",
            [
                "A plain let, and a later shadow with the same name",
                "let mut, on the binding that owns the Vec",
                "The mut keyword in front of the type, as in let v = mut Vec",
                "Nothing. A Vec is always mutable",
            ],
            1,
            "`push` changes the vector, so the binding has to be `mut`. A shadow makes a new binding. It does not make the old vector mutable. `mut` is written on the binding: `let mut v`."
        ),
    ]),

    lesson("types", "language", "The common types", minutes: 5, [
        .prose("Integers carry a size in the name. `i32` is a signed 32-bit integer, and it is the default when the compiler has nothing else to go on. `i64` is bigger. `u32` is unsigned. `usize` is the unsigned integer the size of a pointer. Lengths and indexes use `usize`."),
        .prose("`f64` is the default floating-point type. `bool` is `true` or `false`. `char` is one Unicode scalar value, not a byte. It is four bytes wide. The character `é` is one `char` and two bytes of UTF-8."),
        .code("""
        let n = 1;            // i32
        let x = 1.0;          // f64
        let c = 'é';          // char
        let big: u64 = 9;
        let index: usize = 0;
        """),
        .prose("A tuple packs mixed values, written `(i32, bool)`. Read the fields with `.0` and `.1`. An array packs one type and a fixed length, and the length is part of the type. `[i32; 3]` and `[i32; 4]` are different types. A `Vec<i32>` is the growable version."),
        .prose("`String` owns text. `&str` borrows text. A string literal has type `&str`, and it lives for the whole program."),
        .note("In a debug build, adding 1 to a `u8` that holds 255 panics. Overflow is a bug unless you ask for wrapping with `wrapping_add`, or for an `Option` with `checked_add`. A release build wraps instead of panicking. Do not rely on the wrap."),
    ], [
        ask(
            "types-1",
            "What is a `char`?",
            [
                "One byte, as in C",
                "A Unicode scalar value",
                "An owned growable string",
                "Always a single UTF-8 byte",
            ],
            1,
            "A `char` is one Unicode scalar value and takes four bytes. UTF-8 bytes are not chars. `é` is one char and two bytes. Owned text is a `String`."
        ),
        ask(
            "types-2",
            "Which type do you use for a vector's length and for indexing?",
            [
                "i32, because it is the default integer",
                "u8, because indexes are small",
                "usize",
                "f64",
            ],
            2,
            "`usize` is the pointer-sized unsigned integer. `Vec` lengths and indexes use it. A plain `0` written in `v[0]` is inferred as `usize` there, not left as `i32`."
        ),
        ask(
            "types-3",
            "What is the difference between `[i32; 3]` and `Vec<i32>`?",
            [
                "They are the same type",
                "The array's length is fixed and part of its type. The Vec can grow",
                "The array can grow. The Vec cannot",
                "The array holds owned values. The Vec holds references only",
            ],
            1,
            "`[i32; 3]` has room for exactly three `i32` values, and the 3 is part of the type. A `Vec<i32>` owns a buffer that can grow when you `push`."
        ),
    ]),

    lesson("fn", "language", "Functions", minutes: 4, [
        .prose("A function names its parameter types and its return type. The last expression is the return value. There is no semicolon on that line. A semicolon turns an expression into a statement and throws the value away, leaving the unit type `()`."),
        .code("""
        fn add(a: i32, b: i32) -> i32 {
            a + b
        }

        fn ignore() {
            add(1, 2);
        }
        """),
        .prose("`add(1, 2);` with the semicolon runs the function and discards the `i32`. `ignore` returns `()`. That is what a function returns when you write no `->` clause. `main` is `fn main()`."),
        .prose("`return` exists, and you use it to leave early. You do not need it on the last line."),
        .code("""
        fn half(n: i32) -> i32 {
            if n < 0 {
                return 0;
            }
            n / 2
        }
        """),
        .note("A trailing semicolon is the usual reason a function returns `()` when you asked for an `i32`. The compiler says it expected `i32` and found `()`. Delete the semicolon, or write `return`."),
    ], [
        ask(
            "fn-1",
            "What does this function return?",
            [
                "It does not compile",
                "7",
                "The unit value ()",
                "Nothing. Rust functions cannot return integers",
            ],
            1,
            "The last line is an expression with no semicolon, and the return type is `i32`. The value of that expression, 7, is what the function returns.",
            code: """
            fn value() -> i32 {
                7
            }
            """
        ),
        ask(
            "fn-2",
            "What is wrong here?",
            [
                "Nothing",
                "The semicolon makes the block return (), not an i32",
                "7 is not a valid integer literal",
                "The function is missing mut",
            ],
            1,
            "The semicolon discards 7, so the block's value is `()`. The signature promised an `i32`. Drop the semicolon.",
            code: """
            fn value() -> i32 {
                7;
            }
            """
        ),
        ask(
            "fn-3",
            "What is `()`?",
            [
                "Null",
                "The type of a function that returns no useful value",
                "An empty string",
                "The error type",
            ],
            1,
            "`()` is the unit type. It has one value, also written `()`. Functions with no `->` clause return it. Rust does not have null."
        ),
    ]),
]
