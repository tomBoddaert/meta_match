const std = @import("std");
const Type = std.builtin.Type;

const ContainerMatch = @import("ContainerMatch.zig");
const IntMatch = @import("IntMatch.zig");
const FloatMatch = @import("FloatMatch.zig");
const PointerMatch = @import("PointerMatch.zig");
const ArrayMatch = @import("ArrayMatch.zig");
const StructMatch = @import("StructMatch.zig");
const OptionalMatch = @import("OptionalMatch.zig");
const ErrorUnionMatch = @import("ErrorUnionMatch.zig");
const ErrorSetMatch = @import("error_set_match.zig").ErrorSetMatch;
const EnumMatch = @import("EnumMatch.zig");
const UnionMatch = @import("UnionMatch.zig");
const FnMatch = @import("FnMatch.zig");
const OpaqueMatch = @import("OpaqueMatch.zig");
const FrameMatch = @import("FrameMatch.zig");
const AnyFrameMatch = @import("AnyFrameMatch.zig");
const VectorMatch = @import("VectorMatch.zig");

/// Match a type.
///
/// https://ziglang.org/documentation/master/std/#std.builtin.Type
pub const TypeMatch = union(enum) {
    any: void,
    by_type: type,
    container: *const ContainerMatch,

    Type: void,
    Void: void,
    Bool: void,
    NoReturn: void,
    Int: *const IntMatch,
    Float: *const FloatMatch,
    Pointer: *const PointerMatch,
    Array: *const ArrayMatch,
    Struct: *const StructMatch,
    ComptimeFloat: void,
    ComptimeInt: void,
    Undefined: void,
    Null: void,
    Optional: *const OptionalMatch,
    ErrorUnion: *const ErrorUnionMatch,
    ErrorSet: *const ErrorSetMatch,
    Enum: *const EnumMatch,
    Union: *const UnionMatch,
    Fn: *const FnMatch,
    Opaque: *const OpaqueMatch,
    Frame: *const FrameMatch,
    AnyFrame: *const AnyFrameMatch,
    Vector: *const VectorMatch,
    EnumLiteral: void,

    const Self = @This();

    pub fn match_type_info(comptime self: Self, comptime T: type, comptime t: Type) bool {
        return switch (self) {
            .any => true,
            .by_type => |type_| T == type_,
            .container => |container| switch (t) {
                .Struct => |struct_| container.match_type_info(T, .{ .Struct = struct_ }),
                .Enum => |enum_| container.match_type_info(T, .{ .Enum = enum_ }),
                .Union => |union_| container.match_type_info(T, .{ .Union = union_ }),
                .Opaque => |opaque_| container.match_type_info(T, .{ .Opaque = opaque_ }),
                else => false,
            },

            .Type => t == .Type,
            .Void => t == .Void,
            .Bool => t == .Bool,
            .NoReturn => t == .NoReturn,
            .Int => |int| switch (t) {
                .Int => |int_type| int.match_info(int_type),
                else => false,
            },
            .Float => |float| switch (t) {
                .Float => |float_type| float.match_info(float_type),
                else => false,
            },
            .Pointer => |pointer| switch (t) {
                .Pointer => |pointer_type| pointer.match_info(pointer_type),
                else => false,
            },
            .Array => |array| switch (t) {
                .Array => |array_type| array.match_info(array_type),
                else => false,
            },
            .Struct => |struct_| switch (t) {
                .Struct => |struct_type| struct_.match_type_info(T, struct_type),
                else => false,
            },
            .ComptimeFloat => t == .ComptimeFloat,
            .ComptimeInt => t == .ComptimeInt,
            .Undefined => t == .Undefined,
            .Null => t == .Null,
            .Optional => |optional| switch (t) {
                .Optional => |optional_type| optional.match_info(optional_type),
                else => false,
            },
            .ErrorUnion => |error_union| switch (t) {
                .ErrorUnion => |error_union_type| error_union.match_info(error_union_type),
                else => false,
            },
            .ErrorSet => |error_set| switch (t) {
                .ErrorSet => |error_set_type| error_set.match_info(error_set_type),
                else => false,
            },
            .Enum => |enum_| switch (t) {
                .Enum => |enum_type| enum_.match_type_info(T, enum_type),
                else => false,
            },
            .Union => |union_| switch (t) {
                .Union => |union_type| union_.match_type_info(T, union_type),
                else => false,
            },
            .Fn => |fn_| switch (t) {
                .Fn => |fn_type| fn_.match_info(fn_type),
                else => false,
            },
            .Opaque => |opaque_| switch (t) {
                .Opaque => |opaque_type| opaque_.match_type_info(T, opaque_type),
                else => false,
            },
            .Frame => |frame| switch (t) {
                .Frame => |frame_type| frame.match_info(frame_type),
                else => false,
            },
            .AnyFrame => |any_frame| switch (t) {
                .AnyFrame => |any_frame_type| any_frame.match_info(any_frame_type),
                else => false,
            },
            .Vector => |vector| switch (t) {
                .Vector => |vector_type| vector.match_info(vector_type),
                else => false,
            },
            .EnumLiteral => t == .EnumLiteral,
        };
    }

    pub inline fn match(comptime self: Self, comptime T: type) bool {
        return self.match_type_info(T, @typeInfo(T));
    }

    pub fn from(comptime t: anytype) Self {
        // TODO: If it is another match, wrap it in this is possible, if it is a type, wrap it in by_type
        return switch (@TypeOf(t)) {
            type => from(@typeInfo(t)),
            Type => {
                @compileError("'TypeMatch.from' is not yet implemented");
            },
            else => @compileError(std.fmt.comptimePrint("'TypeMatch.from' expected 't' to be either a 'type' or a 'std.builtin.Type', found '{s}'", .{@typeName(@TypeOf(t))})),
        };
    }
};

test "meta_match.TypeMatch" {
    const testing = std.testing;

    const tm_type = TypeMatch{
        .Type = void{},
    };
    try testing.expect(tm_type.match(type));

    const tm_void = TypeMatch{
        .Void = void{},
    };
    try testing.expect(tm_void.match(void));

    const tm_bool = TypeMatch{
        .Bool = void{},
    };
    try testing.expect(tm_bool.match(bool));

    const tm_no_return = TypeMatch{
        .NoReturn = void{},
    };
    try testing.expect(tm_no_return.match(noreturn));

    const tm_int = TypeMatch{
        .Int = &IntMatch{},
    };
    try testing.expect(tm_int.match(u8));

    const tm_float = TypeMatch{
        .Float = &FloatMatch{},
    };
    try testing.expect(tm_float.match(f32));

    const tm_pointer = TypeMatch{
        .Pointer = &PointerMatch{},
    };
    try testing.expect(tm_pointer.match(*const u8));

    const tm_array = TypeMatch{
        .Array = &ArrayMatch{},
    };
    try testing.expect(tm_array.match([5]u8));

    const tm_struct = TypeMatch{
        .Struct = &StructMatch{},
    };
    try testing.expect(tm_struct.match(StructMatch));

    const tm_optional = TypeMatch{
        .Optional = &OptionalMatch{},
    };
    try testing.expect(tm_optional.match(?u8));

    const tm_error_union = TypeMatch{
        .ErrorUnion = &ErrorUnionMatch{},
    };
    try testing.expect(tm_error_union.match(error{}!u8));

    const tm_error_set = TypeMatch{
        .ErrorSet = &ErrorSetMatch{ .any = {} },
    };
    try testing.expect(tm_error_set.match(error{}));

    const tm_enum = TypeMatch{
        .Enum = &EnumMatch{},
    };
    try testing.expect(tm_enum.match(enum {}));

    const tm_union = TypeMatch{
        .Union = &UnionMatch{},
    };
    try testing.expect(tm_union.match(union {}));

    const tm_fn = TypeMatch{
        .Fn = &FnMatch{},
    };
    try testing.expect(tm_fn.match(fn () void));

    const tm_opaque = TypeMatch{
        .Opaque = &OpaqueMatch{},
    };
    try testing.expect(tm_opaque.match(opaque {}));

    // TODO: test Frame and AnyFrame once async is added to the self-hosted compiler

    const tm_vector = TypeMatch{
        .Vector = &VectorMatch{},
    };
    try testing.expect(tm_vector.match(@Vector(4, u8)));
}
