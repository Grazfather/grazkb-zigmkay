const std = @import("std");

const zmk = @import("zigmkay");
const zigmkay = zmk.zigmkay;
const dk = zmk.keycodes.dk;
const core = zigmkay.core;
const us = zmk.keycodes.us;
const microzig = zmk.microzig;
const rp2xxx = microzig.hal;
const time = rp2xxx.time;
const gpio = rp2xxx.gpio;

const keymap = @import("keymap.zig");

// uart

const uart_tx_pin = gpio.num(0);
const uart_rx_pin = gpio.num(1);

// zig fmt: off
pub const pin_config = rp2xxx.pins.GlobalConfiguration{
    // .GPIO17 = .{ .name = "led", .direction = .out },

    .GPIO28 = .{ .name = "row1", .direction = .in },
    .GPIO27 = .{ .name = "row2", .direction = .in },
    .GPIO26 = .{ .name = "row3", .direction = .in },
    .GPIO15 = .{ .name = "row4", .direction = .in },
    .GPIO14 = .{ .name = "row5", .direction = .in },
    .GPIO3 = .{ .name = "row6", .direction = .in },
    .GPIO4 = .{ .name = "row7", .direction = .in },
    .GPIO5 = .{ .name = "row8", .direction = .in },
    .GPIO6 = .{ .name = "row9", .direction = .in },
    .GPIO7 = .{ .name = "row10", .direction = .in },

    .GPIO8 = .{ .name = "col1", .direction = .out },
    .GPIO9 = .{ .name = "col2", .direction = .out },
    .GPIO10 = .{ .name = "col3", .direction = .out },
    .GPIO11 = .{ .name = "col4", .direction = .out },
    .GPIO12 = .{ .name = "col5", .direction = .out },
    .GPIO13 = .{ .name = "col6", .direction = .out },
};
pub const p = pin_config.pins();
pub const pin_mapppings = [keymap.key_count]?[2]usize{
            .{0,5}, .{0,4}, .{0,3}, .{0,2}, .{0,1}, .{0,0},      .{5,0}, .{5,1}, .{5,2}, .{5,3}, .{5,4}, .{5,5},
            .{1,5}, .{1,4}, .{1,3}, .{1,2}, .{1,1}, .{1,0},      .{6,0}, .{6,1}, .{6,2}, .{6,3}, .{6,4}, .{6,5},
            .{2,5}, .{2,4}, .{2,3}, .{2,2}, .{2,1}, .{2,0},      .{7,0}, .{7,1}, .{7,2}, .{7,3}, .{7,4}, .{7,5},
            .{3,5}, .{3,4}, .{3,3}, .{3,2}, .{3,1}, .{3,0},      .{8,0}, .{8,1}, .{8,2}, .{8,3}, .{8,4}, .{8,5},
                    .{4,4}, .{4,3}, .{4,2}, .{4,1}, .{4,0},      .{9,0}, .{9,1}, .{9,2}, .{9,3}, .{9,4},
};

pub const scanner_settings = zigmkay.matrix_scanning.ScannerSettings{
    .debounce = .{ .ms = 50 },
};

// zig fmt: on
pub const cols = [_]rp2xxx.gpio.Pin{ p.col1, p.col2, p.col3, p.col4, p.col5, p.col6 };
pub const rows = [_]rp2xxx.gpio.Pin{ p.row1, p.row2, p.row3, p.row4, p.row5, p.row6, p.row7, p.row8, p.row9, p.row10 };

const primary = true;

pub fn main() !void {

    // Init pins
    pin_config.apply(); // dont know how this could be done inside the module, but it needs to be done for things to work
    const uart = init_uart();
    // blink_led(1, 300);
    zigmkay.run_primary(
        keymap.dimensions,
        cols[0..],
        rows[0..],
        scanner_settings,
        keymap.combos[0..],
        &keymap.custom_functions,
        pin_mapppings,
        &keymap.keymap,
        keymap.sides,
        uart,
    ) catch {
        // blink_led(100000, 50);
    };
}

pub fn init_uart() rp2xxx.uart.UART {
    // uart init
    uart_tx_pin.set_function(.uart);
    uart_rx_pin.set_function(.uart);
    const uart = rp2xxx.uart.instance.num(0);
    uart.apply(.{ .clock_config = rp2xxx.clock_config, .baud_rate = 9600 });
    return uart;
}

pub fn blink_led(blink_count: u32, interval_ms: u32) void {
    var counter = blink_count;
    while (counter > 0) : (counter -= 1) {
        p.led.put(1);
        time.sleep_us(interval_ms * 1000);
        p.led.put(0);
        time.sleep_us(interval_ms * 1000);
    }
}
