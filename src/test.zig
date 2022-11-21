// zig run src/test.zig

const log = @import("main.zig").log;
const Logger = @import("main.zig").Logger;

const Left = struct {
    right: ?*Right = null,
};

const Right = struct {
    left: ?*Left = null,
};

const User = struct {
    id: u64,
    name: []const u8,
    age: u16,
};

const SadStruct = struct {
    some: u32,
    stuff: []const u8,
};

const Thing = struct {
    that: SadStruct,
    this: SadStruct,

    pub usingnamespace Logger(.{});
};

pub fn main() void {
    var left = Left{};
    var right = Right{};
    left.right = &right;
    right.left = &left;

    log(left);
    log(right);

    const thomas = User{
        .id = 42,
        .name = "Thomas",
        .age = 27,
    };
    log(thomas);

    var x: Thing = .{
        .that = .{ .some = 4, .stuff = "ziguanas" },
        .this = .{ .some = 0, .stuff = "safety" },
    };
    x.log();
}
