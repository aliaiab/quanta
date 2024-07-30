//! Provides the main function. An analog to std.start.

///The main entrypoint for quanta.init
///This can be placed in a std.start main function and it will work
///Or if you want quanta.init to have full control over the entrypoint,
///Do: pub const main = quanta.boostrap.entrypoint;
pub fn entrypoint() !void {
    var gpa_instance = std.heap.GeneralPurposeAllocator(.{
        .stack_trace_frames = 10,
    }){};
    defer std.debug.assert(gpa_instance.deinit() != .leak);

    var arena_instance = std.heap.ArenaAllocator.init(gpa_instance.allocator());
    defer arena_instance.deinit();

    const init_options = init.InitOptions{
        .gpa = gpa_instance.allocator(),
        .arena = arena_instance.allocator(),
    };

    var init_payload: if (std.meta.hasFn(root, "init")) blk: {
        const initFn = @field(root, "init");

        const init_fn_info = @typeInfo(@TypeOf(initFn));

        const ReturnType: type = init_fn_info.Fn.return_type orelse {
            @compileError("return_type must not be null!");
        };

        const return_type_info = @typeInfo(ReturnType);

        break :blk return_type_info.ErrorUnion.payload;
    } else void = undefined;

    if (std.meta.hasFn(root, "init")) {
        const initFn = @field(root, "init");

        const init_fn_info = @typeInfo(@TypeOf(initFn));

        const ReturnType: type = init_fn_info.Fn.return_type orelse comptime {
            @compileError("return_type must not be null!");
        };

        const return_type_info = @typeInfo(ReturnType);

        switch (return_type_info) {
            .ErrorUnion => |error_union_info| {
                const PayloadType = error_union_info.payload;
                _ = PayloadType; // autofix

                init_payload = try initFn(init_options);
            },
            else => {
                _ = initFn(init_options);
            },
        }
    }

    defer {
        if (std.meta.hasFn(root, "deinit")) {
            const deinitFn = @field(root, "deinit");

            const deinit_args = std.meta.ArgsTuple(@TypeOf(deinitFn));

            if (std.meta.fields(deinit_args).len > 1) {
                _ = deinitFn(init_options, init_payload);
            } else {
                _ = deinitFn(init_options);
            }
        }
    }

    while (!finalize_threads.load(.monotonic)) {}
}

///Specifies when threads created by quanta.init should be finalized
pub var finalize_threads = std.atomic.Value(bool).init(false);

const std = @import("std");
const root = @import("root");
const init = @import("../init.zig");
