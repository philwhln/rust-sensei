import Foundation

let errorLessons: [Lesson] = [
    lesson("returning", "errors", "Returning Result", minutes: 4, [
        .prose("A function that can fail in a way the caller might handle returns `Result`. The error type is part of the signature. Callers can see it without reading the body."),
        .code("""
        fn parse_age(s: &str) -> Result<u32, std::num::ParseIntError> {
            s.parse()
        }
        """),
        .prose("`str::parse` already returns a `Result`. This function hands that result straight back. There is no extra `Ok` around it, because the types already match. When you build the result yourself, you write `Ok(value)` or `Err(error)`."),
        .prose("The caller chooses the policy. A form can show the message. A parser can skip the line. `main` can stop. The function does not choose by panicking."),
        .code("""
        parse_age("nope"); // warning: unused Result
        """),
        .prose("`Result` is `must_use`. Throwing the value away warns. The failure would sit in a value nobody read. Bind it, pass it through `?`, or match on it."),
        .note("`parse` needs to know the target type. Inside `parse_age` the return type supplies `u32`. On a `let`, write the type on the binding, or use `parse::<u32>()`. That `::<u32>` is the turbofish. It passes the type when nothing else states it."),
    ], [
        ask(
            "returning-1",
            "Where does a caller see what can go wrong?",
            [
                "Only in a comment above the function",
                "In the error type of the return type",
                "Only in a panic message at run time",
                "From cargo, after the crate is published",
            ],
            1,
            "The signature `Result<u32, ParseIntError>` says success is a `u32` and failure is a parse error. The caller handles that type. A comment can help, and it is not what the compiler checks."
        ),
        ask(
            "returning-2",
            "What happens if you call `parse_age` and ignore the value?",
            [
                "It panics when the text is not a number",
                "It compiles, with a warning that the Result was unused",
                "It returns 0 from main",
                "It is a hard error, because every Result must be bound with let",
            ],
            1,
            "Unused `Result` is the `unused_must_use` warning. The call itself does not panic. The `Err` is inside the value you dropped. Warnings do not stop the build unless you ask them to. Handle the result anyway."
        ),
        ask(
            "returning-3",
            "In `parse_age`, how does `parse` know the number should be a `u32`?",
            [
                "parse always produces a u32",
                "It looks at the characters and guesses",
                "From the function's return type",
                "From the letters in the function's name",
            ],
            2,
            "The function returns `Result<u32, ParseIntError>`, so `s.parse()` is inferred as that same type. When no return type supplies it, annotate the `let` or write `parse::<u32>()`."
        ),
    ]),

    lesson("question", "errors", "The ? operator", minutes: 5, [
        .prose("`?` is the early return for `Result` and for `Option`. On `Ok(value)` or `Some(value)`, it unwraps, and the function continues. On `Err` or `None`, the function returns immediately with that failure."),
        .code("""
        fn double(s: &str) -> Result<i32, std::num::ParseIntError> {
            let n: i32 = s.parse()?;
            Ok(n * 2)
        }
        """),
        .prose("The function has to return a compatible `Result` or `Option`. `?` on a `Result` inside a function that returns `Option` does not compile, and the reverse does not either."),
        .prose("If the inner error type does not match the function's error type, `?` converts it with the `From` trait. No `From` impl means a compile error, not a cast at run time. `.map_err(...)?` is how you convert when `From` does not already do it."),
        .prose("`?` is legal in `main` when `main` returns a `Result`. On `Err`, the program prints the error and exits with a failure status."),
        .note("`v.first()` returns `Option`. `?` on that `Option` needs a function that returns `Option`. In a function that returns `Result`, convert first, for example with `ok_or`, and then apply `?`. The question mark does not guess which error you meant."),
    ], [
        ask(
            "question-1",
            "What does `?` do when the value is `Ok(4)`?",
            [
                "It returns Ok(4) from the function immediately",
                "It yields 4, and the function continues",
                "It panics",
                "It converts 4 into an error",
            ],
            1,
            "On `Ok`, `?` unwraps the success value and execution continues at the next line. The early return happens only for `Err`."
        ),
        ask(
            "question-2",
            "What does `?` do when the value is `Err`?",
            [
                "It panics",
                "It turns the error into None and continues",
                "It returns from the function with that error, converting with From if the types differ",
                "It calls the function again",
            ],
            2,
            "`?` on `Err` leaves the function now. If the error type matches, it returns that `Err`. If a `From` impl can convert it into the function's error type, it converts and then returns. It does not panic."
        ),
        ask(
            "question-3",
            "Does this compile?",
            [
                "Yes. ? works on Option inside any function",
                "Yes. A missing element becomes an empty Err",
                "No. first returns Option, and this function returns Result",
                "No. Slices have no first method",
            ],
            2,
            "`v.first()` is `Option<&i32>`. `?` on an `Option` requires the function to return an `Option`. This one returns a `Result`, so it does not compile. Convert with `ok_or` before `?` if a `Result` is what you need.",
            code: """
            fn first(v: &[i32]) -> Result<i32, String> {
                let n = v.first()?;
                Ok(*n)
            }
            """
        ),
    ]),

    lesson("own-error", "errors", "An error of your own", minutes: 5, [
        .prose("When a function fails in more than one way, the error type is an enum. Each variant is one way, and it can hold the detail for that way."),
        .code("""
        enum AgeError {
            Empty,
            NotANumber(std::num::ParseIntError),
        }

        fn parse_age(s: &str) -> Result<u32, AgeError> {
            if s.is_empty() {
                return Err(AgeError::Empty);
            }
            let n: u32 = s.parse().map_err(AgeError::NotANumber)?;
            Ok(n)
        }
        """),
        .prose("`map_err(AgeError::NotANumber)` turns the parse error into `AgeError`. The variant's constructor is a function from `ParseIntError` to `AgeError`. `?` then returns it if parsing failed. For `?` to do that conversion by itself, implement `From`."),
        .code("""
        impl From<std::num::ParseIntError> for AgeError {
            fn from(err: std::num::ParseIntError) -> Self {
                AgeError::NotANumber(err)
            }
        }
        """),
        .prose("With that impl, `s.parse()?` converts on its own inside a function that returns `Result<u32, AgeError>`. Real projects often generate `From` and `Display` with the `thiserror` crate. The impl above is the whole mechanism."),
        .prose("Library code returns `Result` for problems the caller should expect: empty input, a bad number, a missing file. It panics for a broken invariant, such as an index the caller was required to keep valid."),
        .note("`?` does not need `Display`. Printing from `main` needs `Debug` on the error, so derive `Debug` on the enum. Implement `Display` when a person will read the message."),
    ], [
        ask(
            "own-error-1",
            "Why make the error an enum?",
            [
                "An enum cannot be returned, so the caller must panic",
                "Each variant is one way the function fails, and it can hold data for that way",
                "So the function panics with a typed value",
                "So the caller can ignore the failure",
            ],
            1,
            "An enum lists the failures. `Empty` carries nothing. `NotANumber` carries the parse error that caused it. The caller matches on the variant and handles each case."
        ),
        ask(
            "own-error-2",
            "What lets `?` turn a `ParseIntError` into `AgeError` on its own?",
            [
                "A Display impl for AgeError",
                "An impl of From<ParseIntError> for AgeError",
                "The error type being String",
                "mut on the function",
            ],
            1,
            "`?` converts with `From`. `impl From<ParseIntError> for AgeError` is the conversion. `Display` is for printing. `map_err` is the manual version of the same conversion, used when you do not want a `From` impl."
        ),
        ask(
            "own-error-3",
            "A user typed text that is not a number. What should library code do?",
            [
                "Panic, so the bug is obvious",
                "Call unwrap, which does not panic",
                "Return Err with an error value the caller can handle",
                "Return 0 and continue",
            ],
            2,
            "Bad input is an expected failure, so it is an `Err`. `unwrap` does panic. Returning 0 hides the failure. The caller decides whether bad input stops the program."
        ),
    ]),
]
