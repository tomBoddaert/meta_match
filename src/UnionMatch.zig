//! Match a `Union` type.
//!
//! https://ziglang.org/documentation/master/std/#A;std:builtin.Type.Union

const std = @import("std");
const Type = std.builtin.Type;
const Union = Type.Union;

const OneOfMatch = @import("one_of_match.zig").OneOfMatch;
const TypeMatch = @import("type_match.zig").TypeMatch;
const UnionFieldMatch = @import("UnionFieldMatch.zig");
const DeclarationMatch = @import("DeclarationMatch.zig");
const match_error = @import("utils.zig").match_error;

layout: OneOfMatch(Type.ContainerLayout) = .{ .any = {} },
tag_type: ??TypeMatch = null,
fields: []const UnionFieldMatch = &.{},
exclusive_fields: bool = false,
decls: []const DeclarationMatch = &.{},
exclusive_decls: bool = false,

const Self = @This();

pub fn match_type_info(comptime self: Self, comptime T: type, comptime t: Union) bool {
    if (!self.layout.match(t.layout)) return false;

    if (self.tag_type) |optional_tag_type| {
        if (optional_tag_type) |tag_type| {
            const t_tag_type = t.tag_type orelse return false;
            if (!tag_type.match(t_tag_type))
                return false;
        } else if (t.tag_type != null)
            return false;
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

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Union => |union_| self.match_type_info(T, union_),
        else => match_error("UnionMatch.match", "Union", T),
    };
}

test "meta_match.UnionMatch" {
    const testing = std.testing;

    const Magnitude = union { x: f32, y: f32 };
    const Vector = union(enum) { x: f32, y: f32 };
    const PackedMagnitude = packed union { x: f32, y: f32 };

    const um_empty = Self{};
    try testing.expect(um_empty.match(Magnitude));

    const um_tagged = Self{ .tag_type = .any };
    try testing.expect(um_tagged.match(Vector));
    try testing.expect(!um_tagged.match(Magnitude));

    const sm_packed_layout = Self{
        .layout = .{ .options = &.{.Packed} },
    };
    try testing.expect(sm_packed_layout.match(PackedMagnitude));
    try testing.expect(!sm_packed_layout.match(Magnitude));
}
