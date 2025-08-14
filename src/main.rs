#![no_std]
#![no_main]

use core::panic::PanicInfo;

const VGA_BUFFER: *mut u8 = 0xb8000 as *mut u8;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[unsafe(no_mangle)]
pub extern "C" fn kernel_main() -> ! {
    unsafe {
        for i in 0..(80 * 25) {
            let off = i * 2;
            VGA_BUFFER.add(off).write_volatile(b' ');
            VGA_BUFFER.add(off + 1).write_volatile(0x07);
        }
    }

    loop {}
}
