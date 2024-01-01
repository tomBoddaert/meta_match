//! Match a `Vector` type.
//!
//! https://ziglang.org/documentation/master/std/#A;std:builtin.Type.Vector

const std = @import("std");
const Vector = std.builtin.Type.Vector;

const TypeMatch = @import("type_match.zig").TypeMatch;
const match_error = @import("utils.zig").match_error;

len: ?comptime_int = null,
child: ?TypeMatch = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: Vector) bool {
    if (self.len) |len| {
        if (t.len != len) return false;
    }

    if (self.child) |child| {
        if (!child.match(t.child)) return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Vector => |vector| self.match_info(vector),
        else => match_error("VectorMatch.match", "Vector", T),
    };
}
