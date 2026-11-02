import Foundation

let collectionLessons: [Lesson] = [
    lesson("vec", "collections", "Vec", minutes: 4, [
        .prose("`Vec<T>` is a growable list that owns its elements. `vec![1, 2, 3]` builds one. `Vec::new()` starts empty. `push` adds at the end. `pop` removes from the end and returns `Option<T>`, because the vector might be empty. `len` is the count."),
        .code("""
        let mut v = vec![10, 20, 30];
        v.push(40);
        let last = v.pop(); // Some(40)
        """),
        .prose("`v[i]` returns a reference to the element, and it panics if `i` is out of bounds. `v.get(i)` returns `Option<&T>` and does not panic. Use `get` when a missing index is ordinary. Use `v[i]` when a bad index is a bug."),
        .code("""
        let v = vec![10, 20, 30];
        for n in &v {
            println!("{n}");
        }
        """),
        .prose("`for n in &v` borrows each element, and `v` is usable afterward. `for n in &mut v` lets you change elements. `for n in v` moves the elements out and consumes `v`. After that loop the vector is gone."),
        .note("A reference into a `Vec` and a later `push` is the borrow error from earlier. `push` may allocate a new buffer and move every element. Copy the element out, when it is `Copy`, or finish using the reference, before you push."),
    ], [
        ask(
            "vec-1",
            "What does `v[i]` do when `i` is past the end?",
            [
                "It returns None",
                "It returns 0",
                "It panics",
                "It grows the vector with a default element",
            ],
            2,
            "Indexing with `[]` panics on an out-of-bounds index. That is the right tool when the index is supposed to be valid. When it might not be, call `get`."
        ),
        ask(
            "vec-2",
            "What does `v.get(i)` return?",
            [
                "The element, moved out of the vector",
                "A reference, or a panic if i is out of bounds",
                "Option of a reference to the element",
                "Option of a cloned element",
            ],
            2,
            "`get` returns `Option<&T>`. A valid index is `Some`, and a reference keeps the vector as the owner. An invalid index is `None`, not a panic."
        ),
        ask(
            "vec-3",
            "What does `for n in v` do when `v` is a `Vec<String>`?",
            [
                "It borrows each String and leaves v usable",
                "It clones each String",
                "It moves each String out and consumes v",
                "It does not compile, because String is not Copy",
            ],
            2,
            "`for n in v` takes ownership of the vector. Each `String` moves into `n`. After the loop, `v` cannot be used. `for n in &v` borrows instead, and that form works for `String` too."
        ),
    ]),

    lesson("string", "collections", "String and &str", minutes: 5, [
        .prose("`String` is owned, growable, UTF-8 text. `&str` borrows UTF-8 text. A literal is a `&str`. Build a `String` with `String::from`, with `.to_string()`, or with `format!`."),
        .code("""
        let mut s = String::from("hi");
        s.push('!');
        s.push_str(" yo");
        """),
        .prose("`push` takes one `char`. `push_str` takes `&str`, so the argument stays yours. `+` is the surprising operator. `s1 + &s2` moves `s1` and borrows `s2`. After that line, `s1` is gone and `s2` is not."),
        .prose("You cannot write `s[0]` on a `String`. A byte index is not always one character, and finding the nth character is not a constant-time operation, so Rust does not pretend that it is. Walk characters with `.chars()`, or bytes with `.bytes()`."),
        .code("""
        let word = "é";
        let bytes = word.len();           // 2
        let chars = word.chars().count(); // 1
        """),
        .prose("A function that only reads text should take `&str`, not `&String`. An `&str` parameter accepts a literal, a `String`, or a slice of either. An `&String` parameter accepts only a `String`."),
        .note("`.len()` counts bytes, not characters. `.chars().count()` is closer to what a person counts, and it still is not the full story for grapheme clusters. Do not use `.len()` to cut text up for display."),
    ], [
        ask(
            "string-1",
            "Why does `s[0]` fail to compile for a `String`?",
            [
                "A byte index can split a character, and character indexing is not a constant-time lookup",
                "String can only hold ASCII",
                "The syntax for the first character is s(0)",
                "It compiles and returns a char",
            ],
            0,
            "`String` is UTF-8. Offset 0 is not always a whole character, and the nth character cannot be found in constant time. Rust refuses `s[0]` instead of hiding that. Use `.chars()` or a byte range that lands on a boundary."
        ),
        ask(
            "string-2",
            "After `let s3 = s1 + &s2`, with `s1` and `s2` both `String`, which names still work?",
            [
                "s1 and s2. Plus copies both",
                "s2 and s3. s1 was moved",
                "s1 and s3. s2 was moved",
                "Only s3. Both inputs were moved",
            ],
            1,
            "`Add` for `String` takes the left side by value and the right side as `&str`. `s1` moves into the result. `&s2` only borrows `s2`, so `s2` is still usable. `s3` owns the combined text."
        ),
        ask(
            "string-3",
            "A function only reads text. Which parameter accepts both a `String` and a literal?",
            [
                "&String",
                "String, by value",
                "&str",
                "char",
            ],
            2,
            "`&str` borrows text. A `String` dereferences to `str`, so passing `&owned` works, and a literal is already `&str`. `&String` will not accept a literal without building a `String` first. Taking `String` by value forces a move or a clone."
        ),
    ]),

    lesson("map", "collections", "HashMap", minutes: 5, [
        .prose("`HashMap<K, V>` lives in `std::collections`. It owns its keys and its values. `insert` adds or replaces. `get` returns `Option<&V>`. A missing key is `None`, not a panic."),
        .code("""
        use std::collections::HashMap;

        let mut scores = HashMap::new();
        scores.insert(String::from("ada"), 10);
        let ada = scores.get("ada"); // Some
        let no = scores.get("bea");  // None
        """),
        .prose("`get` borrows the key. When the key type is `String`, `get` with a string literal works, because a `String` can be looked up through `&str`. You do not allocate a new `String` just to search."),
        .prose("`entry` updates in place. `or_insert` writes the default only when the key is absent, and it hands back `&mut V` either way."),
        .code("""
        let count = scores.entry(String::from("ada")).or_insert(0);
        *count += 1;
        """),
        .prose("A key type needs `Eq` and `Hash`. `i32` and `String` qualify. `f64` does not. `NaN` is not equal to itself, so floating-point numbers have no `Eq` implementation, and they cannot be keys."),
        .note("`insert` on a key that is already there replaces the value and returns the old one as `Option`. `or_insert` does not replace an existing value. Pick the one that matches what should happen when the key is already present."),
    ], [
        ask(
            "map-1",
            "What does `scores.get` return for a key that was never inserted?",
            [
                "It panics",
                "None",
                "0",
                "Err",
            ],
            1,
            "`get` returns `Option<&V>`. A missing key is `None`. It does not panic, and it does not invent a zero. `v[key]` on a map is different: that panics when the key is absent."
        ),
        ask(
            "map-2",
            "What does `entry(key).or_insert(0)` do when the key is already present?",
            [
                "It replaces the stored value with 0",
                "It panics, because the key exists",
                "It leaves the value alone and returns a mutable reference to it",
                "It removes the key",
            ],
            2,
            "`or_insert` writes the default only into a vacant entry. If the key is present, you get `&mut` to the value that was already there, and that value is unchanged until you write through the reference."
        ),
        ask(
            "map-3",
            "Why is `f64` rejected as a `HashMap` key?",
            [
                "HashMap only allows String keys",
                "f64 has no Eq, because NaN is not equal to itself",
                "f64 is too wide to hash",
                "Floating-point values cannot be stored in a struct",
            ],
            1,
            "Keys need `Eq` and `Hash`. Equality has to be reflexive, and `NaN != NaN`, so `f64` implements `PartialEq` but not `Eq`. Integers and `String` are fine."
        ),
    ]),
]
