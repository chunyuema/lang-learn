extern "C" fn risky() {
    println!("risky: about to panic");
    panic!("boom");
}

fn main() {
    let result = std::panic::catch_unwind(|| risky());
    println!("caught: {}", result.is_err());
}
