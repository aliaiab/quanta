const Sampler = @This();

const vk = @import("vk.zig");
const Context = @import("Context.zig");

pub const ReductionMode = enum {
    min,
    max,
    weighted_average,
};

pub const FilterMode = enum {
    linear,
    nearest,
};

pub const AddressMode = enum {
    repeat,
    mirrored_repeat,
    clamp_to_edge,
    clamp_to_border,
    mirror_clamp_to_edge,
};

handle: vk.Sampler,

pub fn init(min_filter: FilterMode, mag_filter: FilterMode, address_mode_u: AddressMode, address_mode_v: AddressMode, address_mode_w: AddressMode, reduction_mode: ?ReductionMode) !Sampler {
    var self = Sampler{
        .handle = .null_handle,
    };

    self.handle = try Context.self.vkd.createSampler(
        Context.self.device,
        &.{
            .p_next = if (reduction_mode != null) &vk.SamplerReductionModeCreateInfo{
                .reduction_mode = switch (reduction_mode.?) {
                    .min => vk.SamplerReductionMode.min,
                    .max => vk.SamplerReductionMode.max,
                    .weighted_average => vk.SamplerReductionMode.weighted_average,
                },
            } else null,
            .flags = .{},
            .mag_filter = switch (min_filter) {
                .linear => vk.Filter.linear,
                .nearest => vk.Filter.nearest,
            },
            .min_filter = switch (mag_filter) {
                .linear => vk.Filter.linear,
                .nearest => vk.Filter.nearest,
            },
            .mipmap_mode = .nearest,
            .address_mode_u = switch (address_mode_u) {
                .repeat => vk.SamplerAddressMode.repeat,
                .mirrored_repeat => vk.SamplerAddressMode.mirrored_repeat,
                .clamp_to_edge => vk.SamplerAddressMode.clamp_to_edge,
                .clamp_to_border => vk.SamplerAddressMode.clamp_to_border,
                .mirror_clamp_to_edge => vk.SamplerAddressMode.mirror_clamp_to_edge,
            },
            .address_mode_v = switch (address_mode_v) {
                .repeat => vk.SamplerAddressMode.repeat,
                .mirrored_repeat => vk.SamplerAddressMode.mirrored_repeat,
                .clamp_to_edge => vk.SamplerAddressMode.clamp_to_edge,
                .clamp_to_border => vk.SamplerAddressMode.clamp_to_border,
                .mirror_clamp_to_edge => vk.SamplerAddressMode.mirror_clamp_to_edge,
            },
            .address_mode_w = switch (address_mode_w) {
                .repeat => vk.SamplerAddressMode.repeat,
                .mirrored_repeat => vk.SamplerAddressMode.mirrored_repeat,
                .clamp_to_edge => vk.SamplerAddressMode.clamp_to_edge,
                .clamp_to_border => vk.SamplerAddressMode.clamp_to_border,
                .mirror_clamp_to_edge => vk.SamplerAddressMode.mirror_clamp_to_edge,
            },
            .mip_lod_bias = 0,
            .anisotropy_enable = vk.FALSE,
            .max_anisotropy = 0,
            .compare_enable = vk.FALSE,
            .compare_op = .always,
            .min_lod = 0,
            .max_lod = 0,
            .border_color = vk.BorderColor.float_opaque_black,
            .unnormalized_coordinates = vk.FALSE,
        },
        &Context.self.allocation_callbacks,
    );

    return self;
}

pub fn deinit(self: *Sampler) void {
    defer self.* = undefined;

    defer Context.self.vkd.destroySampler(Context.self.device, self.handle, &Context.self.allocation_callbacks);
}
