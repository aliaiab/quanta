//! Input state captures for debugging and playback

pub const Context = struct {
    ///Time at the start of the capture
    time_start: i64,

    first_time_stamp: i64 = 0,

    header_index: usize = 0,

    read_data: []u8 = &.{},
};

pub const StateHeader = extern struct {
    ///Timestamp relative to the start time of the capture
    ///Measured in real system time
    timestamp: i64,
};

///Writes a single state to the capture stream
pub fn writeStateToCapture(
    ctx: Context,
    gpa: std.mem.Allocator,
    capture_file: std.fs.File,
    state: State,
) !void {
    const time_stamp: i64 = std.time.microTimestamp() - ctx.time_start;

    _ = gpa; // autofix

    const state_bytes = std.mem.asBytes(&state);

    _ = try capture_file.write(std.mem.asBytes(&time_stamp));
    _ = try capture_file.write(state_bytes);
}

pub fn readStateFromCapture(
    ctx: *Context,
    gpa: std.mem.Allocator,
    capture_file: std.fs.File,
    state_out: *State,
) !bool {
    _ = gpa; // autofix

    if (try capture_file.getEndPos() == try capture_file.getPos()) {
        return false;
    }

    var header: StateHeader = undefined;

    _ = try capture_file.read(std.mem.asBytes(&header));

    defer ctx.header_index += 1;

    if (ctx.header_index == 0) {
        ctx.first_time_stamp = header.timestamp;
    }

    const current_time_stamp = std.time.microTimestamp() - ctx.time_start;
    _ = current_time_stamp; // autofix

    if (true) {
        _ = try capture_file.read(std.mem.asBytes(state_out));

        return true;
    } else {
        try capture_file.seekBy(-@sizeOf(StateHeader));
    }

    return false;
}

const State = @import("State.zig");
const std = @import("std");
