//! Match a `Frame` type.
//!
//! https://ziglang.org/documentation/master/std/#A;std:builtin.Type.Frame

const std = @import("std");
const Frame = std.builtin.Type.Frame;

const match_error = @import("utils.zig").match_error;

function: ?*const anyopaque = null,

const Self = @This();

pub fn match_info(comptime self: Self, comptime t: Frame) bool {
    if (self.function) |function| {
        if (t.function != function) return false;
    }

    return true;
}

pub inline fn match(comptime self: Self, comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .Frame => |frame| self.match_info(frame),
        else => match_error("FrameMatch.match", "Frame", T),
    };
}
