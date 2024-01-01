//!zig-autodoc-guide: ../README.md
//! This project assumes that all type infos passed into functions
//! were created by `@typeInfo`.

pub const TypeMatch = @import("type_match.zig").TypeMatch;
pub const ContainerMatch = @import("ContainerMatch.zig");
pub const IntMatch = @import("IntMatch.zig");
pub const FloatMatch = @import("FloatMatch.zig");
pub const PointerMatch = @import("PointerMatch.zig");
pub const ArrayMatch = @import("ArrayMatch.zig");
pub const StructMatch = @import("StructMatch.zig");
pub const StructFieldMatch = @import("StructFieldMatch.zig");
pub const DeclarationMatch = @import("DeclarationMatch.zig");
pub const OptionalMatch = @import("OptionalMatch.zig");
pub const ErrorUnionMatch = @import("ErrorUnionMatch.zig");
pub const ErrorSetMatch = @import("error_set_match.zig").ErrorSetMatch;
pub const EnumMatch = @import("EnumMatch.zig");
pub const EnumFieldMatch = @import("EnumFieldMatch.zig");
pub const UnionMatch = @import("UnionMatch.zig");
pub const UnionFieldMatch = @import("UnionFieldMatch.zig");
pub const FnMatch = @import("FnMatch.zig");
pub const ParamMatch = @import("ParamMatch.zig");
pub const OpaqueMatch = @import("OpaqueMatch.zig");
pub const FrameMatch = @import("FrameMatch.zig");
pub const AnyFrameMatch = @import("AnyFrameMatch.zig");
pub const VectorMatch = @import("VectorMatch.zig");

pub const OneOfMatch = @import("one_of_match.zig").OneOfMatch;

test {
    const std = @import("std");
    const testing = std.testing;

    testing.refAllDecls(@This());
}
