fn ordinary_risky() {
    println!("ordinary: about to panic");
    panic!("boom");
}

extern "C" fn boundary_risky() {
    println!("boundary: about to panic");
    panic!("boom");
}

fn main() {
    // Keep the output focused on the two behaviors instead of printing the
    // default panic diagnostics and backtrace for the intentional abort.
    std::panic::set_hook(Box::new(|info| {
        let message = info
            .payload()
            .downcast_ref::<&str>()
            .copied()
            .or_else(|| info.payload().downcast_ref::<String>().map(String::as_str))
            .unwrap_or("non-string panic payload");
        println!("panic: {message}");
    }));

    // An ordinary Rust panic may unwind back to catch_unwind.
    let ordinary_result = std::panic::catch_unwind(ordinary_risky);
    println!("ordinary caught: {}", ordinary_result.is_err());

    // A panic cannot unwind out of an extern "C" function. The process
    // aborts here, before catch_unwind can return a second result.
    let boundary_result = std::panic::catch_unwind(|| boundary_risky());
    println!("boundary caught: {}", boundary_result.is_err());
}
