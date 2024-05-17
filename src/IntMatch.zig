//! Match an `Int` type.
//!
//! https://ziglang.org/documentation/master/std/#std.builtin.Type.Int

const std = @import("std");
const builtin = std.builtin;
const Int = builtin.Type.Int;

const match_error = @import("utils.zig").match_error;

signedness: ?builtin.Signedness = null,
bits: ?u16 = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: Int) bool {
    if (self.signedness) |signedness| {
        if (t.signedness != signedness) return false;
    }

    if (self.bits) |bits| {
        if (t.bits != bits) return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Int => |int| self.match_info(int),
        else => match_error("IntMatch.match", "Int", T),
    };
}
