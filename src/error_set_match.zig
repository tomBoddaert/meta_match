const std = @import("std");
const Type = std.builtin.Type;
const ErrorSet = Type.ErrorSet;

const TypeMatch = @import("type_match.zig").TypeMatch;
const match_error = @import("utils.zig").match_error;

/// Match an `ErrorSet` type.
///
/// https://ziglang.org/documentation/master/std/#A;std:builtin.Type.ErrorSet
pub const ErrorSetMatch = union(enum) {
    by_type: TypeMatch,
    by_errors: struct {
        errors: []const Type.Error = &.{},
        exclusive: bool = false,
    },
    null: void,

    const Self = @This();
    pub const Any = Self{ .by_errors = .{} };

    pub fn match_type_info(comptime self: Self, comptime T: type, comptime t: ErrorSet) bool {
        return switch (self) {
            .by_type => |type_| type_.match_with(T, t),
            .by_errors => |errors| {
                const t_errors = t orelse return false;

                if (errors.exclusive and t_errors.len != errors.errors.len)
                    return false;

                inline for (errors.errors) |error_| {
                    inline for (t_errors) |t_error| {
                        if (std.mem.eql(u8, t_error.name, error_.name)) break;
                    } else return false;
                }

                return true;
            },
            .null => t == null,
        };
    }

    pub fn match(comptime self: Self, comptime T: type) bool {
        return switch (@typeInfo(T)) {
            .ErrorSet => |error_set| self.match_type_info(T, error_set),
            else => match_error("ErrorSetMatch.match", "ErrorSet", T),
        };
    }
};
