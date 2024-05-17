//! Match a field from a `Union` type.
//!
//! https://ziglang.org/documentation/master/std/#std.builtin.Type.UnionField

const std = @import("std");
const UnionField = std.builtin.Type.UnionField;

const TypeMatch = @import("type_match.zig").TypeMatch;

name: []const u8,
type: ?TypeMatch = null,
alignment: ?comptime_int = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: UnionField) bool {
    if (!std.mem.eql(u8, t.name, self.name)) return false;

    if (self.type) |type_| {
        if (!type_.match(t.type)) return false;
    }

    if (self.alignment) |alignment| {
        if (t.alignment != alignment) return false;
    }

    return true;
}
