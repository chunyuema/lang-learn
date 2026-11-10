use std::thread;

fn main() {
    let result = thread::spawn(|| {
        println!("worker: parsing");
        panic!("bad input on line 3");
    })
    .join();

    println!("main: joined, is_err = {}", result.is_err());
    if let Err(payload) = result {
        if let Some(message) = payload.downcast_ref::<&str>() {
            println!("main: worker panicked with {message:?}");
        }
    }
    println!("main: done");
}
