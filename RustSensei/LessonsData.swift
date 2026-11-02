import Foundation

let dataLessons: [Lesson] = [
    lesson("struct", "data", "Structs", minutes: 5, [
        .prose("A struct groups named fields."),
        .code("""
        struct User {
            name: String,
            age: u32,
        }

        let name = String::from("ada");
        let age = 36;
        let user = User { name, age };
        """),
        .prose("`User { name, age }` is shorthand for `name: name, age: age` when the local names match the fields. The `String` is moved in. `age` is `Copy`, so the local `age` is still usable. The local `name` is not."),
        .prose("Changing a field needs a `mut` binding. A tuple struct has positional fields: `struct Point(i32, i32)`, built as `Point(1, 2)`, read as `.0`. A unit struct has no fields: `struct Marker;`."),
        .prose("You can move one field out. The other fields remain. The struct as a whole is then partially moved, and you cannot use it as one value."),
        .code("""
        let user = User {
            name: String::from("ada"),
            age: 36,
        };
        let name = user.name;
        println!("{}", user.age);
        """),
        .note("Field names do the matching, so the order in a struct literal does not have to follow the definition. Leaving a field out is a compile error. Nothing is filled in for you unless you write a default."),
    ], [
        ask(
            "struct-1",
            "Does this compile?",
            [
                "Yes",
                "No. user is not mut",
                "No. age is private to another module",
                "No. A struct field cannot be a number",
            ],
            1,
            "Assignment to a field needs a mutable binding. `let user` cannot be changed. `let mut user` would allow `user.age += 1`.",
            code: """
            struct User { name: String, age: u32 }
            let user = User { name: String::from("ada"), age: 36 };
            user.age += 1;
            """
        ),
        ask(
            "struct-2",
            "What does `User { name, age }` mean when locals named `name` and `age` exist?",
            [
                "Both fields are set to a default value",
                "It is shorthand for name: name and age: age",
                "It copies user into itself",
                "It borrows both locals and stores the references",
            ],
            1,
            "When the local name and the field name are the same, you can write the name once. `name` here is a `String`, so it is moved into the field. `age` is copied."
        ),
        ask(
            "struct-3",
            "After `let name = user.name` moves the `String` out, which use is still allowed?",
            [
                "Reading user.name",
                "Passing the whole user to a function by value",
                "Reading user.age",
                "Calling clone on the field that was moved",
            ],
            2,
            "A partial move takes `name` and leaves `age`. You can still read `age`, and `u32` is `Copy`. You cannot use the moved field, and you cannot use `user` as a whole value."
        ),
    ]),

    lesson("methods", "data", "Methods", minutes: 4, [
        .prose("`impl User` puts functions on the struct. A method takes `self` in some form. `&self` borrows it. `&mut self` borrows it mutably. `self` by value takes ownership and consumes the receiver. An associated function takes no `self`. `User::new` is the usual way to build one. The name `new` is a convention, not a keyword."),
        .code("""
        impl User {
            fn new(name: String, age: u32) -> Self {
                Self { name, age }
            }

            fn greet(&self) -> String {
                format!("hi {}", self.name)
            }

            fn birthday(&mut self) {
                self.age += 1;
            }
        }
        """),
        .prose("`Self` means the type this `impl` is for. `user.greet()` borrows `user`. `user.birthday()` needs `user` to be `mut`. `User::new(...)` does not need an existing value. It builds one."),
        .prose("Rust has no class inheritance. A type does not extend another type and override its methods. Shared behavior goes in a trait. Data you would have inherited, you store in a field."),
        .note("A method that takes `self` by value consumes the receiver. After that call, the old binding is moved. Use that when the method takes the value apart. Use `&self` to read."),
    ], [
        ask(
            "methods-1",
            "What does `&self` mean on a method?",
            [
                "The method takes ownership of the value",
                "The method borrows the value and can read it",
                "The method can always mutate the value",
                "The method is a constructor",
            ],
            1,
            "`&self` is a shared borrow of the receiver, the same idea as `&User`. The caller keeps ownership. Mutation would be `&mut self`. Taking the value would be `self` with no `&`."
        ),
        ask(
            "methods-2",
            "How do you call an associated function that takes no receiver?",
            [
                "user.new(name, age), on an existing value",
                "User::new(name, age)",
                "new(User, name, age)",
                "User.new(name, age)",
            ],
            1,
            "No `self` parameter means there is no receiver. You call it on the type: `User::new(...)`. `user.greet()` is the method form, because `greet` takes `&self`."
        ),
        ask(
            "methods-3",
            "How do types share behavior in Rust?",
            [
                "A struct inherits a base struct and overrides methods",
                "Through traits, and by storing another value in a field",
                "By copying each method into every file by hand",
                "By marking the struct mut",
            ],
            1,
            "There is no inheritance between structs. A trait describes shared methods. When one value is built out of another, the other value is a field, and you call through that field."
        ),
    ]),

    lesson("enum", "data", "Enums with data", minutes: 4, [
        .prose("An enum is one value that is one of several shapes. Each variant can hold different data. This is not a C enum of integers. The value knows which variant it is."),
        .code("""
        enum Command {
            Quit,
            Move { x: i32, y: i32 },
            Say(String),
        }

        let go = Command::Move { x: 1, y: 0 };
        let hi = Command::Say(String::from("hi"));
        """),
        .prose("`Option` and `Result` are enums from the standard library. Your own enums work the same way. A `match` on `Command` has to handle `Quit`, `Move`, and `Say`, or use `_`."),
        .prose("An enum value is large enough for the biggest variant, plus a tag that records which variant it is. You pay for the largest shape, not for the sum of all of them. Some types, such as `Option` of a reference, can fold the tag into unused bits. You do not have to plan on that."),
        .note("Put each case's data in that variant. A struct full of optional fields can represent combinations that cannot happen, such as a quit command that also has coordinates. An enum cannot represent those, because `Quit` has no coordinates."),
    ], [
        ask(
            "enum-1",
            "Can two variants of one enum hold different data?",
            [
                "No. Every variant is only an integer",
                "No. Every variant must have the same fields",
                "Yes. Each variant chooses its own data",
                "Yes, but only if the enum is declared mut",
            ],
            2,
            "Each variant has its own fields. `Quit` can hold nothing, `Move` can hold two integers, and `Say` can hold a `String`. The value is exactly one of those."
        ),
        ask(
            "enum-2",
            "How do you build the `Move` variant as it is defined in the lesson?",
            [
                "Command { x: 1, y: 0 }",
                "Command::Move { x: 1, y: 0 }",
                "Move(Command, 1, 0)",
                "Command::Move(1, 0), for this definition",
            ],
            1,
            "The variant's name is `Command::Move`. This definition uses named fields, so the value uses `{ x, y }`. `Say` is the tuple form, written `Command::Say(text)`. The syntax follows the definition."
        ),
        ask(
            "enum-3",
            "How much room does one enum value take?",
            [
                "The sum of the sizes of every variant",
                "Enough for the largest variant, plus a tag",
                "Always one byte, no matter the data",
                "None. Enums disappear after type checking",
            ],
            1,
            "The value stores a tag for which variant it is, and enough bytes for the largest variant. Smaller variants fit in that space. The value exists at run time. It is not erased."
        ),
    ]),

    lesson("patterns", "data", "Patterns", minutes: 4, [
        .prose("Patterns are not only for `match`. `if let` tries one pattern. `while let` loops while the pattern fits. `let (x, y) = pair` unpacks a tuple. Function parameters are patterns too."),
        .code("""
        let value: Option<i32> = Some(4);
        if let Some(n) = value {
            println!("{n}");
        } else {
            println!("none");
        }
        """),
        .prose("`let Some(n) = value;` on its own does not compile when `value` is an `Option`. A plain `let` needs a pattern that always matches. `Some` does not match `None`, so the pattern is refutable. Refutable patterns belong in `if let` and `match`. `let (x, y) = pair` is fine when `pair` is a two-field tuple, because that shape always has two fields. The pattern is irrefutable."),
        .code("""
        let User { name, age } = user;
        """),
        .prose("That moves `name` when it is a `String`, and copies `age`. If you only need one field, `user.age` is clearer than a pattern. Matching on a reference borrows the fields instead of moving them."),
        .note("`if let Ok(n) = result` handles success and folds every failure into the `else`. That hides which error you got. Use `match` when the error matters."),
    ], [
        ask(
            "patterns-1",
            "Does this compile when `value` has type `Option<i32>`?",
            [
                "Yes. let tries the pattern and skips on None",
                "Yes, and n is 0 when the value is None",
                "No. Some does not match every Option",
                "No. Option cannot appear in a pattern",
            ],
            2,
            "A bare `let` needs an irrefutable pattern. `Some(n)` does not match `None`, so this is rejected. `if let Some(n) = value` is the form that handles both cases.",
            code: """
            let Some(n) = value;
            """
        ),
        ask(
            "patterns-2",
            "When does the `else` of `if let Ok(n) = result` run?",
            [
                "When the value is Ok",
                "When the value is not Ok",
                "Never. if let cannot have an else",
                "When n is zero",
            ],
            1,
            "The block runs when the pattern matches. The `else` runs for every other value, here every `Err`, whatever the error is."
        ),
        ask(
            "patterns-3",
            "What does `let (x, y) = pair` require of `pair`?",
            [
                "pair must be an Option",
                "pair's type always has two fields, such as a pair tuple",
                "pair must be a Vec whose length is checked at run time",
                "x and y must both be declared mut",
            ],
            1,
            "The pattern in a plain `let` has to be irrefutable. A two-field tuple always has those two fields, so the compiler accepts it. A `Vec` of length 2 is not guaranteed by the type, and it does not use this syntax."
        ),
    ]),
]
