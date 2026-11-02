import Foundation

let borrowingLessons: [Lesson] = [
    lesson("shared", "borrowing", "Shared references", minutes: 4, [
        .prose("A shared reference borrows a value. The owner keeps it. `&s` has type `&String` when `s` is a `String`. You can read through it. You cannot change the value through it. Many shared references can exist at the same time."),
        .code("""
        let s = String::from("hi");
        let a = &s;
        let b = &s;
        println!("{a} {b} {s}");
        """),
        .prose("The borrow ends at the last use of the reference. After that use, the owner is free again. Functions take references so they can look without taking ownership."),
        .code("""
        fn len(s: &String) -> usize {
            s.len()
        }
        """),
        .prose("`s.len()` works because the method takes `&self`. You do not write `(*s).len()` in ordinary code. A better function takes `&str`, so it accepts both a `String` and a string slice. That shows up with collections. `&String` is the simple form of a borrow."),
        .note("A borrow is not a clone and not a move. When a function should only read, pass a reference. `.clone()` silences some errors by copying data you did not need to copy."),
    ], [
        ask(
            "shared-1",
            "What does `let a = &s` do when `s` is a `String`?",
            [
                "It moves s into a",
                "It deep-copies the text",
                "It borrows s. s is still the owner",
                "It frees s",
            ],
            2,
            "`&s` is a shared borrow. The `String` still belongs to `s`. `a` is allowed to read it. Nothing is allocated, and nothing is freed."
        ),
        ask(
            "shared-2",
            "How many shared references to one `String` can you hold at the same time?",
            [
                "One",
                "Two, and no more",
                "As many as you need",
                "None. String cannot be borrowed",
            ],
            2,
            "Shared references are read-only, so they do not conflict with each other. You can hold as many as you need. The limit shows up when a mutable reference enters the picture."
        ),
        ask(
            "shared-3",
            "Can you call `push_str` through a shared `&String`?",
            [
                "Yes. Any reference lets you change the value",
                "Yes, if the String was built with String::from",
                "No. A shared reference is read-only",
                "No. push_str exists only on characters",
            ],
            2,
            "`&String` does not allow mutation. `push_str` needs `&mut self`. A shared reference is for reading. Mutation needs `&mut String`, and the binding has to be `mut`."
        ),
    ]),

    lesson("mutref", "borrowing", "Mutable references", minutes: 4, [
        .prose("A mutable reference is `&mut T`. It is how you change a value you do not own. Creating one requires the owner binding to be `mut`. While it is active, it is the only borrow. No second `&mut`, and no shared `&`, may overlap with it."),
        .code("""
        let mut v = vec![1];
        let r = &mut v;
        r.push(2);
        println!("{v}");
        """),
        .prose("`r.push(2)` works because `push` takes `&mut self`, and `r` is already `&mut Vec<i32>`. You usually write `v.push(2)` and let Rust make the `&mut` for that call. The borrow then lasts only for the call."),
        .prose("This does not compile. `v` is not `mut`, so it cannot be borrowed mutably."),
        .code("""
        let v = vec![1];
        let r = &mut v;
        """),
        .note("`&mut` is exclusive. The compiler rejects a second mutable borrow even when you believe the uses do not conflict. Restructure so the borrows do not overlap. Cloning to get a second owner is the escape hatch, not the default."),
    ], [
        ask(
            "mutref-1",
            "Does this compile?",
            [
                "Yes. A Vec allows many mutable borrows",
                "Yes, because push is the last use",
                "No. Two mutable borrows of v overlap",
                "No. A Vec cannot be declared mut",
            ],
            2,
            "`a` and `b` are two `&mut` borrows of the same vector, and `a` is used after `b` is created. A mutable borrow has to be the only borrow. The compiler rejects the overlap.",
            code: """
            let mut v = vec![1, 2];
            let a = &mut v;
            let b = &mut v;
            a.push(3);
            """
        ),
        ask(
            "mutref-2",
            "Does this compile?",
            [
                "Yes",
                "No. v is not mut",
                "No. push takes ownership of the vector",
                "Yes, but only in a release build",
            ],
            1,
            "`push` needs a mutable borrow. `let v` without `mut` cannot give one. Write `let mut v`.",
            code: """
            let v = vec![1];
            v.push(2);
            """
        ),
        ask(
            "mutref-3",
            "A function should append to the caller's vector and leave the caller as the owner. What is the parameter?",
            [
                "v: Vec<i32>",
                "v: &Vec<i32>",
                "v: &mut Vec<i32>",
                "v: mut Vec<i32>",
            ],
            2,
            "`&mut Vec<i32>` borrows the caller's vector and allows `push`. The caller stays the owner. Taking `Vec<i32>` by value would move it in. A shared `&Vec<i32>` cannot push."
        ),
    ]),

    lesson("rules", "borrowing", "The borrow rules", minutes: 5, [
        .prose("Three rules cover almost every borrow error. A value has one owner. You may have any number of shared borrows, or exactly one mutable borrow, and not both over the same stretch of code. A reference must not outlive the owner."),
        .prose("The borrow lasts until its last use. This compiles, because `first` is finished before `push`:"),
        .code("""
        let mut v = vec![1, 2];
        let first = &v[0];
        println!("{first}");
        v.push(3);
        """),
        .prose("This does not. `first` is used after `push`. `push` may allocate a new buffer and move the elements, which would leave `first` pointing at freed memory."),
        .code("""
        let mut v = vec![1, 2];
        let first = &v[0];
        v.push(3);
        println!("{first}");
        """),
        .prose("Returning a reference to a local is the same rule. The local dies at the end of the function. The reference would dangle, so the compiler rejects it."),
        .note("Read the error from the top. Rust names both borrows and points at the use that keeps the first one alive. End that use, or copy out the one element you need when it is `Copy`. Do not sprinkle `.clone()` on the whole vector to get past the error."),
    ], [
        ask(
            "rules-1",
            "Why is printing `first` after `push` rejected?",
            [
                "println cannot print a reference",
                "push may move the buffer, and first would point at the old one",
                "A Vec cannot be borrowed and printed in the same function",
                "The index 0 has type i32, and indexes must be usize",
            ],
            1,
            "`push` can reallocate. `first` borrows an element inside the current buffer. Using `first` after `push` is rejected so that borrow cannot dangle. Printing `first` before the `push` ends the borrow in time."
        ),
        ask(
            "rules-2",
            "A function creates a local `String` and tries to return a reference to it. What happens?",
            [
                "It compiles, and the caller becomes the owner of the String",
                "It compiles, and the String is leaked on purpose",
                "It does not compile. The reference would outlive the owner",
                "It compiles only if the function is marked mut",
            ],
            2,
            "The local is dropped when the function returns. A reference to it would dangle. Return an owned `String`, or borrow from an argument the caller still holds."
        ),
        ask(
            "rules-3",
            "Which set of borrows of one value is allowed over the same stretch of code?",
            [
                "Two mutable references",
                "One shared reference and one mutable reference",
                "Three shared references",
                "One mutable reference, and also a move of the owner",
            ],
            2,
            "Any number of shared references may overlap. A mutable reference has to be the only borrow. Moving the owner while a reference exists would also leave that reference behind, so that is rejected too."
        ),
    ]),

    lesson("slices", "borrowing", "Slices", minutes: 5, [
        .prose("A slice borrows a contiguous sequence. It stores a pointer and a length. It does not own the elements. `&[i32]` is a slice of integers. `&str` is a slice of UTF-8 text. The owner is a `Vec`, an array, a `String`, or, for a literal, the program itself."),
        .code("""
        let a = [10, 20, 30, 40];
        let mid: &[i32] = &a[1..3]; // 20, 30

        let s = String::from("hello");
        let hello: &str = &s[..];
        """),
        .prose("`1..3` starts at 1 and stops before 3. A string literal already has type `&str`. More precisely it is `&'static str`: the text lives in the binary, and the borrow lasts for the whole program."),
        .prose("Ranges on a string are byte offsets, and they must land on a character boundary."),
        .code("""
        let s = "é";
        let _good = &s[0..2]; // the whole character
        // &s[0..1] panics: byte 1 is inside the character
        """),
        .prose("`é` is two bytes in UTF-8. Cutting at byte 1 would split the character, so Rust panics instead of handing you a broken string. That check is at run time. The type system cannot see the bytes of a value built while the program runs."),
        .note("Prefer `&str` over `&String` for a function argument, and `&[T]` over `&Vec<T>`. A slice accepts more callers: a whole buffer, a literal, or a piece of either. A `String` can be passed where `&str` is wanted, because `String` dereferences to `str`."),
    ], [
        ask(
            "slices-1",
            "What does a slice own?",
            [
                "The elements, which it frees at the end of the scope",
                "Nothing. It borrows a pointer and a length",
                "A copy of every element",
                "The variable that created it",
            ],
            1,
            "A slice is a borrow: a pointer and a length. The owner of the underlying buffer is unchanged. Dropping the slice does not free the elements."
        ),
        ask(
            "slices-2",
            "What is the type of the literal `\"hi\"`?",
            [
                "String",
                "char",
                "&'static str",
                "An array of two u8 values",
            ],
            2,
            "A string literal is a shared reference to text stored in the program. The borrow is `'static`, valid for the whole run. It is not an owned `String`. `String::from` or `.to_string()` makes one of those."
        ),
        ask(
            "slices-3",
            "What does `&s[0..1]` do when `s` is the string `é`?",
            [
                "It returns a &str of the character é",
                "It returns the first byte as a char",
                "It panics, because byte 1 is not a character boundary",
                "It does not compile",
            ],
            2,
            "Indexes on `String` and `&str` are byte offsets. `é` is two UTF-8 bytes, so offset 1 sits in the middle of the character. Rust panics rather than return invalid text. `&s[0..2]` is the whole character. The check happens at run time."
        ),
    ]),
]
