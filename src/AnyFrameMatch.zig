//! Match an `AnyFrame` type.
//!
//! https://ziglang.org/documentation/master/std/#A;std:builtin.Type.AnyFrame

const std = @import("std");
const AnyFrame = std.builtin.Type.AnyFrame;

const TypeMatch = @import("type_match.zig").TypeMatch;
const match_error = @import("utils.zig").match_error;

child: ??TypeMatch = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: AnyFrame) bool {
    if (self.child) |optional_child| {
        if (optional_child) |child| {
            if (!child.match(t.child orelse return false))
                return false;
        } else if (t.child != null)
            return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .AnyFrame => |any_frame_type| self.match_info(any_frame_type),
        else => match_error("AnyFrameMatch.match", "AnyFrame", T),
    };
}
