const std = @import("std");
const vk = @import("vulkan");
const spirv = @import("spirv.zig");

fn getDescriptorType(spirv_op: spirv.SpvOp) ?vk.DescriptorType {
    return switch (spirv_op) {
        spirv.SpvOpTypeStruct => .storage_buffer,
        spirv.SpvOpTypeImage => .storage_image,
        spirv.SpvOpTypeSampler => .sampler,
        spirv.SpvOpTypeSampledImage => .combined_image_sampler,
        else => null,
    };
}

pub const ShaderParseResult = struct {
    resources: [32]Resource = std.mem.zeroes([32]Resource),
    resource_count: u32 = 0,
    resource_mask: u32 = 0,
    local_size_x: u32 = 0,
    local_size_y: u32 = 0,
    local_size_z: u32 = 0,
    entry_point: [:0]const u8,

    const Resource = struct {
        descriptor_type: vk.DescriptorType,
        descriptor_count: u32,
        binding: u32,
    };
};

pub fn parseShaderModule(result: *ShaderParseResult, allocator: std.mem.Allocator, shader_module_code: []const u32) !void {
    std.debug.assert(shader_module_code[0] == spirv.SpvMagicNumber);

    const id_count = shader_module_code[3];

    const Id = struct {
        opcode: u32,
        type_id: u32,
        storage_class: u32,
        binding: u32,
        set: u32,
        constant: u32,
        array_length: u32,
    };

    var ids = try allocator.alloc(Id, id_count);
    defer allocator.free(ids);

    for (ids) |*id| {
        id.array_length = 1;
    }

    const local_size_x_id: ?u32 = null;
    const local_size_y_id: ?u32 = null;
    const local_size_z_id: ?u32 = null;

    var word_index: usize = 5;

    while (word_index < shader_module_code.len) {
        const word = shader_module_code[word_index];

        const instruction_opcode = @as(u16, @truncate(word));
        const instruction_word_count = @as(u16, @truncate(word >> 16));

        const words = shader_module_code[word_index .. word_index + instruction_word_count];

        switch (instruction_opcode) {
            spirv.SpvOpEntryPoint => {
                const name_begin = @as([*:0]const u8, @ptrCast(&words[3]));

                const name = std.mem.span(name_begin);

                result.entry_point = name;
            },
            spirv.SpvOpExecutionMode => {},
            spirv.SpvOpExecutionModeId => {},
            spirv.SpvOpDecorate => {
                const id = words[1];

                std.debug.assert(id < id_count);

                switch (words[2]) {
                    spirv.SpvDecorationDescriptorSet => {
                        ids[id].set = words[3];
                    },
                    spirv.SpvDecorationBinding => {
                        ids[id].binding = words[3];
                    },
                    else => {},
                }
            },
            spirv.SpvOpTypeStruct,
            spirv.SpvOpTypeImage,
            spirv.SpvOpTypeSampler,
            spirv.SpvOpTypeSampledImage,
            spirv.SpvOpTypeArray,
            spirv.SpvOpTypeRuntimeArray,
            => {
                const id = words[1];

                ids[id].opcode = instruction_opcode;

                switch (instruction_opcode) {
                    spirv.SpvOpTypeArray => {
                        ids[id].opcode = ids[words[2]].opcode;
                        ids[id].array_length = ids[words[3]].constant;
                    },
                    else => {},
                }
            },
            spirv.SpvOpTypePointer => {
                const id = words[1];

                ids[id].opcode = instruction_opcode;
                ids[id].type_id = words[3];
                ids[id].storage_class = words[2];
            },
            spirv.SpvOpConstant => {
                const id = words[2];

                ids[id].opcode = instruction_opcode;
                ids[id].type_id = words[1];
                ids[id].constant = words[3];
            },
            spirv.SpvOpVariable => {
                const id = words[2];

                ids[id].opcode = instruction_opcode;
                ids[id].type_id = words[1];
                ids[id].storage_class = words[3];
            },
            else => {},
        }

        word_index += instruction_word_count;
    }

    id_loop: for (ids) |id| {
        if (id.opcode == spirv.SpvOpVariable and
            (id.storage_class == spirv.SpvStorageClassUniform or
            id.storage_class == spirv.SpvStorageClassUniformConstant or
            id.storage_class == spirv.SpvStorageClassStorageBuffer or
            id.storage_class == spirv.SpvStorageClassImage))
        {
            const type_kind = ids[ids[id.type_id].type_id].opcode;
            const array_length = ids[ids[id.type_id].type_id].array_length;
            const resource_type = getDescriptorType(type_kind);

            if (resource_type == null) continue;

            {
                for (result.resources) |resource| {
                    if (resource.binding == id.binding and resource.descriptor_type == resource_type.?) {
                        continue :id_loop;
                    }
                }
            }

            result.resources[result.resource_count] = .{
                .descriptor_type = resource_type.?,
                .descriptor_count = array_length,
                .binding = id.binding,
            };

            result.resource_mask |= @as(u32, 1) << @as(u5, @intCast(id.binding));
            result.resource_count += 1;
        }
    }

    if (local_size_x_id != null) {
        result.local_size_x = ids[local_size_x_id.?].constant;
    }

    if (local_size_y_id != null) {
        result.local_size_y = ids[local_size_y_id.?].constant;
    }

    if (local_size_z_id != null) {
        result.local_size_z = ids[local_size_z_id.?].constant;
    }
}
