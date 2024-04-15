const std = @import("std");
const Vec2 = @import("Vec2.zig");
const Backend = @import("backends/Backend.zig");

const Painter = @This();

cursor: Vec2,

backend: *Backend,

screen_size: Vec2,

pub fn init(backend: *Backend) !Painter {
    return .{
        .cursor = Vec2.zero(),
        .backend = backend,
        .screen_size = try backend.window_size(),
    };
}

pub fn print(self: *Painter, text: []const u8) !void {
    if (self.cursor.x < 0 or self.cursor.x >= self.screen_size.x or
        self.cursor.y < 0 or self.cursor.y >= self.screen_size.y)
    {
        return;
    }
    try self.backend.print_at(self.cursor, text);
    self.cursor.addEq(.{ .x = @intCast(text.len), .y = 0 });
}

pub fn print_at(self: *Painter, pos: Vec2, text: []const u8) !void {
    self.move_to(pos);
    try self.print(text);
}

pub fn offset(self: *Painter, value: Vec2) void {
    self.cursor.addEq(value);
}

pub fn move_to(self: *Painter, pos: Vec2) void {
    self.cursor = pos;
}
