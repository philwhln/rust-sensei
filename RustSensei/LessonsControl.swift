import Foundation

let controlLessons: [Lesson] = [
    lesson("if", "control", "if and loops", minutes: 4, [
        .prose("`if` does not use parentheses. The condition has to be a `bool`. Numbers are not truthy. `if n { }` does not compile when `n` is an integer."),
        .prose("`if` is an expression. Both branches have to have the same type, and you can bind the result."),
        .code("""
        let n = 2;
        let label = if n == 0 { "zero" } else { "some" };
        """),
        .prose("`loop` repeats until `break`. `while` repeats while a condition holds. `for` walks an iterator. `0..3` yields 0, 1, and 2. `0..=3` includes 3."),
        .code("""
        let mut total = 0;
        for n in 0..3 {
            total += n;
        }

        let found = loop {
            break 10;
        };
        """),
        .prose("`break` inside `loop` can produce a value, so `loop` itself can be an expression. `break` inside `for` or `while` cannot carry a value. `continue` skips to the next pass."),
        .note("`for n in 0..3` does not include 3. The `=` in `..=` is the included end."),
    ], [
        ask(
            "if-1",
            "Does this compile?",
            [
                "Yes. 1 is true",
                "Yes. Any non-zero integer is true",
                "No. The condition must be a bool",
                "No. if requires parentheses",
            ],
            2,
            "Rust has no truthiness. An `if` condition is a `bool`. Compare the integer, as in `if n != 0`.",
            code: """
            let n = 1;
            if n {
                println!("yes");
            }
            """
        ),
        ask(
            "if-2",
            "Does this compile?",
            [
                "Yes. n can be either an integer or a string",
                "No. The two branches have different types",
                "Yes. The else branch is ignored",
                "No. if cannot be used as an expression",
            ],
            1,
            "`if` is an expression, and both branches must produce the same type. An `i32` and a string slice are not the same type.",
            code: """
            let n = if true { 1 } else { "no" };
            """
        ),
        ask(
            "if-3",
            "Which values does `for n in 0..3` bind to `n`?",
            [
                "0, 1, 2, and 3",
                "0, 1, and 2",
                "1, 2, and 3",
                "0 and 1 only",
            ],
            1,
            "`..` excludes the end. `0..3` is 0, 1, and 2. Write `0..=3` when 3 should be included."
        ),
    ]),

    lesson("match", "control", "match", minutes: 4, [
        .prose("`match` compares a value against patterns, and it has to cover every case. The compiler checks. Add a variant to an enum and forget a match, and the project stops compiling. That is the point."),
        .code("""
        let n = 2;
        let label = match n {
            0 => "zero",
            1 | 2 => "small",
            _ => "other",
        };
        """),
        .prose("Arms are tried in order. The first pattern that fits wins. `_` fits anything, so it belongs last. Put it first and every later arm is unreachable. The compiler warns. The value still comes from the first arm."),
        .prose("`match` is an expression. Every arm returns the same type. You can bind what is inside a value:"),
        .code("""
        let value = Some(4);
        match value {
            Some(n) => println!("{n}"),
            None => println!("none"),
        }
        """),
        .note("`_` throws the value away. If you meant to use it, give it a name: `other => println!(\"{other}\")`. An unused name warns. `_` does not."),
    ], [
        ask(
            "match-1",
            "A `match` on an enum skips one variant and has no `_`. What happens?",
            [
                "It compiles, and panics if that variant shows up",
                "It compiles, and skips that variant at run time",
                "It does not compile",
                "It compiles only in a release build",
            ],
            2,
            "`match` is exhaustive. Every variant has to be handled, or a `_` arm has to cover the rest. Adding a variant without updating the match is a compile error, which is what you want."
        ),
        ask(
            "match-2",
            "What is `label` when `n` is 2?",
            [
                "two, because 2 is the more specific arm",
                "any, because the first matching arm wins",
                "It does not compile, because the arms overlap",
                "It does not compile, because _ is required to be last",
            ],
            1,
            "Arms are tried in order and the first match wins. `_` matches 2, so the later arm never runs. Rust warns that the `2` arm is unreachable. The code compiles, and `label` is `any`.",
            code: """
            let label = match n {
                _ => "any",
                2 => "two",
            };
            """
        ),
        ask(
            "match-3",
            "What does `_` mean in a pattern?",
            [
                "It matches only the unit value",
                "It matches anything, and discards the value",
                "It repeats the previous arm",
                "It is a variable you can print",
            ],
            1,
            "`_` is the catch-all. It fits any value and does not bind a name, so you cannot use the value in that arm. A name such as `other` would bind it."
        ),
    ]),

    lesson("option", "control", "Option", minutes: 4, [
        .prose("Rust has no null. Absence is `Option<T>`, an enum with two variants: `Some(value)` and `None`. `Option<i32>` is either an `i32` or nothing. You cannot get at the `i32` without dealing with `None`."),
        .code("""
        let n: Option<i32> = Some(3);
        let missing: Option<i32> = None;

        let doubled = n.map(|x| x + 1);       // Some(4)
        let still = missing.map(|x| x + 1);   // None
        """),
        .prose("`map` runs the closure only for `Some`. `None` stays `None`, and the closure is not called. `unwrap` returns the inner value, or panics on `None`. `unwrap_or(0)` returns the inner value or the default you passed. `if let Some(x) = n` runs its block only for `Some`."),
        .prose("A panic is for a bug: a `None` that means the program is wrong. A missing entry or a failed lookup is ordinary. Leave it as an `Option` and handle it."),
        .note("`unwrap` is fine in an example and in a test. `unwrap` on a user's input, or on a file that might be missing, will take the program down. Prefer `if let`, `match`, `unwrap_or`, or `?`."),
    ], [
        ask(
            "option-1",
            "What does `None.map(|x| x + 1)` return when the option is `Option<i32>`?",
            [
                "Some(1)",
                "0",
                "None, and the closure does not run",
                "It panics",
            ],
            2,
            "`map` on `None` returns `None` and does not call the closure. On `Some(3)` the same map would return `Some(4)`."
        ),
        ask(
            "option-2",
            "What does `unwrap` do when the value is `None`?",
            [
                "It returns 0",
                "It returns None",
                "It panics",
                "It turns the Option into a Result",
            ],
            2,
            "`unwrap` returns the inner value of `Some` and panics on `None`. Use it when `None` means a bug. For a normal absence, use `unwrap_or`, `if let`, or `match`."
        ),
        ask(
            "option-3",
            "Why does Rust use `Option` instead of null?",
            [
                "So every value takes more memory, with no other effect",
                "So absence is in the type, and you handle it before using the value",
                "Because an Option is faster than a pointer in every program",
                "So that unwrap is required on every variable",
            ],
            1,
            "A null pointer can be forgotten and then dereferenced. `Option` makes the missing case part of the type. The compiler will not let you use the inner value until you have handled `None`."
        ),
    ]),

    lesson("result", "control", "Result", minutes: 4, [
        .prose("`Result<T, E>` is the enum for an operation that can fail and be recovered from. `Ok(value)` is success. `Err(error)` is failure. The error is a value with a type. It is not an exception thrown past the caller."),
        .code("""
        fn half(n: i32) -> Result<i32, String> {
            if n % 2 == 0 {
                Ok(n / 2)
            } else {
                Err(String::from("odd"))
            }
        }
        """),
        .prose("Callers handle it with `match`, with `if let Ok(n) = half(2)`, or with `?`, which has its own lesson. `unwrap` and `expect` panic on `Err`. `expect` panics with the message you wrote. Use them when failure means a bug. A library that hits an ordinary failure returns `Result`. It does not panic."),
        .prose("`Result` is marked `must_use`. Calling `half(2);` and dropping the value produces a warning. The failure would have vanished."),
        .note("`Option` is absence. `Result` is a failure that carries a reason. A missing map entry is an `Option`. A string that was supposed to be a number is a `Result`. A panic is a third thing: the program stops because a bug happened."),
    ], [
        ask(
            "result-1",
            "What is `Err`?",
            [
                "A panic that unwinds the stack immediately",
                "A variant that carries an error value",
                "Null",
                "A warning printed by cargo",
            ],
            1,
            "`Err` is one variant of `Result`. It holds a value of the error type, and the caller decides what to do with it. It does not, by itself, stop the program."
        ),
        ask(
            "result-2",
            "What does `unwrap` do on `Err`?",
            [
                "It returns the error as an empty string",
                "It turns the error into None",
                "It panics",
                "It calls the function again",
            ],
            2,
            "`unwrap` on `Err` panics. `expect` panics too, and includes your message. Both are for bugs. Recoverable failure stays a `Result`."
        ),
        ask(
            "result-3",
            "Which split matches the usual Rust style?",
            [
                "Result for recoverable failure, panic for bugs",
                "Panic for every failure, so callers write less",
                "Option for every error, and Result unused",
                "Result only inside tests",
            ],
            0,
            "A failure you expect, bad input, a missing file, a parse error, comes back as `Err`. A panic means a bug: an invariant broke, or an index was used that the program itself knows is valid."
        ),
    ]),
]
