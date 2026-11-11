fn main() {
    let mut values = vec![1_u64, 2, 3];

    // try_reserve asks for additional capacity without adding any elements.
    // Unlike reserve, it reports allocation or capacity-overflow failure as an
    // Err instead of panicking.
    match values.try_reserve(usize::MAX) {
        Ok(()) => println!("reserved"),
        Err(error) => println!("error: {error}"),
    }

    // A failed reservation leaves the existing elements intact, so the
    // original Vec remains valid and can still be used.
    println!("values are still {values:?}");
}
