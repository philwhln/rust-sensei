import Foundation

let everydayLessons: [Lesson] = [
    lesson("iter", "everyday", "Iterators", minutes: 5, [
        .prose("An iterator yields values one at a time. A `Vec` gives you three ways in. `iter` yields a shared reference to each element and leaves the vector in place. `iter_mut` yields a mutable reference. `into_iter` yields owned elements and consumes the vector. You rarely hold the iterator in a variable. You chain adapters and then consume them."),
        .code("""
        let v = vec![1, 2, 3];
        let doubled: Vec<i32> = v.iter().map(|n| n * 2).collect();
        let sum: i32 = v.iter().sum();
        """),
        .prose("`map` and `filter` are lazy. Calling `map` builds another iterator and does no work until something pulls values: a `for` loop, `sum`, `count`, `collect`, `any`, or `find`. `collect` needs a type somewhere. The `Vec<i32>` on the `let` is enough. `sum` needs a type too, because more than one type can be summed. `v` is still usable, because `iter` only borrowed it."),
        .code("""
        let words = ["a", "bb", "c"];
        let long = words.iter().filter(|w| w.len() > 1).count(); // 1
        """),
        .prose("`filter` keeps the items whose closure returns `true`. Here that is the one word longer than a single character."),
        .note("A `map` that nothing consumes did no work. If a side effect inside the closure never happened, you built an iterator and dropped it. Add a `for`, a `collect`, or another consumer."),
    ], [
        ask(
            "iter-1",
            "When does the closure passed to `map` run?",
            [
                "Immediately, when map is called",
                "When a consumer pulls values. map is lazy",
                "At compile time, on the literal",
                "Twice for every item",
            ],
            1,
            "`map` returns a new iterator. It does not walk the input. `sum`, `collect`, `count`, or a `for` loop pulls values, and the closure runs then."
        ),
        ask(
            "iter-2",
            "For a `Vec`, what is the difference between `iter` and `into_iter`?",
            [
                "There is no difference",
                "iter borrows each element and leaves the Vec. into_iter takes ownership and consumes it",
                "iter consumes the Vec. into_iter borrows it",
                "into_iter only exists for arrays",
            ],
            1,
            "`iter` yields `&T` and the vector remains. `into_iter` on the vector itself yields `T` and moves the vector. After that, the old binding is gone. `iter_mut` is the third form, yielding `&mut T`."
        ),
        ask(
            "iter-3",
            "What does this do?",
            [
                "It does not compile, because map needs a mut binding",
                "It compiles, and the products are thrown away. Nothing pulls on the iterator",
                "It compiles and writes the products back into v",
                "It panics",
            ],
            1,
            "`map` returns an iterator and does not walk it. That iterator is unused, so it is dropped. The closure never runs. Collect the result, sum it, or loop over it.",
            code: """
            let v = vec![1, 2, 3];
            v.iter().map(|n| n * 2);
            """
        ),
    ]),

    lesson("closures", "everyday", "Closures", minutes: 5, [
        .prose("A closure is a function written inline. It can use names from the surrounding function."),
        .code("""
        let factor = 2;
        let double = |n: i32| n * factor;
        let six = double(3);
        """),
        .prose("How it captures decides the trait it implements. If the body only reads a capture, the closure is `Fn`, and you can call it through a shared reference. If calling it needs to change a capture, it is `FnMut`, and the closure binding itself is `mut`. If a call consumes a capture, the closure can run only once. That is `FnOnce`."),
        .code("""
        let mut n = 0;
        let mut inc = || {
            n += 1;
        };
        inc();
        inc();
        """),
        .prose("`inc` is `mut` because each call changes `n`. A closure that only read `n` would not need `mut` on the binding."),
        .prose("`move` is about the capture, not about starting a thread. It moves captured values into the closure instead of borrowing them. You need that when the closure outlives the current stack frame, which is the usual shape of work sent to another thread. A `move` closure can still be called many times if the body only reads what it captured. It is `FnOnce` when the body uses a capture up, for example by returning the `String` it holds."),
        .code("""
        let s = String::from("hi");
        let once = move || s;
        let _taken = once();
        """),
        .note("If the compiler says a closure is `FnOnce` and you wanted to call it twice, the body is consuming a capture. Borrow inside the closure, or clone before the call, instead of moving the value out."),
    ], [
        ask(
            "closures-1",
            "Can a closure use a local from the function around it?",
            [
                "No. A closure is sealed off from that function",
                "Yes. Capturing those names is what a closure is for",
                "Only if the local is 'static",
                "Only if the local is an integer",
            ],
            1,
            "A closure captures names from the enclosing scope. `double` uses `factor` without taking it as a parameter. The capture is a borrow, or a move if you write `move` or if the body needs ownership."
        ),
        ask(
            "closures-2",
            "Why is the counter closure declared `let mut inc`?",
            [
                "Every closure binding has to be mut",
                "Calling it changes a capture, so the closure is FnMut",
                "Because the captured value is an integer",
                "Because move is implied for every closure",
            ],
            1,
            "The body does `n += 1`, so a call mutably borrows `n`. That makes the closure `FnMut`. Calling a `FnMut` closure needs a mutable binding. A closure that only read `n` could be `let inc`."
        ),
        ask(
            "closures-3",
            "What does `move` in front of a closure do?",
            [
                "It runs the closure on another thread by itself",
                "It moves captured values into the closure instead of borrowing them",
                "It copies every capture and leaves the originals in place",
                "It stops the closure from being called",
            ],
            1,
            "`move` selects move-capture. A non-`Copy` original cannot be used outside afterward. It does not start a thread on its own. The closure is `FnOnce` only if a call consumes a capture. A `move` closure that only reads can be called many times."
        ),
    ]),

    lesson("modules", "everyday", "Modules", minutes: 4, [
        .prose("A crate is split into modules. `src/main.rs` is the root of a binary crate. `src/lib.rs` is the root of a library. Items are private to their module by default. `pub` lets other modules see an item."),
        .code("""
        mod greet {
            pub fn hi() {
                println!("hi");
            }

            fn secret() {}
        }

        fn main() {
            greet::hi();
            // greet::secret();
        }
        """),
        .prose("Privacy follows the module tree. Code in a module can use that module's private items. A nested module can use private items of its parent. A parent cannot use private items of a child. Siblings cannot see each other's private items. `pub` opens the item to the parent, and further if the parents are public too. `pub(crate)` opens it to the whole current crate and not to crates that depend on you. That is the right level for a helper."),
        .prose("`mod greet;` with no body, written in `src/main.rs`, loads `src/greet.rs` or `src/greet/mod.rs`. `use greet::hi;` brings `hi` into scope so the call can be `hi()` rather than `greet::hi()`. `crate::` starts at the crate root. `super::` is the parent module. `self::` is the current one."),
        .note("Private means private to the module, not private to one function. Other items in the same module can see it, and so can modules nested inside it. To hide a helper from the rest of the crate, put it in a child module and leave it un-`pub`."),
    ], [
        ask(
            "modules-1",
            "A function has no `pub`. Who can call it?",
            [
                "Any crate that depends on yours",
                "Only the main function",
                "Its own module, and modules nested inside that one",
                "Nobody. A function without pub is deleted",
            ],
            2,
            "A private item is visible in the module where it is defined and in modules nested inside that one. The parent module, a sibling, and other crates cannot call it."
        ),
        ask(
            "modules-2",
            "Can `main` call `greet::secret` when `secret` is not `pub`?",
            [
                "Yes. main can see every item in the crate",
                "Yes. A parent can see private items in its child",
                "No. A parent cannot see a child's private items",
                "No. secret is a keyword and cannot be a function",
            ],
            2,
            "`main` is in the parent module. `secret` is private to `greet`. Parents do not get to see a child's private items. `pub fn secret` would make the call legal. A nested module inside `greet` could call `secret` without `pub`."
        ),
        ask(
            "modules-3",
            "In a binary crate, `mod greet;` in `src/main.rs`, with no module body, loads which file?",
            [
                "A crate named greet from crates.io",
                "src/greet.rs or src/greet/mod.rs",
                "Only a macro named greet",
                "A file named greet.main.rs",
            ],
            1,
            "A `mod` declaration with no `{ }` body is a file. From `src/main.rs`, `mod greet;` is `src/greet.rs`, or `src/greet/mod.rs` if the module has children of its own. A dependency from crates.io is a different mechanism: you name it in `Cargo.toml` and write `use`."
        ),
    ]),

    lesson("program", "everyday", "A small program", minutes: 5, [
        .prose("This function uses the pieces together. It sums the integers in a block of text, one number on each line, and skips blank lines. The caller keeps the text. The function only borrows it."),
        .code("""
        fn sum_numbers(text: &str) -> Result<i64, std::num::ParseIntError> {
            let mut total: i64 = 0;
            for line in text.lines() {
                if line.is_empty() {
                    continue;
                }
                total += line.trim().parse::<i64>()?;
            }
            Ok(total)
        }
        """),
        .prose("`lines` yields `&str` slices of that same text, so the loop does not allocate a `String` per line. `parse` returns a `Result`. `?` returns the parse error immediately, and `total` is dropped on the way out. The caller does not get a partial sum. Success is `Ok(total)`. An `i64` is `Copy`, so returning it does not move a buffer."),
        .prose("An empty line is an empty string, and the `if` skips it. `trim` also drops surrounding spaces, so a line of spaces around a 3 parses as 3. A line whose text is `x` fails the parse, and the function returns `Err`."),
        .prose("Stopping at the first bad line is a policy, and `?` is how this function encodes it. Collecting every error would be a different function and a different return type. The borrow of `text` would stay."),
        .prose("That is the core of the language: who owns the value, who is borrowing it, and how a failure comes back. The Rust book is the next thing to read, with a compiler open. Async, macros, and unsafe sit on top of this."),
        .note("You can paste this into `src/main.rs` and call it from `main`. Give `main` a `Result` return type, or handle the `Result` with `match`, if you want a bad line to be a message instead of a panic."),
    ], [
        ask(
            "program-1",
            "Who owns the text while `sum_numbers` is running?",
            [
                "The function. The parameter type is String",
                "The caller. The function borrows it as &str",
                "lines, which copies every line into a new String",
                "The local total",
            ],
            1,
            "The parameter is `&str`, a borrow. The caller remains the owner. `lines` yields slices of that same borrow. `total` is a separate `i64` the function owns."
        ),
        ask(
            "program-2",
            "The text is three lines: `1`, an empty line, and `2`. What does `sum_numbers` return?",
            [
                "Err, because of the empty line",
                "Ok(3)",
                "Ok(1), and then it stops",
                "It panics on the empty line",
            ],
            1,
            "`lines` yields the empty line as an empty `&str`, and the `if` skips it. `1` and `2` both parse. The total is 3, returned as `Ok`. A blank line is not an error in this function."
        ),
        ask(
            "program-3",
            "One line is the text `x`. What does the caller receive?",
            [
                "Ok, with the sum of the numbers from earlier lines",
                "Err, and the partial total is dropped with the function",
                "Ok(0)",
                "Ok, because x is skipped like a blank line",
            ],
            1,
            "`parse` returns `Err` for `x`. `?` returns from the function immediately with that error. `total` is a local, so it is dropped. The caller sees the error, not a partial sum. Skipping bad lines would be different code."
        ),
    ]),
]
