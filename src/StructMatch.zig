//! Match a `Struct` type.
//!
//! https://ziglang.org/documentation/master/std/#std.builtin.Type.Struct

const std = @import("std");
const Type = std.builtin.Type;
const Struct = Type.Struct;

const OneOfMatch = @import("one_of_match.zig").OneOfMatch;
const StructFieldMatch = @import("StructFieldMatch.zig");
const DeclarationMatch = @import("DeclarationMatch.zig");
const match_error = @import("utils.zig").match_error;

layout: OneOfMatch(Type.ContainerLayout) = .{ .any = {} },
backing_integer: ??type = null,
fields: []const StructFieldMatch = &.{},
exclusive_fields: bool = false,
decls: []const DeclarationMatch = &.{},
exclusive_decls: bool = false,
is_tuple: ?bool = null,

const Self = @This();

pub fn match_type_info(comptime self: Self, comptime T: type, comptime t: Struct) bool {
    if (!self.layout.match(t.layout)) return false;

    if (self.backing_integer) |backing_integer| {
        if (t.backing_integer != backing_integer) return false;
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

    if (self.is_tuple) |is_tuple| {
        if (t.is_tuple != is_tuple) return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Struct => |struct_| self.match_type_info(T, struct_),
        else => match_error("StructMatch.match", "Struct", T),
    };
}

test "meta_match.StructMatch" {
    const testing = std.testing;

    const Point = struct { x: f32, y: f32 };
    const PackedPoint = packed struct { x: f32, y: f32 };
    const HideablePoint = struct { x: f32, y: f32, hidden: bool };
    const HiddenPoint = struct { x: f32, y: f32, hidden: bool = false };
    const UnhideablePoint = struct { x: f32, y: f32, hidden: void };
    const ColouredPoint = struct {
        x: f32,
        y: f32,
        colour: Colour,
        pub const Colour = struct { u8, u8, u8 };
    };

    const sm_empty = Self{};
    try testing.expect(sm_empty.match(Point));

    const sm_packed_layout = Self{
        .layout = .{ .options = &.{.@"packed"} },
    };
    try testing.expect(sm_packed_layout.match(PackedPoint));
    try testing.expect(!sm_packed_layout.match(Point));

    const sm_bool_field = Self{
        .fields = &.{.{ .name = "hidden", .type = .Bool }},
    };
    try testing.expect(sm_bool_field.match(HideablePoint));
    try testing.expect(!sm_bool_field.match(Point));
    try testing.expect(!sm_bool_field.match(UnhideablePoint));

    const sm_bool_field_default = Self{
        .fields = &.{.{
            .name = "hidden",
            .type = .Bool,
            .default_value = @typeInfo(HiddenPoint).Struct.fields[2].default_value,
        }},
    };
    try testing.expect(sm_bool_field_default.match(HiddenPoint));
    try testing.expect(!sm_bool_field_default.match(HideablePoint));
    try testing.expect(!sm_bool_field_default.match(Point));

    const sm_type_decl = Self{
        .decls = &.{.{ .name = "Colour", .type = .Type }},
    };
    try testing.expect(sm_type_decl.match(ColouredPoint));
    try testing.expect(!sm_type_decl.match(Point));

    // TODO: add function decl test once FnMatch is added
    // const sm_fn_decl = Self{ .decls = &.{.{ .name = "draw", .type = .{.Fn = } }} };
}
