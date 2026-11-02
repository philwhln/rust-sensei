import Foundation

let ownershipLessons: [Lesson] = [
    lesson("owner", "ownership", "Values have one owner", minutes: 4, [
        .prose("Every value has one owner. The owner is a variable. When the owner's scope ends, Rust drops the value. For a `String` or a `Vec`, that frees the heap buffer. You do not call `free`."),
        .prose("Ownership moves. Assigning a `String` to a new name, or passing it to a function by value, moves it. The old name is then unusable. The heap buffer stays where it is. The move copies the small header, a pointer, a length, and a capacity, and invalidates the source."),
        .code("""
        let s = String::from("hi");
        let t = s;
        // println!("{s}"); // rejected: s was moved
        println!("{t}");
        """),
        .prose("`i32` does not behave this way. It is `Copy`, which is the next lesson but one. `String`, `Vec`, and most structs move. A function that takes `String` takes ownership. The caller cannot use the value afterward unless the function gives it back."),
        .note("A move is not a deep copy. If you need a second independent `String`, call `.clone()`. If you only need to look, borrow with `&`. Borrowing is the usual fix."),
    ], [
        ask(
            "owner-1",
            "After this code, which names can you use?",
            [
                "Both s and t",
                "Only s",
                "Only t",
                "Neither. String cannot be assigned",
            ],
            2,
            "Assigning a `String` moves it. `t` is the owner. `s` is spent, and reading `s` is a compile error. The characters were not copied into a second buffer.",
            code: """
            let s = String::from("hi");
            let t = s;
            """
        ),
        ask(
            "owner-2",
            "Who frees the heap buffer of a `String`?",
            [
                "The programmer, with a call to free",
                "The owner, when the owner goes out of scope",
                "The borrow checker, while the program is running",
                "The first function that reads the string",
            ],
            1,
            "Drop runs when the owner goes out of scope. For `String`, drop frees the buffer. The borrow checker decides whether the program is allowed to compile. It does not free memory at run time."
        ),
        ask(
            "owner-3",
            "A function is declared `fn consume(s: String)`. The caller writes `consume(s)`. What happens to the caller's `s`?",
            [
                "The caller keeps s, and the function gets a copy of the text",
                "s is borrowed for the call and then returned",
                "s is moved into the function, and the caller cannot use it",
                "It compiles only if s is an i32",
            ],
            2,
            "A parameter of type `String` takes ownership. The call moves `s` in. When `consume` returns, it drops that `String` unless it moves the value somewhere else, such as a return value."
        ),
    ]),

    lesson("move", "ownership", "Moves", minutes: 4, [
        .prose("A `String` is three words on the stack, plus the bytes on the heap. A move copies those three words and marks the old variable dead. The bytes stay put. That is why moving a large vector is cheap, and why two owners would be a bug. Both would free the same buffer."),
        .code("""
        fn consume(s: String) {
            println!("{s}");
        }

        let s = String::from("hi");
        consume(s);
        // println!("{s}");
        """),
        .prose("You can move the value back out by returning it."),
        .code("""
        fn identity(s: String) -> String {
            s
        }

        let s = String::from("hi");
        let s = identity(s);
        println!("{s}");
        """),
        .prose("The second `let s` is a shadow. It receives the string that was moved back. This is legal, and it is usually the wrong tool. If a function only needs to read the text, it should borrow. Returning ownership is for a function that builds a value, or that was given a value and wants to hand it on."),
        .note("Moving in a loop is a classic error. The body `let t = s;` inside `for _ in 0..2` moves `s` on the first pass. The second pass has nothing to move. Clone inside the loop, or borrow."),
    ], [
        ask(
            "move-1",
            "What does a move of a `String` copy?",
            [
                "The heap buffer, byte by byte",
                "The pointer, length, and capacity. The heap buffer stays put",
                "Nothing. The new name is an alias for the variable",
                "Only the first character",
            ],
            1,
            "The `String` header is three words. A move copies that header and invalidates the old variable. The bytes on the heap are not copied. A second owner would be dangerous, because both would free the buffer."
        ),
        ask(
            "move-2",
            "Does the last line compile?",
            [
                "Yes. consume borrows s",
                "Yes. println copies s",
                "No. consume moved s",
                "No. String cannot be printed",
            ],
            2,
            "`consume` takes `String` by value, so the call moves `s`. The later `println` would use a moved value. The compiler rejects it.",
            code: """
            fn consume(s: String) {
                println!("{s}");
            }
            let s = String::from("hi");
            consume(s);
            println!("{s}");
            """
        ),
        ask(
            "move-3",
            "A function takes `String` by value. How can the caller keep that same buffer afterward, without cloning?",
            [
                "The function returns the String, moving it back",
                "The parameter is marked mut",
                "The caller calls the function twice",
                "It is impossible. A move always destroys the bytes",
            ],
            0,
            "The function can return the `String`. Returning moves ownership to the caller. The bytes are still the same buffer. `mut` does not give ownership back."
        ),
    ]),

    lesson("copy", "ownership", "Copy and Clone", minutes: 5, [
        .prose("Some types are `Copy`. Assignment copies the bits, and the old name stays valid. Integers, `bool`, `char`, `f32`, and `f64` are `Copy`. So are tuples and arrays of `Copy` types, and shared references `&T`."),
        .prose("`String` and `Vec<T>` are not `Copy`. Nor is a struct that contains one of them. A `Copy` type has to be trivial to duplicate, and its destructor must not matter. Freeing a `String` matters, so it cannot be `Copy`."),
        .code("""
        let x = 1;
        let y = x;
        println!("{x} {y}");

        let s = String::from("hi");
        let t = s.clone();
        println!("{s} {t}");
        """),
        .prose("`.clone()` is the explicit copy. On a `String` it allocates a new buffer and copies the bytes. Both names stay usable. Clone can be expensive. That is why it is a method call and not silent."),
        .prose("`Copy` requires `Clone`. The clone of a `Copy` type is the same bit copy, so you rarely call it. Assignment already copied. A shared reference is `Copy` even when the value it points at is not. Copying `&String` copies the pointer, not the `String`. A mutable reference `&mut T` is not `Copy`."),
        .note("If the compiler says a value was moved and you still need the old one, borrow it. Clone when you really want a second owned value."),
    ], [
        ask(
            "copy-1",
            "What happens here?",
            [
                "It does not compile. x was moved",
                "It prints 1. i32 is Copy",
                "It prints nothing. println takes ownership of x",
                "It panics",
            ],
            1,
            "`i32` is `Copy`. Assignment copies the bits and `x` stays valid. A `String` would have been moved.",
            code: """
            let x: i32 = 1;
            let y = x;
            println!("{x}");
            """
        ),
        ask(
            "copy-2",
            "Which type can be `Copy`?",
            [
                "String",
                "Vec of i32",
                "A struct whose fields are all i32",
                "A struct with a String field",
            ],
            2,
            "`Copy` is for types that can be duplicated by copying their bits, with nothing to free. Fields that are all `i32` qualify. `String` and `Vec` own heap buffers, and so does a struct that contains them."
        ),
        ask(
            "copy-3",
            "What does `s.clone()` do when `s` is a `String`?",
            [
                "Copies the three-word header and shares the buffer",
                "Allocates a new buffer and copies the bytes. Both names work",
                "Moves s into the clone and invalidates s",
                "Borrows s for the rest of the scope",
            ],
            1,
            "`Clone` for `String` is a deep copy. The new `String` has its own buffer, so the original is still usable. A move would invalidate the original. A borrow would be `&s`, not `clone`."
        ),
    ]),

    lesson("drop", "ownership", "Scope and Drop", minutes: 4, [
        .prose("When a value's owner goes out of scope, Rust drops it. Locals are dropped in reverse order of declaration. Fields of a struct are dropped in reverse order too. Drop is deterministic. It runs at the closing brace, not at some later collection pass."),
        .code("""
        {
            let a = String::from("a");
            let b = String::from("b");
        } // drops b, then a
        """),
        .prose("A move out of the scope means this scope does not drop the value. The new owner will."),
        .code("""
        fn make() -> String {
            let s = String::from("hi");
            s // moved to the caller, not dropped here
        }
        """),
        .prose("This is RAII. A file handle closes when its owner drops. A lock guard unlocks when it drops. You put the resource in a value, and leaving the scope ends the resource. `drop(x)` drops early. You rarely need it. Use it when you must release a lock, or end a borrow, before the closing brace."),
        .note("Returning a value, storing it in a struct, or passing it to a function all move it. If a `String` disappears at the end of a function and you did not return it or move it, this function freed it. That is usually what you want."),
    ], [
        ask(
            "drop-1",
            "In what order are `a` and `b` dropped?",
            [
                "a, then b",
                "b, then a",
                "Whichever string is longer",
                "Neither. String values are never dropped",
            ],
            1,
            "Locals are dropped in reverse order of declaration, at the end of the scope. `b` was declared last, so it drops first.",
            code: """
            let a = String::from("a");
            let b = String::from("b");
            """
        ),
        ask(
            "drop-2",
            "A function builds a `String` and returns it. Where is that `String` dropped?",
            [
                "Inside the function, always, before the return",
                "By the caller, when the caller's owner goes out of scope",
                "Only when the process exits, never sooner",
                "It is leaked. Returned values are not freed",
            ],
            1,
            "The return moves the `String` to the caller. The function does not drop it. The caller owns it and drops it at the end of the caller's scope, unless the caller moves it onward."
        ),
        ask(
            "drop-3",
            "What does RAII mean in Rust?",
            [
                "A garbage collector scans the heap later",
                "A resource is released when the value that owns it is dropped",
                "A way to turn the borrow checker off for one function",
                "A macro that frees memory at the start of a function",
            ],
            1,
            "RAII ties a resource to a value. When the value drops, its drop code runs: files close, locks unlock, buffers are freed. Leaving the scope ends the resource."
        ),
    ]),
]
