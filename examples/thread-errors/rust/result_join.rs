use std::thread;

#[derive(Debug)]
enum WorkError {
    DiskFull,
    BadFlag(String),
}

fn work(id: usize) -> Result<(), WorkError> {
    match id {
        0 => Err(WorkError::DiskFull),
        2 => Err(WorkError::BadFlag("--fast".to_string())),
        3 => panic!("something is wrong here"),
        _ => Ok(()),
    }
}

fn main() {
    let handles: Vec<_> = (0..4)
        .map(|id| thread::spawn(move || work(id)))
        .collect();

    for (id, handle) in handles.into_iter().enumerate() {
        match handle.join() {
            Ok(Ok(())) => println!("{id}: ok"),
            Ok(Err(WorkError::BadFlag(flag))) => println!("{id}: bad flag {flag}"),
            Ok(Err(error)) => println!("{id}: error {error:?}"),
            Err(_) => println!("{id}: panicked"),
        }
    }
}
