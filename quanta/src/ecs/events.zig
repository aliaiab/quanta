const std = @import("std");

pub fn ExampleEvent(comptime T: type) type {
    return struct {
        value: T,
    };
}

///Event triggered when a two colliders first intersect
const CollisionEvent = struct {
    entity_a: u64,
    entity_b: u64,
    normal: @Vector(3, f32),
};

fn eventSender(events: EventWriter(CollisionEvent)) void {
    events.send(.{ .entity_a = 0, .entity_b = 0, .normal = @splat(3, @as(f32, 1)) });
    events.send(undefined);
}

fn eventHandler(events: *EventReader(CollisionEvent)) void {
    while (events.recieve()) |event| {
        _ = event;
    }
}

///A source stream of events to be recieved by an event reader
pub fn EventWriter(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        events: std.SegmentedList(T, 4),

        pub fn send(self: @This(), event: T) void {
            self.events.append(self.allocator, event) catch unreachable;
        }
    };
}

///A queue of event writers that allows events to be recieved
pub fn EventReader(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        event_writers: std.ArrayListUnmanaged(*const EventWriter(T)),
        event_writer_index: u32,
        event_index: u32,

        pub fn reset(self: *@This()) void {
            self.event_writer_index = 0;
            self.event_index = 0;
        }

        pub fn recieve(self: *@This()) ?T {
            if (self.event_writer_index >= self.event_writers.items.len) {
                return null;
            }

            var event_writer = &self.event_writers.items[self.event_writer_index];

            if (self.event_index >= event_writer.events.len) {
                self.event_writer_index += 1;

                event_writer = &self.event_writers.items[self.event_writer_index];
            }

            defer self.event_index += 1;

            return event_writer.events.at(self.event_index);
        }
    };
}
