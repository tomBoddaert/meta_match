# meta_match

`meta_match` is a [zig](https://ziglang.org/) module that can match types for you!
It is designed to assist with meta-programming of things like interfaces.

## Adding meta_match to your project
Run
```sh
zig fetch --save https://github.com/tomBoddaert/meta_match/archive/{commit}.tar.gz
```
Where `{commit}` is replaced with the commit (e.g. `4129996211edd30b25c23454520fd78b2a70394b`).

## Example: go-like interfaces
Interfaces in go are implemented implicitly, this means that any type that has the required
functions and fields.

```zig
/// An interface for deinitialising.
///
/// If the type does not have a `deinit` function, the `deinit` function
/// does nothing.
pub fn Deinit(comptime T: type) type {
    return struct {
        // This matches a compatable 'deinit' function
        const DeinitMatch = TypeMatch{
            .Fn = &FnMatch{
                // Only accept zig and C functions
                .calling_convention = .{ .options = &.{ .Unspecified, .C, .Inline } },
                // Don't accept C variadic functions
                .is_var_args = false,
                // It must return void
                .return_type = TypeMatch{ .Void = {} },
                .params = &.{
                    // It must have a single pointer parameter
                    // Note that the 'constness' of this pointer is not specified,
                    // so functions that take '*const T' will also be accepted.
                    ParamMatch{
                        .type = TypeMatch{
                            .Pointer = &PointerMatch{
                                // The pointer must point to one value
                                .size = .{ .options = &.{Type.Pointer.Size.One} },
                                // It must not be volatile
                                .is_volatile = false,
                                // It must be pointing to a 'T'
                                .child = TypeMatch{ .by_type = T },
                                // It must not have a sentinel
                                // Note that if this was just 'null', meta_match would not
                                // check it.
                                .sentinel = @as(?*const anyopaque, null),
                            },
                        },
                    },
                },
            },
        };

        /// The MetaMatch expression used to determine 'has_deinit'.
        pub const MetaMatch = TypeMatch{
            .container = &ContainerMatch{
                // It must be a container with a 'deinit' declaration matching 'DeinitMatch' above
                .decls = &.{DeclarationMatch{ .name = "deinit", .type = DeinitMatch }},
            },
        };

        /// `true` if `T` has a `deinit` function.
        pub const has_deinit: bool = MetaMatch.match(T);

        /// Deinitialise a value.
        pub inline fn deinit(value: *T) void {
            if (has_deinit) {
                T.deinit(value);
            }
        }
    };
}

test {
    try testing.expect(!Deinit(u8).has_deinit);
    var n: u8 = 5;
    // This will do nothing
    Deinit(u8).deinit(&n);

    const S = struct {
        pub fn deinit(_: *@This()) void {}
    };
    try testing.expect(Deinit(S).has_deinit);
    var s = S{};
    // This will run the deinit function
    Deinit(S).deinit(&s);
}
```

In this example, if 'deinit' is called with a type that does not have a 'deinit' function, nothing happens but
you could add a compile error, or you could run a default function.
If 'deinit' is run with a type that does have a matching 'deinit' function, then the type's 'deinit' function is called.
