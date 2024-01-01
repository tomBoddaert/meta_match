//! Match a `Pointer` type.
//!
//! https://ziglang.org/documentation/master/std/#A;std:builtin.Type.Pointer

const std = @import("std");
const builtin = std.builtin;
const Pointer = builtin.Type.Pointer;

const OneOfMatch = @import("one_of_match.zig").OneOfMatch;
const TypeMatch = @import("type_match.zig").TypeMatch;
const match_error = @import("utils.zig").match_error;

size: OneOfMatch(Pointer.Size) = .{ .any = {} },
is_const: ?bool = null,
is_volatile: ?bool = null,
/// TODO: when the `comptime_int` is replaced with `u16` in std, update it here
alignment: ?comptime_int = null,
address_space: ?builtin.AddressSpace = null,
child: ?TypeMatch = null,
is_allowzero: ?bool = null,
sentinel: ??*const anyopaque = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: Pointer) bool {
    if (!self.size.match(t.size)) return false;

    if (self.is_const) |is_const| {
        if (t.is_const != is_const) return false;
    }

    if (self.is_volatile) |is_volatile| {
        if (t.is_volatile != is_volatile) return false;
    }

    if (self.alignment) |alignment| {
        if (t.alignment != alignment) return false;
    }

    if (self.address_space) |address_space| {
        if (t.address_space != address_space) return false;
    }

    if (self.child) |child| {
        if (!child.match(t.child)) return false;
    }

    if (self.is_allowzero) |is_allowzero| {
        if (t.is_allowzero != is_allowzero) return false;
    }

    if (self.sentinel) |sentinel| {
        if (t.sentinel != sentinel) return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Pointer => |pointer| self.match_info(pointer),
        else => match_error("PointerMatch.match", "Pointer", T),
    };
}
