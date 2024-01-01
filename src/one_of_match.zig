/// Match one of a set of options.
///
/// This matches with `==`, so it cannot be used with other 'Match' types.
pub fn OneOfMatch(comptime T: type) type {
    return union(enum) {
        options: []const T,
        any: void,

        const Self = @This();

        pub fn match(comptime self: Self, actual: T) bool {
            return switch (self) {
                .options => {
                    inline for (self.options) |option| {
                        if (actual == option) return true;
                    }
                    return false;
                },
                .any => return true,
            };
        }
    };
}
