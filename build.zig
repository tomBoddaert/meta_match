const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root = .{ .path = "src/root.zig" };
    const mod = b.addModule("meta_match", .{
        .root_source_file = root,
    });
    _ = mod;

    // Add 'test' step
    const unit_tests = b.addTest(.{
        // Set the root name in the docs
        .name = "meta_match",
        .root_source_file = root,
        .target = target,
        .optimize = optimize,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // Add 'fmt' step
    const format = b.addFmt(.{
        .paths = &.{"src/"},
    });

    const format_step = b.step("fmt", "Format source");
    format_step.dependOn(&format.step);

    // Add 'docs' step
    const docs = b.addInstallDirectory(.{
        .source_dir = unit_tests.getEmittedDocs(),
        .install_dir = .{ .prefix = {} },
        .install_subdir = "docs",
    });

    const docs_step = b.step("docs", "Generate documentation");
    docs_step.dependOn(&docs.step);
}
