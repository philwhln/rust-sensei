import Foundation

let traitLessons: [Lesson] = [
    lesson("traits", "traits", "Traits", minutes: 5, [
        .prose("A trait is shared behavior that types can implement. It is the closest thing Rust has to an interface."),
        .code("""
        trait Area {
            fn area(&self) -> f64;
        }

        struct Square {
            side: f64,
        }

        impl Area for Square {
            fn area(&self) -> f64 {
                self.side * self.side
            }
        }
        """),
        .prose("A trait method can have a default body. An `impl` may keep it or replace it. The `impl` can live apart from the struct, in another module. You can implement your own trait for a type from the standard library. You can implement a standard trait, such as `Display`, for a struct you defined."),
        .prose("You cannot implement a trait you do not own for a type you do not own. `impl Display for String` in your crate is rejected, because both belong to the standard library. That is the orphan rule. It stops two crates from writing the same impl."),
        .note("If you wrote the impl and the compiler says the method does not exist, the trait may be out of scope. Methods from a trait show up only when the trait is in scope. Add a `use`."),
    ], [
        ask(
            "traits-1",
            "What is a trait?",
            [
                "A base struct you inherit from",
                "Shared behavior a type can implement",
                "A macro that generates a struct",
                "The file a type is defined in",
            ],
            1,
            "A trait names methods. Types supply the bodies in `impl Trait for Type`. It is how you describe behavior that more than one type can have."
        ),
        ask(
            "traits-2",
            "Which of these is your crate allowed to write?",
            [
                "impl Display for String",
                "impl Display for a struct you defined",
                "impl Debug for Vec<i32>",
                "impl Clone for String",
            ],
            1,
            "You may implement a foreign trait for your own type. `Display` for a struct you defined is allowed. `Display` for `String`, `Debug` for `Vec<i32>`, and `Clone` for `String` are foreign traits on foreign types. The orphan rule rejects those."
        ),
        ask(
            "traits-3",
            "The impl is written, and the compiler says the method does not exist on the value. What is a likely cause?",
            [
                "Traits are not allowed to add methods",
                "The trait is not in scope",
                "The method has to be marked mut on the call",
                "impl blocks are only legal in main.rs",
            ],
            1,
            "A trait's methods are visible when the trait is in scope. `use` the trait in the module that calls the method. The impl can live in another module. The call site still needs the trait."
        ),
    ]),

    lesson("generics", "traits", "Generics", minutes: 5, [
        .prose("A generic function is written once and used for many types. At each call, the compiler fills in a concrete type and compiles a version for it. That is monomorphization. The finished binary has a copy per type you actually used. An ordinary generic call does not look the method up in a table at run time."),
        .code("""
        fn first<T>(items: &[T]) -> Option<&T> {
            items.first()
        }
        """),
        .prose("`T` is chosen from the argument. `first` of a slice of `i32` makes `T` into `i32`. With no bounds, `first` can only do what works for every type: take a reference, move a value, return it. The next lesson adds bounds so you can call methods."),
        .code("""
        struct Point<T> {
            x: T,
            y: T,
        }
        """),
        .prose("Both fields are the same `T`. `Point` of `i32` and `Point` of `f64` are different types. A point with an integer `x` and a floating `y` does not fit this struct."),
        .prose("`fn show(x: impl Display)` is another way to say some type that implements `Display`. Each `impl Trait` parameter is its own hidden type. Two parameters written `impl Display` may be different types. One shared `T: Display` forces them to be the same type."),
        .note("A trait object, written `dyn Area`, is the other tool: one function, and at run time a pointer to the value plus a pointer to its methods. Use a generic unless you need to mix types in one collection or behind one argument. This course stays with generics."),
    ], [
        ask(
            "generics-1",
            "You call one generic function on `i32` and on `String`. What does the compiler produce?",
            [
                "One function that looks the type up while the program runs",
                "A version for i32 and a version for String",
                "An error on the second call",
                "A boxed value for every argument",
            ],
            1,
            "Monomorphization copies the function for each concrete type. The `i32` call and the `String` call become two functions in the binary. There is no run-time search for an ordinary generic."
        ),
        ask(
            "generics-2",
            "For `struct Point<T> { x: T, y: T }`, which value is legal?",
            [
                "A point with x equal to 1 and y equal to 1.0",
                "A point with x equal to 1 and y equal to 2",
                "A point with x equal to a string and y equal to 1",
                "A point with x equal to true and y equal to 0",
            ],
            1,
            "Both fields are the same `T`. `1` and `2` can both be `i32`. `1` and `1.0` would be an `i32` and an `f64`, and those are different types."
        ),
        ask(
            "generics-3",
            "Which call compiles?",
            [
                "same(1, a string slice)",
                "diff(1, a string slice)",
                "Both calls",
                "Neither call",
            ],
            1,
            "`same` has one type parameter, so both arguments have to be that type. An integer and a string slice are not. `diff` gives each `impl Display` its own type. Both arguments implement `Display`, and they are allowed to differ.",
            code: """
            fn same<T: std::fmt::Display>(a: T, b: T) {}
            fn diff(a: impl std::fmt::Display, b: impl std::fmt::Display) {}
            """
        ),
    ]),

    lesson("bounds", "traits", "Trait bounds", minutes: 4, [
        .prose("A trait bound says what a generic type must be able to do. Without a bound, you cannot call a method that only some types have."),
        .code("""
        use std::fmt::Display;

        fn show<T: Display>(x: T) {
            println!("{x}");
        }
        """),
        .prose("`T: Display` means any type that implements `Display`. `{}` in a format string uses `Display`. `{:?}` uses `Debug`. They are different traits. `#[derive(Debug)]` writes a `Debug` impl for you. It does not write `Display`. `Display` is the text you chose to show a person, and you usually write that impl yourself."),
        .prose("A longer bound is easier to read on a `where` clause. Several traits combine with `+`, as in `T: Clone + Debug`."),
        .code("""
        #[derive(Debug, Clone, PartialEq, Eq)]
        struct Point {
            x: i32,
            y: i32,
        }
        """),
        .prose("`==` comes from `PartialEq`. `Eq` is a marker that equality is reflexive: a value equals itself. `f64` is `PartialEq` and not `Eq`, because `NaN` is not equal to `NaN`. That is why a `HashMap` key needs `Eq`, and why `f64` cannot be one. `Hash` is the other requirement for a key."),
        .note("`{:?}` on a type with no `Debug` impl is a compile error. Derive `Debug` on your structs. You will want it the first time a test prints a value."),
    ], [
        ask(
            "bounds-1",
            "What does `T: Display` mean?",
            [
                "T is the Display type itself",
                "T implements Display",
                "T is a trait, not a type",
                "T is not allowed to be printed",
            ],
            1,
            "The bound restricts `T` to types that implement `Display`. Inside the function you may use `T` the way `Display` allows, including `{}` in a format string."
        ),
        ask(
            "bounds-2",
            "What does `#[derive(Debug)]` give you?",
            [
                "Printing with {}",
                "Printing with {:?}",
                "A constructor named new",
                "The == operator",
            ],
            1,
            "`Debug` is the `{:?}` format, meant for programmers. `{}` is `Display`, which derive does not generate. `==` would be `PartialEq`."
        ),
        ask(
            "bounds-3",
            "Which trait provides `==`?",
            [
                "Display",
                "Debug",
                "PartialEq",
                "Copy",
            ],
            2,
            "`PartialEq` is the trait behind `==` and `!=`. `Eq` is an extra marker, used when equality is reflexive. `Copy` is about duplication, not comparison."
        ),
    ]),
]
