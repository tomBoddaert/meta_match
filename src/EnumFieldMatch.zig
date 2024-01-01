//! Match an field from an `Enum` type.
//!
//! https://ziglang.org/documentation/master/std/#A;std:builtin.Type.EnumField

const std = @import("std");
const EnumField = std.builtin.Type.EnumField;

name: []const u8,
value: ?comptime_int = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: EnumField) bool {
    if (!std.mem.eql(u8, t.name, self.name)) return false;

    if (self.value) |value| {
        if (t.value != value) return false;
    }

    return true;
}
