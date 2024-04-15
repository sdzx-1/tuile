const std = @import("std");
const Widget = @import("Widget.zig");
const Vec2 = @import("../Vec2.zig");
const events = @import("../events.zig");
const Painter = @import("../Painter.zig");
const Style = @import("../Style.zig");

const Config = struct {
    style: Style = .{},
};

pub fn StyledWidget(comptime config: Config, comptime inner: anytype) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,

        inner: Widget,

        style: Style,

        size: ?Vec2 = null,

        pub fn create(allocator: std.mem.Allocator) !*Self {
            const inner_w = try inner.create(allocator);

            const self = try allocator.create(Self);
            self.* = Self{
                .allocator = allocator,
                .inner = inner_w.widget(),
                .style = config.style,
            };
            return self;
        }

        pub fn destroy(self: *Self) void {
            self.inner.destroy();
            self.allocator.destroy(self);
        }

        pub fn widget(self: *Self) Widget {
            return Widget.init(self);
        }

        pub fn draw(self: *Self, painter: *Painter) !void {
            const min = painter.cursor;
            const max = min.add(self.size.?).sub(.{ .x = 1, .y = 1 });

            painter.offset(.{ .x = 1, .y = 1 });
            try self.inner.draw(painter);

            try draw_border(painter, min, max);

            painter.move_to(max);
        }

        pub fn desired_size(self: *Self, available: Vec2) !Vec2 {
            const inner_size = try self.inner.desired_size(available);
            return inner_size.add(.{ .x = 2, .y = 2 });
        }

        pub fn layout(self: *Self, bounds: Vec2) !void {
            self.size = bounds;
            const inner_bounds = .{
                .x = @max(2, bounds.x) - 2,
                .y = @max(2, bounds.y) - 2,
            };
            try self.inner.layout(inner_bounds);
        }

        pub fn handle_event(self: *Self, event: events.Event) !events.EventResult {
            return self.inner.handle_event(event);
        }

        pub fn focus(self: *Self) !events.EventResult {
            return self.inner.focus();
        }

        fn draw_border(painter: *Painter, min: Vec2, max: Vec2) !void {
            var x = min.x + 1;
            while (x <= max.x - 1) : (x += 1) {
                try painter.print_at(.{ .x = x, .y = min.y }, "-");
                try painter.print_at(.{ .x = x, .y = max.y }, "-");
            }

            var y = min.y + 1;
            while (y <= max.y - 1) : (y += 1) {
                try painter.print_at(.{ .x = min.x, .y = y }, "|");
                try painter.print_at(.{ .x = max.x, .y = y }, "|");
            }

            try painter.print_at(.{ .x = min.x, .y = min.y }, "+");
            try painter.print_at(.{ .x = min.x, .y = max.y }, "+");
            try painter.print_at(.{ .x = max.x, .y = min.y }, "+");
            try painter.print_at(.{ .x = max.x, .y = max.y }, "+");
        }
    };
}
