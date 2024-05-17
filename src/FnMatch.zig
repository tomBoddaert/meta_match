//! Match a `Fn` type.
//!
//! https://ziglang.org/documentation/master/std/#std.builtin.Type.Fn

const std = @import("std");
const builtin = std.builtin;
const Fn = builtin.Type.Fn;

const OneOfMatch = @import("one_of_match.zig").OneOfMatch;
const TypeMatch = @import("type_match.zig").TypeMatch;
const ParamMatch = @import("ParamMatch.zig");
const match_error = @import("utils.zig").match_error;

calling_convention: OneOfMatch(builtin.CallingConvention) = .{ .any = {} },
is_generic: ?bool = null,
is_var_args: ?bool = null,
// TODO: when this is made not optional in std, remove an optional
return_type: ??TypeMatch = null,
params: ?[]const ParamMatch = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: Fn) bool {
    if (!self.calling_convention.match(t.calling_convention)) return false;

    if (self.is_generic) |is_generic| {
        if (t.is_generic != is_generic) return false;
    }

    if (self.is_var_args) |is_var_args| {
        if (t.is_var_args != is_var_args) return false;
    }

    if (self.return_type) |optional_return_type| {
        if (optional_return_type) |return_type| {
            if (!return_type.match(t.return_type orelse return false))
                return false;
        } else if (t.return_type != null)
            return false;
    }

    if (self.params) |params| {
        if (t.params.len != params.len) return false;

        inline for (params, t.params) |param, t_param| {
            if (!param.match_info(t_param)) return false;
        }
    }

    return true;
}

pub fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Fn => |fn_type| self.match_info(fn_type),
        else => match_error("FnMatch.match", "Fn", T),
    };
}
