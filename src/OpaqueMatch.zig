//! Match an `Opaque` type.
//!
//! https://ziglang.org/documentation/master/std/#A;std:builtin.Type.Opaque

const std = @import("std");
const Opaque = std.builtin.Type.Opaque;

const DeclarationMatch = @import("DeclarationMatch.zig");
const match_error = @import("utils.zig").match_error;

decls: []const DeclarationMatch = &.{},
exclusive_decls: bool = false,

const Self = @This();

pub fn match_type_info(comptime self: Self, comptime T: type, comptime t: Opaque) bool {
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
        .Opaque => |opaque_| self.match_type_info(T, opaque_),
        else => match_error("OpaqueMatch.match", "Opaque", T),
    };
}
