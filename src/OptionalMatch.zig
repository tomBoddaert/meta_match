//! Match an `Optional` type.
//!
//! https://ziglang.org/documentation/master/std/#std.builtin.Type.Optional

const std = @import("std");
const Optional = std.builtin.Type.Optional;

const TypeMatch = @import("type_match.zig").TypeMatch;
const match_error = @import("utils.zig").match_error;

child: ?TypeMatch = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: Optional) bool {
    if (self.child) |child| {
        if (!child.match(t.child)) return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Optional => |optional| self.match_info(optional),
        else => match_error("OptionalMatch.match", "Optional", T),
    };
}
