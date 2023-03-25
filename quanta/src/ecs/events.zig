const std = @import("std");

///A source stream of events to be recieved by an event reader
pub fn EventBuffer(comptime T: type) type {
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
        event_writers: std.ArrayListUnmanaged(*EventBuffer(T)),
        event_writer_index: u32,
        event_index: u32,

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
