const Swapchain = @This();
const std = @import("std");
const vk = @import("vk.zig");
const Context = @import("Context.zig");
const Semaphore = @import("Semaphore.zig");

pub const PresentState = enum {
    optimal,
    suboptimal,
};

allocator: std.mem.Allocator,
surface: vk.SurfaceKHR,
surface_format: vk.SurfaceFormatKHR,
present_mode: vk.PresentModeKHR,
extent: vk.Extent2D,
handle: vk.SwapchainKHR,
swap_images: []SwapImage,
image_index: u32,
next_image_acquired: Semaphore,

pub fn init(allocator: std.mem.Allocator, surface: vk.SurfaceKHR) !Swapchain {
    return try initRecycle(allocator, surface, .null_handle);
}

pub fn initRecycle(allocator: std.mem.Allocator, surface: vk.SurfaceKHR, old_handle: vk.SwapchainKHR) !Swapchain {
    const caps = try Context.self.vki.getPhysicalDeviceSurfaceCapabilitiesKHR(Context.self.physical_device, surface);
    const actual_extent = caps.current_extent;

    if (actual_extent.width == 0 or actual_extent.height == 0) {
        return error.InvalidSurfaceDimensions;
    }

    const surface_format = try findSurfaceFormat(surface, allocator);
    const present_mode = try findPresentMode(surface, allocator);

    var image_count = caps.min_image_count + 1;
    if (caps.max_image_count > 0) {
        image_count = @min(image_count, caps.max_image_count);
    }

    const qfi = [_]u32{ Context.self.graphics_family_index.?, Context.self.present_family_index.? };
    const sharing_mode: vk.SharingMode = if (Context.self.graphics_family_index.? != Context.self.present_family_index.?)
        .concurrent
    else
        .exclusive;

    std.log.info("swapchain image sharing mode: {}", .{sharing_mode});

    const handle = try Context.self.vkd.createSwapchainKHR(Context.self.device, &.{
        .flags = .{},
        .surface = surface,
        .min_image_count = image_count,
        .image_format = surface_format.format,
        .image_color_space = surface_format.color_space,
        .image_extent = actual_extent,
        .image_array_layers = 1,
        .image_usage = .{ .color_attachment_bit = true, .transfer_dst_bit = true, .storage_bit = true },
        .image_sharing_mode = sharing_mode,
        .queue_family_index_count = qfi.len,
        .p_queue_family_indices = &qfi,
        .pre_transform = caps.current_transform,
        .composite_alpha = .{ .opaque_bit_khr = true },
        .present_mode = present_mode,
        .clipped = vk.TRUE,
        .old_swapchain = old_handle,
    }, null);
    errdefer Context.self.vkd.destroySwapchainKHR(Context.self.device, handle, null);

    if (old_handle != .null_handle) {
        // Apparently, the old swapchain handle still needs to be destroyed after recreating.
        Context.self.vkd.destroySwapchainKHR(Context.self.device, old_handle, null);
    }

    const swap_images = try initSwapchainImages(handle, surface_format.format, allocator);
    errdefer for (swap_images) |*si| si.deinit();

    var next_image_acquired = try Semaphore.initBinary();
    errdefer next_image_acquired.deinit();

    const result = try Context.self.vkd.acquireNextImage2KHR(Context.self.device, &vk.AcquireNextImageInfoKHR{
        .swapchain = handle,
        .semaphore = next_image_acquired.handle,
        .timeout = std.math.maxInt(u64),
        .fence = .null_handle,
        .device_mask = 1,
    });

    if (result.result != .success) {
        return error.ImageAcquireFailed;
    }

    std.mem.swap(Semaphore, &swap_images[result.image_index].image_acquired, &next_image_acquired);

    return Swapchain{
        .allocator = allocator,
        .surface = surface,
        .surface_format = surface_format,
        .present_mode = present_mode,
        .extent = actual_extent,
        .handle = handle,
        .swap_images = swap_images,
        .image_index = result.image_index,
        .next_image_acquired = next_image_acquired,
    };
}

fn deinitExceptSwapchain(self: *Swapchain) void {
    for (self.swap_images) |*image| {
        image.deinit();
    }
    self.allocator.free(self.swap_images);
    self.next_image_acquired.deinit();
}

pub fn waitForAllFences(self: Swapchain) !void {
    for (self.swap_images) |si| si.waitForFence(self.context) catch {};
}

pub fn deinit(self: *Swapchain) void {
    self.deinitExceptSwapchain();
    Context.self.vkd.destroySwapchainKHR(Context.self.device, self.handle, null);
}

pub fn recreate(self: *Swapchain) !void {
    const allocator = self.allocator;
    const old_handle = self.handle;
    self.deinitExceptSwapchain();
    self.* = try initRecycle(allocator, self.surface, old_handle);
}

pub fn currentImage(self: Swapchain) vk.Image {
    return self.swap_images[self.image_index].image;
}

pub fn currentSwapImage(self: Swapchain) *const SwapImage {
    return &self.swap_images[self.image_index];
}

pub fn present(self: *Swapchain) !void {
    const image_index = self.image_index;
    const image = self.swap_images[image_index];

    const surface_capabilities = try Context.self.vki.getPhysicalDeviceSurfaceCapabilitiesKHR(Context.self.physical_device, self.surface);

    if (self.extent.width != surface_capabilities.current_extent.width or self.extent.height != surface_capabilities.current_extent.height) {
        std.log.err("Lol the surface and swapchain don't agree!!!: surface current extent: {}", .{surface_capabilities.current_extent});

        try Context.self.vkd.queueWaitIdle(Context.self.graphics_queue);

        try self.recreate();

        return;
    }

    _ = Context.self.vkd.queuePresentKHR(Context.self.graphics_queue, &.{
        .wait_semaphore_count = 1,
        .p_wait_semaphores = @as([*]const vk.Semaphore, @ptrCast(&image.render_finished)),
        .swapchain_count = 1,
        .p_swapchains = @as([*]const vk.SwapchainKHR, @ptrCast(&self.handle)),
        .p_image_indices = @as([*]const u32, @ptrCast(&image_index)),
        .p_results = null,
    }) catch |e| {
        switch (e) {
            error.OutOfDateKHR => {
                try Context.self.vkd.queueWaitIdle(Context.self.graphics_queue);

                try self.recreate();
            },
            else => return e,
        }
    };
}

pub fn swap(self: *Swapchain) !void {
    const result = try Context.self.vkd.acquireNextImage2KHR(Context.self.device, &vk.AcquireNextImageInfoKHR{
        .swapchain = self.handle,
        .semaphore = self.next_image_acquired.handle,
        .timeout = std.math.maxInt(u64),
        .fence = .null_handle,
        .device_mask = 1,
    });

    std.mem.swap(Semaphore, &self.swap_images[result.image_index].image_acquired, &self.next_image_acquired);
    self.image_index = result.image_index;
}

pub const SwapImage = struct {
    image: vk.Image,
    view: vk.ImageView,
    image_acquired: Semaphore,
    render_finished: Semaphore,
    frame_fence: vk.Fence,

    fn init(image: vk.Image, format: vk.Format) !SwapImage {
        const view = try Context.self.vkd.createImageView(Context.self.device, &.{
            .flags = .{},
            .image = image,
            .view_type = .@"2d",
            .format = format,
            .components = .{ .r = .identity, .g = .identity, .b = .identity, .a = .identity },
            .subresource_range = .{
                .aspect_mask = .{ .color_bit = true },
                .base_mip_level = 0,
                .level_count = 1,
                .base_array_layer = 0,
                .layer_count = 1,
            },
        }, null);
        errdefer Context.self.vkd.destroyImageView(Context.self.device, view, null);

        const frame_fence = try Context.self.vkd.createFence(Context.self.device, &.{ .flags = .{ .signaled_bit = true } }, null);
        errdefer Context.self.vkd.destroyFence(Context.self.device, frame_fence, null);

        return SwapImage{
            .image = image,
            .view = view,
            .image_acquired = try Semaphore.initBinary(),
            .render_finished = try Semaphore.initBinary(),
            .frame_fence = frame_fence,
        };
    }

    fn deinit(self: *SwapImage) void {
        self.waitForFence() catch return;

        Context.self.vkd.destroyImageView(Context.self.device, self.view, null);

        self.image_acquired.deinit();
        self.render_finished.deinit();
        Context.self.vkd.destroyFence(Context.self.device, self.frame_fence, null);
    }

    pub fn waitForFence(self: SwapImage) !void {
        _ = try Context.self.vkd.waitForFences(Context.self.device, 1, @as([*]const vk.Fence, @ptrCast(&self.frame_fence)), vk.TRUE, std.math.maxInt(u64));
    }
};

fn initSwapchainImages(swapchain: vk.SwapchainKHR, format: vk.Format, allocator: std.mem.Allocator) ![]SwapImage {
    var count: u32 = undefined;
    _ = try Context.self.vkd.getSwapchainImagesKHR(Context.self.device, swapchain, &count, null);
    const images = try allocator.alloc(vk.Image, count);
    defer allocator.free(images);
    _ = try Context.self.vkd.getSwapchainImagesKHR(Context.self.device, swapchain, &count, images.ptr);

    const swap_images = try allocator.alloc(SwapImage, count);
    errdefer allocator.free(swap_images);

    var i: usize = 0;
    errdefer for (swap_images[0..i]) |*si| si.deinit();

    for (images) |image| {
        swap_images[i] = try SwapImage.init(image, format);
        i += 1;
    }

    return swap_images;
}

fn findSurfaceFormat(surface: vk.SurfaceKHR, allocator: std.mem.Allocator) !vk.SurfaceFormatKHR {
    const preferred = vk.SurfaceFormatKHR{
        //might be preferred, idk, this might fuck things up
        // .format = .b8g8r8a8_srgb,
        .format = vk.Format.r8g8b8a8_unorm,
        .color_space = .srgb_nonlinear_khr,
    };

    var count: u32 = undefined;
    _ = try Context.self.vki.getPhysicalDeviceSurfaceFormatsKHR(Context.self.physical_device, surface, &count, null);
    const surface_formats = try allocator.alloc(vk.SurfaceFormatKHR, count);
    defer allocator.free(surface_formats);
    _ = try Context.self.vki.getPhysicalDeviceSurfaceFormatsKHR(Context.self.physical_device, surface, &count, surface_formats.ptr);

    for (surface_formats) |sfmt| {
        if (std.meta.eql(sfmt, preferred)) {
            return preferred;
        }
    }

    return surface_formats[0]; // There must always be at least one supported surface format
}

fn findPresentMode(surface: vk.SurfaceKHR, allocator: std.mem.Allocator) !vk.PresentModeKHR {
    var count: u32 = undefined;
    _ = try Context.self.vki.getPhysicalDeviceSurfacePresentModesKHR(Context.self.physical_device, surface, &count, null);
    const present_modes = try allocator.alloc(vk.PresentModeKHR, count);
    defer allocator.free(present_modes);
    _ = try Context.self.vki.getPhysicalDeviceSurfacePresentModesKHR(Context.self.physical_device, surface, &count, present_modes.ptr);

    const preferred = [_]vk.PresentModeKHR{
        .mailbox_khr,
        .immediate_khr,
    };

    for (preferred) |mode| {
        if (std.mem.indexOfScalar(vk.PresentModeKHR, present_modes, mode) != null) {
            return mode;
        }
    }

    return .fifo_khr;
}
