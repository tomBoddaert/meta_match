//! Match an `Enum` type.
//!
//! https://ziglang.org/documentation/master/std/#std.builtin.Type.Enum

const std = @import("std");
const Type = std.builtin.Type;
const Enum = Type.Enum;

const TypeMatch = @import("type_match.zig").TypeMatch;
const EnumFieldMatch = @import("EnumFieldMatch.zig");
const DeclarationMatch = @import("DeclarationMatch.zig");
const match_error = @import("utils.zig").match_error;

tag_type: ?TypeMatch = null,
fields: []const EnumFieldMatch = &.{},
exclusive_fields: bool = false,
decls: []const DeclarationMatch = &.{},
exclusive_decls: bool = false,
is_exhaustive: ?bool = null,

const Self = @This();

pub fn match_type_info(comptime self: Self, comptime T: type, comptime t: Enum) bool {
    if (self.tag_type) |tag_type| {
        if (!tag_type.match(t.tag_type)) return false;
    }

    if (self.exclusive_fields and t.fields.len != self.fields.len)
        return false;

    inline for (self.fields) |field| {
        inline for (t.fields) |t_field| {
            if (field.match_info(t_field)) break;
        } else return false;
    }

    if (self.exclusive_decls and t.decls.len != self.decls.len)
        return false;

    inline for (self.decls) |decl| {
        inline for (t.decls) |t_decl| {
            if (decl.match_parenttype_info(T, t_decl)) break;
        } else return false;
    }

    if (self.is_exhaustive) |is_exhaustive| {
        if (t.is_exhaustive != is_exhaustive) return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Enum => |enum_type| self.match_type_info(T, enum_type),
        else => match_error("EnumMatch.match", "Enum", T),
    };
}

test "meta_match.EnumMatch" {
    const testing = std.testing;

    const Unconstructable = enum {};
    const Basic = enum { a };

    const em_empty = Self{};
    try testing.expect(em_empty.match(Basic));
    try testing.expect(em_empty.match(Unconstructable));

    const em_unconstructable = Self{
        .exclusive_fields = true,
    };
    try testing.expect(em_unconstructable.match(Unconstructable));
    try testing.expect(!em_unconstructable.match(Basic));
}
