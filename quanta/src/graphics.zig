pub const Context = @import("graphics/Context.zig");
pub const Swapchain = @import("graphics/Swapchain.zig");
pub const CommandBuffer = @import("graphics/CommandBuffer.zig");
pub const GraphicsPipeline = @import("graphics/GraphicsPipeline.zig");
pub const ComputePipeline = @import("graphics/ComputePipeline.zig");
pub const Buffer = @import("graphics/Buffer.zig");
pub const Image = @import("graphics/Image.zig");
pub const Sampler = @import("graphics/Sampler.zig");
pub const Fence = @import("graphics/Fence.zig");
pub const Event = @import("graphics/Event.zig");
pub const Semaphore = @import("graphics/Semaphore.zig");

///Module level options
pub const Options = struct {
    ///Enables internal debug logging of various gpu related events such
    ///as allocations.
    debug_logging: bool = false,
    ///Api validation, turn off at your own risk
    ///Disabled by default in ReleaseFast
    api_validation: bool = @import("builtin").mode != .ReleaseFast and @import("builtin").mode != .ReleaseSafe,
    ///If true, the underlying graphics API will use the zig allocators passed in to Context.init
    ///This allows for use of debug allocators like std.heap.GeneralPurposeAllocator
    ///Disabled by default in ReleaseFast
    use_custom_allocator: bool = @import("builtin").mode != .ReleaseFast,
};

test {
    _ = @import("std").testing.refAllDecls(@This());
}

///TODO: remove this
pub const vulkan = @import("vulkan");
