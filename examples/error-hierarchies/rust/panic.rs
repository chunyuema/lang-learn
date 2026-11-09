fn fetch() -> String {
    panic!("timeout after 1500 ms");
}

fn main() {
    match std::panic::catch_unwind(fetch) {
        Ok(body) => println!("got {body}"),
        Err(payload) => println!("caught: {:?}", payload.downcast_ref::<&str>()),
    }
    println!("still running");
}
