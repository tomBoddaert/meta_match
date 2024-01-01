//! Match a param from a `Fn` type.
//!
//! https://ziglang.org/documentation/master/std/#A;std:builtin.Type.Fn.Param

const std = @import("std");
const Param = std.builtin.Type.Fn.Param;

const TypeMatch = @import("type_match.zig").TypeMatch;

is_generic: ?bool = null,
is_noalias: ?bool = null,
type: ??TypeMatch = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: Param) bool {
    if (self.is_generic) |is_generic| {
        if (t.is_generic != is_generic) return false;
    }

    if (self.is_noalias) |is_noalias| {
        if (t.is_noalias != is_noalias) return false;
    }

    if (self.type) |optional_type| {
        if (optional_type) |type_| {
            if (!type_.match(t.type orelse return false))
                return false;
        } else if (t.type != null)
            return false;
    }

    return true;
}
