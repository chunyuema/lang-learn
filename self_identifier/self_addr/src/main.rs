use ::std::ptr::addr_of;

struct Rectangle {
    width: u32,
    heigth: i32,
}

impl Rectangle {
    fn check_address(self) {
        println!("check address will move the data from 'rect' to 'self', we will lose 'rect'");
        // This self will be a different variable with different address
        let self_address = addr_of!(self) as usize;
        println!(
            "Inside the function call, the address of self is 0x{:x}",
            self_address
        );

        let data_addr = (&self as *const Rectangle) as usize;
        println!("Inside check_address, data address is 0x{:x}", data_addr);
    }

    fn check_address_ref(&self) {
        println!("check_address_ref let 'self' borrows from 'rect', no move, we still have 'rect' afterwards");
        let self_address = addr_of!(self) as usize;
        println!(
            "Inside the check_address_ref, the address of self is 0x{:x}",
            self_address
        );

        let data_addr = (self as *const Rectangle) as usize;
        println!(
            "Inside check_address_ref, data address is 0x{:x}",
            data_addr
        );
    }
}

fn main() {
    let rect = Rectangle {
        width: 10,
        heigth: 20,
    };
    let rect_addr = addr_of!(rect) as usize;
    println!(
        "Inside main function call, the address of rect is 0x{:x}",
        rect_addr
    );
    let data_addr = (&rect as *const Rectangle) as usize;
    println!(
        "Inside main fucntion call, data address is 0x{:x}",
        data_addr
    );

    println!("=================");
    // call this first before calling check_address, since that will make use lose rect
    rect.check_address_ref();

    println!("=================");
    // rect will be moved to self, and we are no longer going to be able to use it
    rect.check_address();

    // println!("rectangle is : {}{}", rect.width, rect.heigth);
    //                                ^^^^^^^^^^^ value borrowed here after move
}
