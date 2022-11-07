const std = @import("std");
const builtin = @import("builtin");

const Term = struct {
    fn code(comptime c: u8, comptime str: []const u8) []const u8 {
        if (builtin.os.tag == .windows) return str;
        return "\u{001b}[" ++ std.fmt.comptimePrint("{}", .{c}) ++ "m" ++ str ++ "\u{001b}[0m";
    }
    fn green(comptime str: []const u8) []const u8 {
        return code(32, str);
    }
    fn yellow(comptime str: []const u8) []const u8 {
        return code(33, str);
    }
    fn cyan(comptime str: []const u8) []const u8 {
        return code(36, str);
    }
};

fn ext(comptime str: []const u8) []const u8 {
    if (std.mem.indexOf(u8, str, ".")) |i| {
        return str[i + 1 ..];
    }
    return str;
}

fn Log(comptime name: []const u8, comptime Self: type) type {
    const T = @typeInfo(Self);
    return struct {
        pub fn log(self: Self) void {
            switch (T) {
                .Struct => |s| {
                    std.debug.print(
                        Term.green("{s}") ++ " " ++
                            Term.yellow("{{") ++ "\n",
                        .{name},
                    );
                    inline for (s.fields) |f| {
                        std.debug.print(
                            "  " ++ Term.cyan("{s}") ++ ": " ++
                                Term.green("{s}") ++ "\n",
                            .{ f.name, ext(@typeName(f.field_type)) },
                        );
                    }
                    std.debug.print(Term.yellow("}}") ++ "\n", .{});
                },
                else => std.debug.print("{any}\n", .{self}),
            }
        }
    };
}

const SadStruct = struct {
    some: u32,
    stuff: []const u8,
};

const Thing = struct {
    that: SadStruct,
    this: SadStruct,

    pub usingnamespace Log("Thing", @This());
};

test "mixin" {
    var x: Thing = .{
        .that = .{ .some = 4, .stuff = "ziguanas" },
        .this = .{ .some = 0, .stuff = "safety" },
    };

    x.log();
}
