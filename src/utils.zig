const comptimePrint = @import("std").fmt.comptimePrint;

pub inline fn match_error(comptime self: []const u8, comptime expected: []const u8, comptime T: type) void {
    @compileError(comptimePrint("'{s}' expected 'T' to be a '{s}', found '{s}'", .{ self, expected, @typeName(T) }));
}
