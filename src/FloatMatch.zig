//! Match a `Float` type.
//!
//! https://ziglang.org/documentation/master/std/#std.builtin.Type.Float

const std = @import("std");
const Float = std.builtin.Type.Float;

const match_error = @import("utils.zig").match_error;

bits: ?u16 = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: Float) bool {
    if (self.bits) |bits| {
        if (t.bits != bits) return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: anytype) bool {
    return switch (@typeInfo(T)) {
        .Float => |float| self.match_info(float),
        else => match_error("FloatMatch.match", "Float", T),
    };
}
