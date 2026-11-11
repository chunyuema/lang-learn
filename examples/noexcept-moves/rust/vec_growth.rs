struct Item {
    id: i32,
}

impl Clone for Item {
    fn clone(&self) -> Self {
        println!("  clone {}", self.id);
        Self { id: self.id }
    }
}

impl Drop for Item {
    fn drop(&mut self) {
        println!("  drop {}", self.id);
    }
}

fn main() {
    let mut items: Vec<Item> = Vec::new();
    for id in 0..6 {
        println!(
            "push {id} (capacity {}, buffer {:p})",
            items.capacity(),
            items.as_ptr()
        );
        items.push(Item { id });
    }
    println!("end (capacity {})", items.capacity());
}
