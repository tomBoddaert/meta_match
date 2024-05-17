const std = @import("std");
const Type = std.builtin.Type;
const ErrorSet = Type.ErrorSet;

const TypeMatch = @import("type_match.zig").TypeMatch;
const match_error = @import("utils.zig").match_error;

/// Match an `ErrorSet` type.
///
/// https://ziglang.org/documentation/master/std/#std.builtin.Type.ErrorSet
pub const ErrorSetMatch = union(enum) {
    by_errors: struct {
        errors: []const Type.Error = &.{},
        exclusive: bool = false,
        allow_global: bool = false,
    },
    global: void,
    any: void,

    const Self = @This();

    pub fn match_info(comptime self: Self, comptime t: ErrorSet) bool {
        return switch (self) {
            .by_errors => |errors| {
                const t_errors = t orelse return errors.allow_global;

                if (errors.exclusive and t_errors.len != errors.errors.len)
                    return false;

                inline for (errors.errors) |error_| {
                    inline for (t_errors) |t_error| {
                        if (std.mem.eql(u8, t_error.name, error_.name)) break;
                    } else return false;
                }

                return true;
            },
            .global => t == null,
            .any => true,
        };
    }

    pub fn match(comptime self: Self, comptime T: type) bool {
        return switch (@typeInfo(T)) {
            .ErrorSet => |error_set| self.match_info(error_set),
            else => match_error("ErrorSetMatch.match", "ErrorSet", T),
        };
    }
};
