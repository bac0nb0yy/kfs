#![no_std]
#![no_main]

use core::panic::PanicInfo;

const VGA_BUFFER: *mut u8 = 0xb8000 as *mut u8;
const HEIGHT: usize = 25;
const WIDTH: usize = 80;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[unsafe(no_mangle)]
pub extern "C" fn kernel_main() -> ! {
    unsafe {
        for i in 0..(HEIGHT * WIDTH) {
            let off: usize = i << 1;
            VGA_BUFFER.add(off).write_volatile(b' ');
            VGA_BUFFER.add(off + 1).write_volatile(0x07);
        }
        let mid_off: usize = (HEIGHT / 2 * WIDTH + (WIDTH / 2 - 1)) << 1;

        VGA_BUFFER.add(mid_off).write_volatile(b'4');
        VGA_BUFFER.add(mid_off + 1).write_volatile(0x07);

        VGA_BUFFER.add(mid_off + 2).write_volatile(b'2');
        VGA_BUFFER.add(mid_off + 3).write_volatile(0x07);
    }

    loop {}
}
