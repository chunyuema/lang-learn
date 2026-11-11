fn main() {
    let original = String::from("hello");
    println!("ORIGINAL buffer at {:p}", original.as_ptr());

    // MOVE: ownership of the String is transferred to `moved`. The heap
    // buffer is not copied, so its address stays the same. `original` can no
    // longer be used after this assignment.
    let moved = original;
    println!("MOVE     buffer at {:p}", moved.as_ptr());

    // CLONE: a new String with its own heap buffer is created. This is the
    // explicit Rust equivalent of making a deep copy; both values remain usable.
    let cloned = moved.clone();
    println!("CLONE    buffer at {:p}", cloned.as_ptr());
}
