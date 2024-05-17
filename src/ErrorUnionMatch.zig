//! Match an `ErrorUnion` type.
//!
//! https://ziglang.org/documentation/master/std/#std.builtin.Type.ErrorUnion

const std = @import("std");
const ErrorUnion = std.builtin.Type.ErrorUnion;

const ErrorSetMatch = @import("error_set_match.zig").ErrorSetMatch;
const TypeMatch = @import("type_match.zig").TypeMatch;
const match_error = @import("utils.zig").match_error;

error_set: ?ErrorSetMatch = null,
payload: ?TypeMatch = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: ErrorUnion) bool {
    if (self.error_set) |error_set| {
        if (!error_set.match(t.error_set)) return false;
    }

    if (self.payload) |payload| {
        if (!payload.match(t.payload)) return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .ErrorUnion => |error_union| self.match_info(error_union),
        else => match_error("ErrorUnionMatch.match", "ErrorUnion", T),
    };
}
