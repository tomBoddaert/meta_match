//! Match a declaration from a container.
//!
//! https://ziglang.org/documentation/master/std/#A;std:builtin.Type.Declaration

const std = @import("std");
const Declaration = std.builtin.Type.Declaration;

const TypeMatch = @import("type_match.zig").TypeMatch;

name: []const u8,
type: ?TypeMatch = null,

const Self = @This();

pub fn match_parenttype_info(comptime self: Self, comptime Parent: type, comptime t: Declaration) bool {
    if (!std.mem.eql(u8, t.name, self.name)) return false;

    if (self.type) |type_| {
        const T = @TypeOf(@field(Parent, self.name));
        if (!type_.match(T)) return false;
    }

    return true;
}
