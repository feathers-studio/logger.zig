const std = @import("std");
const builtin = @import("builtin");
const print = std.debug.print;

// TODO: Move this to own file?
pub const Term = struct {
    pub fn start(comptime c: u8) []const u8 {
        return "\u{001b}[" ++ std.fmt.comptimePrint("{}", .{c}) ++ "m";
    }
    pub const end = "\u{001b}[0m";
    pub fn code(comptime c: u8, comptime str: []const u8) []const u8 {
        if (builtin.os.tag == .windows) return str;
        return start(c) ++ str ++ end;
    }
    // TODO: Add all colors
    pub fn green(comptime str: []const u8) []const u8 {
        return code(32, str);
    }
    pub fn yellow(comptime str: []const u8) []const u8 {
        return code(33, str);
    }
    pub fn purple(comptime str: []const u8) []const u8 {
        return code(35, str);
    }
    pub fn cyan(comptime str: []const u8) []const u8 {
        return code(36, str);
    }
};

pub fn ext(comptime str: []const u8) []const u8 {
    if (std.mem.indexOf(u8, str, ".")) |i| {
        return str[i + 1 ..];
    }
    return str;
}

pub fn logAny(x: anytype, comptime indent: usize, comptime depth: usize) void {
    const T = @TypeOf(x);
    const info = @typeInfo(T);
    if (depth == 0) {
        print("...", .{});
        return;
    }
    switch (info) {
        .Struct => |s| {
            print(Term.green("{s}"), .{ext(@typeName(T))});
            print("{{\n", .{});
            inline for (s.fields) |f| {
                print(("  " ** indent) ++ "." ++ Term.cyan("{s}") ++ " = ", .{f.name});
                logAny(@field(x, f.name), indent + 1, depth - 1);
                print(",\n", .{});
            }
            print(("  " ** (indent - 1)) ++ "}}", .{});
        },
        .Int => {
            print(Term.purple("@as") ++ "(", .{});
            print(Term.green("{s}"), .{@typeName(T)});
            print(", ", .{});
            print(Term.start(33), .{});
            print("{}", .{x});
            print(Term.end, .{});
            print(")", .{});
        },
        .Pointer => switch (T) {
            []const u8 => {
                print(Term.start(32), .{});
                print("\"{s}\"", .{x});
                print(Term.end, .{});
            },
            else => logAny(x.*, indent, depth),
        },
        .Optional => {
            if (x) |val|
                logAny(val, indent, depth)
            else
                print("null", .{});
        },
        // TODO: Add support for more types
        // (comment the next line to see missing constituents in compile error)
        else => print("{any}", .{x}),
    }
}

pub const LoggerOptions = struct {
    depth: u16 = 10,
};

pub fn Logger(comptime options: LoggerOptions) type {
    return struct {
        pub fn log(x: anytype) void {
            logAny(x, 1, options.depth);
            print("\n", .{});
        }
    };
}

pub const logger = Logger(.{});

pub const log = logger.log;
