//! Match a field from a `Struct` type.
//!
//! https://ziglang.org/documentation/master/std/#A;std:builtin.Type.StructField

const std = @import("std");
const StructField = std.builtin.Type.StructField;

const TypeMatch = @import("type_match.zig").TypeMatch;

name: []const u8,
type: ?TypeMatch = null,
/// Warning: This is checked by pointer equality, not value!
default_value: ??*const anyopaque = null,
is_comptime: ?bool = null,
alignment: ?comptime_int = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: StructField) bool {
    if (!std.mem.eql(u8, t.name, self.name)) return false;

    if (self.type) |type_| {
        if (!type_.match(t.type)) return false;
    }

    if (self.default_value) |default_value| {
        // TODO: because the types are anyopaque, this currently
        // checks by pointer equality rather than value
        if (t.default_value != default_value) return false;
    }

    if (self.is_comptime) |is_comptime| {
        if (t.is_comptime != is_comptime) return false;
    }

    if (self.alignment) |alignment| {
        if (t.alignment != alignment) return false;
    }

    return true;
}
