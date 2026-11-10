use std::sync::mpsc;
use std::thread;
use std::time::Duration;

#[derive(Debug)]
enum WorkError {
    DiskFull,
    BadFlag(String),
}

fn work(id: u64) -> Result<(), WorkError> {
    thread::sleep(Duration::from_millis(25 * (4 - id)));
    match id {
        0 => Err(WorkError::DiskFull),
        2 => Err(WorkError::BadFlag("--fast".to_string())),
        3 => panic!("something is wrong here"),
        _ => Ok(()),
    }
}

fn main() {
    let (sender, receiver) = mpsc::channel();
    let mut handles = Vec::new();
    for id in 0..4 {
        let sender = sender.clone();
        handles.push(thread::spawn(move || {
            sender.send((id, work(id))).unwrap();
        }));
    }
    drop(sender);

    let mut received = 0;
    for (id, result) in receiver {
        received += 1;
        match result {
            Ok(()) => println!("{id}: ok"),
            Err(WorkError::DiskFull) => println!("{id}: error DiskFull"),
            Err(WorkError::BadFlag(flag)) => println!("{id}: error BadFlag({flag:?})"),
        }
    }
    let panicked = handles
        .into_iter()
        .map(|handle| handle.join().is_err())
        .filter(|did_panic| *did_panic)
        .count();
    println!("main: received {received} of 4; joined {panicked} panic");
}
