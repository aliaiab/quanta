allocator: std.mem.Allocator,
surface: vk.SurfaceKHR,
surface_format: vk.SurfaceFormatKHR,
present_mode: vk.PresentModeKHR,
extent: vk.Extent2D,
handle: vk.SwapchainKHR,
swap_images: []SwapImage,
swap_image_handles: []vk.Image,
swap_image_views: []vk.ImageView,
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

    var image_count = @max(caps.min_image_count, 3);

    if (caps.max_image_count > 0) {
        image_count = @min(image_count, caps.max_image_count);
    }

    const qfi = [_]u32{ Context.self.graphics_family_index.?, Context.self.present_family_index.? };
    const sharing_mode: vk.SharingMode = if (Context.self.graphics_family_index.? != Context.self.present_family_index.?)
        .concurrent
    else
        .exclusive;

    var present_modes_info = vk.SwapchainPresentModesCreateInfoEXT{
        .present_mode_count = 1,
        .p_present_modes = &.{vk.PresentModeKHR.mailbox_khr},
    };

    var present_scaling_info = vk.SwapchainPresentScalingCreateInfoEXT{
        .p_next = &present_modes_info,
        .scaling_behavior = .{
            .stretch_bit_ext = true,
        },
        .present_gravity_x = .{ .centered_bit_ext = true },
        .present_gravity_y = .{ .centered_bit_ext = true },
    };

    const handle = try Context.self.vkd.createSwapchainKHR(Context.self.device, &.{
        .p_next = &present_scaling_info,
        .flags = .{
            //TODO: look into why this doesn't work. Currently returns a timeout on acquire image and I have no idea why
            .deferred_memory_allocation_bit_ext = false,
        },
        .surface = surface,
        .min_image_count = image_count,
        .image_format = surface_format.format,
        .image_color_space = surface_format.color_space,
        .image_extent = .{
            //I'm not even sure how this is even possible but x11 certainly found a way to do this, so thanks for that X.
            .width = std.math.clamp(actual_extent.width, caps.min_image_extent.width, caps.max_image_extent.width),
            .height = std.math.clamp(actual_extent.height, caps.min_image_extent.height, caps.max_image_extent.height),
        },
        .image_array_layers = 1,
        .image_usage = .{ .color_attachment_bit = true, .transfer_dst_bit = true, .storage_bit = true },
        .image_sharing_mode = sharing_mode,
        .queue_family_index_count = qfi.len,
        .p_queue_family_indices = &qfi,
        .pre_transform = caps.current_transform,
        .composite_alpha = .{ .inherit_bit_khr = true },
        .present_mode = present_mode,
        .clipped = vk.TRUE,
        .old_swapchain = old_handle,
    }, null);
    errdefer Context.self.vkd.destroySwapchainKHR(Context.self.device, handle, null);

    if (old_handle != .null_handle) {
        //TODO: defer this so that the old swapchain can be used by the current rendering frame
        Context.self.vkd.destroySwapchainKHR(Context.self.device, old_handle, null);
    }

    var queryed_image_count: u32 = undefined;

    _ = try Context.self.vkd.getSwapchainImagesKHR(Context.self.device, handle, &queryed_image_count, null);

    //Why are we fucking allocating using a gpa here?
    const images = try allocator.alloc(vk.Image, queryed_image_count);
    errdefer allocator.free(images);

    _ = try Context.self.vkd.getSwapchainImagesKHR(Context.self.device, handle, &queryed_image_count, images.ptr);

    const image_views = try allocator.alloc(vk.ImageView, queryed_image_count);
    errdefer allocator.free(image_views);

    @memset(image_views, .null_handle);

    const swap_images = try initSwapchainImages(allocator, images);
    errdefer for (swap_images) |*si| si.deinit();

    var next_image_acquired = try Semaphore.initBinary();
    errdefer next_image_acquired.deinit();

    return Swapchain{
        .allocator = allocator,
        .surface = surface,
        .surface_format = surface_format,
        .present_mode = present_mode,
        .extent = actual_extent,
        .handle = handle,
        .swap_images = swap_images,
        .swap_image_handles = images,
        .swap_image_views = image_views,
        .image_index = 0,
        .next_image_acquired = next_image_acquired,
    };
}

fn deinitExceptSwapchain(self: *Swapchain) void {
    for (self.swap_images) |*image| {
        image.deinit();
    }

    for (self.swap_image_views) |image_view| {
        if (image_view == .null_handle) continue;

        Context.self.vkd.destroyImageView(Context.self.device, image_view, null);
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

///Obtain the next image for presentation
pub fn obtainNextImage(self: *Swapchain) !Image {
    const result = Context.self.vkd.acquireNextImage2KHR(Context.self.device, &vk.AcquireNextImageInfoKHR{
        .swapchain = self.handle,
        .semaphore = self.next_image_acquired.handle,
        .timeout = std.math.maxInt(u64),
        .fence = .null_handle,
        .device_mask = 1,
    }) catch |e| {
        switch (e) {
            error.OutOfDateKHR => {
                try Context.self.vkd.queueWaitIdle(Context.self.graphics_queue);

                try self.recreate();

                return try self.obtainNextImage();
            },
            else => {
                return e;
            },
        }
    };

    if (result.image_index >= self.swap_images.len) {
        std.log.info("res.image_index = 0x{x}", .{result.image_index});
        std.log.info("res.result = {}", .{result.result});
    }

    std.debug.assert(result.image_index < self.swap_images.len);

    std.mem.swap(Semaphore, &self.swap_images[result.image_index].image_acquired, &self.next_image_acquired);
    self.image_index = result.image_index;

    if (self.swap_image_views[self.image_index] == .null_handle) {
        const view = try Context.self.vkd.createImageView(Context.self.device, &.{
            .flags = .{},
            .image = self.swap_image_handles[self.image_index],
            .view_type = .@"2d",
            .format = self.surface_format.format,
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

        self.swap_image_views[self.image_index] = view;
    }

    const color_image: Image = .{
        .handle = self.swap_image_handles[self.image_index],
        .type = .@"2d",
        .view = self.swap_image_views[self.image_index],
        .memory_page = undefined,
        .size = undefined,
        .alignment = undefined,
        .format = self.surface_format.format,
        .layout = .color_attachment_optimal,
        .aspect_mask = .{ .color_bit = true },
        .width = self.extent.width,
        .height = self.extent.height,
        .depth = 1,
        .levels = 1,
    };

    //TODO: just set this in init swapchain
    color_image.debugSetName("Swapchain Image");

    return color_image;
}

pub fn present(self: *Swapchain) !void {
    const image_index = self.image_index;
    const image = self.swap_images[image_index];

    const surface_capabilities = try Context.self.vki.getPhysicalDeviceSurfaceCapabilitiesKHR(Context.self.physical_device, self.surface);

    if (self.extent.width != surface_capabilities.current_extent.width or self.extent.height != surface_capabilities.current_extent.height) {
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
            else => {
                return e;
            },
        }
    };
}

pub const SwapImage = struct {
    image_acquired: Semaphore,
    render_finished: Semaphore,
    frame_fence: vk.Fence,

    fn init() !SwapImage {
        const frame_fence = try Context.self.vkd.createFence(Context.self.device, &.{ .flags = .{ .signaled_bit = true } }, null);
        errdefer Context.self.vkd.destroyFence(Context.self.device, frame_fence, null);

        return SwapImage{
            .image_acquired = try Semaphore.initBinary(),
            .render_finished = try Semaphore.initBinary(),
            .frame_fence = frame_fence,
        };
    }

    fn deinit(self: *SwapImage) void {
        self.waitForFence() catch return;

        self.image_acquired.deinit();
        self.render_finished.deinit();
        Context.self.vkd.destroyFence(Context.self.device, self.frame_fence, null);

        self.frame_fence = .null_handle;
    }

    pub fn waitForFence(self: SwapImage) !void {
        if (self.frame_fence == .null_handle) return;

        _ = try Context.self.vkd.waitForFences(
            Context.self.device,
            1,
            @as([*]const vk.Fence, @ptrCast(&self.frame_fence)),
            vk.TRUE,
            std.math.maxInt(u64),
        );
    }
};

fn initSwapchainImages(
    allocator: std.mem.Allocator,
    images: []vk.Image,
) ![]SwapImage {
    const swap_images = try allocator.alloc(SwapImage, images.len);
    errdefer allocator.free(swap_images);

    errdefer for (swap_images) |*si| si.deinit();

    for (swap_images) |*swap_image| {
        swap_image.* = try SwapImage.init();
    }

    return swap_images;
}

fn findSurfaceFormat(surface: vk.SurfaceKHR, allocator: std.mem.Allocator) !vk.SurfaceFormatKHR {
    const preferred = vk.SurfaceFormatKHR{
        //might be preferred, idk, this might fuck things up
        .format = .b8g8r8a8_unorm,
        // .format = vk.Format.r8g8b8a8_unorm,
        .color_space = .srgb_nonlinear_khr,
    };

    var count: u32 = undefined;
    _ = try Context.self.vki.getPhysicalDeviceSurfaceFormatsKHR(Context.self.physical_device, surface, &count, null);
    const surface_formats = try allocator.alloc(vk.SurfaceFormatKHR, count);
    defer allocator.free(surface_formats);
    _ = try Context.self.vki.getPhysicalDeviceSurfaceFormatsKHR(Context.self.physical_device, surface, &count, surface_formats.ptr);

    for (surface_formats) |sfmt| {
        std.log.info("Avaiable surface format: {}", .{sfmt});

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

pub const PresentState = enum {
    optimal,
    suboptimal,
};

const Swapchain = @This();
const std = @import("std");
const vk = @import("vulkan");
const Image = @import("Image.zig");
const Context = @import("Context.zig");
const Semaphore = @import("Semaphore.zig");
