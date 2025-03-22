# Quanta

A data oriented game engine/framework/library for desktop platforms written using (almost) pure zig.

Design Goals/Rules:
- Intentionally for desktop platforms only, no web, mobile or console. This keeps the design tight and focused,
improving the the entire engine from top to bottom.
- As pure zig as possible, within reason. No C++.
- Source based. What do I mean? The entire engine (and future editor) is compiled from source, no binary releases at all. No system depedencies.
This keeps every project locally reproducable and ensures keeping up with latest stays easy. This goal isn't unique to this project, 
but a side effect of the great zig build system and package manager.
- The source tree isn't changed by the engine or editor. The engine and editor should never mutate the source tree behind the back of the user. Assets are compiled from source to the output format as part of the build system, and we never use the words import/export to describe this process. Asset compilation can be 
non-trivial, potentially involving optimization and compression, and produces an output format that is target specific and optimized for runtime loading. Assets will never be compiled at runtime unless the compiler is brought in directly (for use cases such as modding).
- When the editor is implemented, it will be entirely optional. It will not be responsible for compiling assets or packaging, as that is part of the core kernel of the engine. Building an application should always be possible with one command: zig build ...    

This is an unfinished, experimental project which satisfies my semi-academic
interest in game engine design. It is not yet fully useable.

### Required System Dependencies:

- Zig 0.15.0 master

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
