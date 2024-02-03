# Quanta

A data oriented game engine/framework/library for desktop platforms written in
and for Zig.

This is an unfinished, experimental project which satisfies my semi-academic
interest in game engine design. It is not yet fully useable.

### Required System Dependencies:

- Git
- Zig 0.12.0 master

### Optional System Dependencies:

- LunarG vulkan-sdk (for validation layers)

## Build and Run Tests

`zig build test`

## Build the Example

`cd quanta-example`

`zig build run`

If you want to test the asset compiler in isolation (which is run as a
dependency step for the run step by default).

`zig build compile_assets`
