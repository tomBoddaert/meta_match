//! Match an `Array` type.
//!
//! https://ziglang.org/documentation/master/std/#std.builtin.Type.Array

const std = @import("std");
const Array = std.builtin.Type.Array;

const TypeMatch = @import("type_match.zig").TypeMatch;
const match_error = @import("utils.zig").match_error;

len: ?comptime_int = null,
child: ?TypeMatch = null,
sentinel: ??*const anyopaque = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: Array) bool {
    if (self.len) |len| {
        if (t.len != len) return false;
    }

    if (self.child) |child| {
        if (t.child != child) return false;
    }

    if (self.sentinel) |sentinel| {
        if (t.sentinel != sentinel) return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Array => |array| self.match_info(array),
        else => match_error("ArrayMatch.match", "Array", T),
    };
}
