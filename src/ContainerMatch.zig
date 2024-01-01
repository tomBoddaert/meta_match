//! Match any [container](https://ziglang.org/documentation/master/#toc-Containers) type.
//!
//! Structs, enums, unions and opaques are all containers.

const std = @import("std");
const Type = std.builtin.Type;
const Struct = Type.Struct;
const Enum = Type.Enum;
const Union = Type.Union;
const Opaque = Type.Opaque;
const Declaration = Type.Declaration;

const DeclarationMatch = @import("DeclarationMatch.zig");
const match_error = @import("utils.zig").match_error;

/// Any container type.
pub const Container = union(enum) {
    Struct: Struct,
    Enum: Enum,
    Union: Union,
    Opaque: Opaque,

    pub fn from(comptime value: anytype) Container {
        return switch (@TypeOf(value)) {
            type => from(@typeInfo(value)),
            Struct => Container{ .Struct = value },
            Enum => Container{ .Enum = value },
            Union => Container{ .Union = value },
            Opaque => Container{ .Opaque = value },
            else => match_error("ContainerMatch.Container", "Struct / Enum / Union / Opaque", @TypeOf(value)),
        };
    }

    pub fn decls(comptime self: Container) []const Declaration {
        return switch (self) {
            .Struct => |struct_| struct_.decls,
            .Enum => |enum_| enum_.decls,
            .Union => |union_| union_.decls,
            .Opaque => |opaque_| opaque_.decls,
        };
    }
};

decls: []const DeclarationMatch = &.{},
exclusive_decls: bool = false,

const Self = @This();

pub fn match_type_info(comptime self: Self, comptime T: type, comptime t: Container) bool {
    const t_decls = t.decls();

    if (self.exclusive_decls and t_decls.len != self.decls.len)
        return false;

    inline for (self.decls) |decl| {
        inline for (t_decls) |t_decl| {
            if (decl.match_parenttype_info(T, t_decl)) break;
        } else return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Struct => |struct_| self.match_type_info(T, Container{ .Struct = struct_ }),
        .Enum => |enum_| self.match_type_info(T, Container{ .Enum = enum_ }),
        .Union => |union_| self.match_type_info(T, Container{ .Union = union_ }),
        .Opaque => |opaque_| self.match_type_info(T, Container{ .Opaque = opaque_ }),
        else => match_error("ContainerMatch.match", "Struct / Enum / Union / Opaque", T),
    };
}
