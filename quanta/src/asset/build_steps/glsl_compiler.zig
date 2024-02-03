//!A replacement for google's shaderc. A frontend to khronos glslang for use in zig build.
//!As such, this frontend does not need to provide a human readable command line interface.

const glslang_c = @cImport(
    @cInclude("glslang/Include/glslang_c_interface.h"),
);

extern fn glslang_default_resource() callconv(.C) *const glslang_c.glslang_resource_t;

fn glslIncludeLocalFunc(
    context: ?*anyopaque,
    header_name: [*c]const u8,
    includer_name: [*c]const u8,
    include_depth: usize,
) callconv(.C) [*c]glslang_c.glsl_include_result_t {
    _ = context;
    std.log.err("HELLO FROM INCLUDE FUNC: header_name = {s}, includer_name = {s}, include_depth = {}", .{
        header_name,
        includer_name,
        include_depth,
    });

    const result = std.heap.c_allocator.create(glslang_c.glsl_include_result_t) catch @panic("");

    return result;
}

fn glslIncludeResultFree(context: ?*anyopaque, glsl_include_result: [*c]glslang_c.glsl_include_result_t) callconv(.C) c_int {
    _ = context;

    std.heap.c_allocator.destroy(@as(*glslang_c.glsl_include_result_t, @ptrCast(glsl_include_result)));
    return 0;
}

pub fn main() !void {
    var process_args_iterator = std.process.args();

    _ = process_args_iterator.next().?;

    const arg_optimize = process_args_iterator.next().?;

    const shader_optimize = std.meta.stringToEnum(std.builtin.OptimizeMode, arg_optimize).?;

    const arg_stage = process_args_iterator.next().?;

    const Stage = enum {
        vertex,
        fragment,
        compute,
    };

    const stage = std.meta.stringToEnum(Stage, arg_stage).?;

    const arg_input_path = process_args_iterator.next().?;

    const source_file_data = try std.fs.cwd().readFileAllocOptions(
        std.heap.page_allocator,
        arg_input_path,
        std.math.maxInt(u32),
        null,
        1,
        0,
    );

    const arg_output_path = process_args_iterator.next().?;

    std.log.info("Hello from glsl_compiler", .{});

    if (glslang_c.glslang_initialize_process() == 0) {
        return error.FailedToInitializeProcess;
    }

    defer glslang_c.glslang_finalize_process();

    const shader_stage: c_uint = switch (stage) {
        .vertex => glslang_c.GLSLANG_STAGE_VERTEX,
        .fragment => glslang_c.GLSLANG_STAGE_FRAGMENT,
        .compute => glslang_c.GLSLANG_STAGE_COMPUTE,
    };

    const struct_glslang_input_s = extern struct {
        language: glslang_c.glslang_source_t,
        stage: glslang_c.glslang_stage_t,
        client: glslang_c.glslang_client_t,
        client_version: glslang_c.glslang_target_client_version_t,
        target_language: glslang_c.glslang_target_language_t,
        target_language_version: glslang_c.glslang_target_language_version_t,
        code: [*c]const u8,
        default_version: c_int,
        default_profile: glslang_c.glslang_profile_t,
        force_default_version_and_profile: c_int,
        forward_compatible: c_int,
        messages: glslang_c.glslang_messages_t,
        resource: [*c]const glslang_c.glslang_resource_t,
        callbacks: glslang_c.glsl_include_callbacks_t,
        context: ?*anyopaque,
    };

    var input: struct_glslang_input_s = .{
        .language = glslang_c.GLSLANG_SOURCE_GLSL,
        .stage = shader_stage,
        .client = glslang_c.GLSLANG_CLIENT_VULKAN,
        .client_version = glslang_c.GLSLANG_TARGET_VULKAN_1_3,
        .target_language = glslang_c.GLSLANG_TARGET_SPV,
        .target_language_version = glslang_c.GLSLANG_TARGET_SPV_1_5,
        .code = source_file_data.ptr,
        .default_version = 450,
        .default_profile = glslang_c.GLSLANG_NO_PROFILE,
        .force_default_version_and_profile = @intFromBool(false),
        .forward_compatible = @intFromBool(false),
        .messages = glslang_c.GLSLANG_MSG_DEFAULT_BIT | glslang_c.GLSLANG_MSG_DEBUG_INFO_BIT | glslang_c.GLSLANG_MSG_ENHANCED,
        .resource = glslang_default_resource(),
        .callbacks = .{
            // .include_local = &glslIncludeLocalFunc,
            // .include_system = &glslIncludeLocalFunc,
            // .free_include_result = &glslIncludeResultFree,
            .include_local = null,
            .include_system = null,
            .free_include_result = null,
        },
        .context = null,
    };

    const shader = glslang_c.glslang_shader_create(@ptrCast(&input)) orelse return error.FailedToCreateShader;
    defer glslang_c.glslang_shader_delete(shader);

    // glslang_c.glslang_shader_set_preamble(shader, "#extension GL_GOOGLE_include_directive : enable\n");
    glslang_c.glslang_shader_set_options(shader, glslang_c.GLSLANG_SHADER_AUTO_MAP_LOCATIONS);

    errdefer {
        std.log.err("{s}", .{arg_input_path});
        std.log.err("{s}", .{glslang_c.glslang_shader_get_info_log(shader)});
        std.log.err("{s}", .{glslang_c.glslang_shader_get_info_debug_log(shader)});
    }

    if (glslang_c.glslang_shader_preprocess(shader, @ptrCast(&input)) == 0) {
        return error.CompileFailed;
    }

    if (glslang_c.glslang_shader_parse(shader, @ptrCast(&input)) == 0) {
        return error.CompileFailed;
    }

    const program = glslang_c.glslang_program_create() orelse return error.FailedToCreateProgram;
    defer glslang_c.glslang_program_delete(program);

    glslang_c.glslang_program_add_shader(program, shader);

    if (glslang_c.glslang_program_link(program, glslang_c.GLSLANG_MSG_SPV_RULES_BIT | glslang_c.GLSLANG_MSG_VULKAN_RULES_BIT) == 0) {
        return error.LinkFailed;
    }

    if (glslang_c.glslang_program_map_io(program) == 0) {
        return error.InputOutputMappingFailed;
    }

    const file_path = try std.heap.page_allocator.dupeZ(u8, arg_input_path);

    glslang_c.glslang_program_add_source_text(program, shader_stage, source_file_data.ptr, source_file_data.len);
    glslang_c.glslang_program_set_source_file(program, shader_stage, file_path);

    var spirv_options: glslang_c.glslang_spv_options_t = .{
        .generate_debug_info = shader_optimize == .Debug and false,
        .strip_debug_info = shader_optimize != .Debug,
        .disable_optimizer = shader_optimize == .Debug,
        .optimize_size = shader_optimize == .ReleaseSmall,
        .disassemble = false,
        .validate = true,
        .emit_nonsemantic_shader_debug_info = shader_optimize == .Debug and false,
        .emit_nonsemantic_shader_debug_source = shader_optimize == .Debug and false,
    };

    glslang_c.glslang_program_SPIRV_generate_with_options(program, shader_stage, &spirv_options);

    const spirv_messages = glslang_c.glslang_program_SPIRV_get_messages(program);

    if (spirv_messages != null) {
        std.log.err("{s}", .{spirv_messages});

        return error.SpirvGenerationFailed;
    }

    const binary_size = glslang_c.glslang_program_SPIRV_get_size(program);
    const spirv_ptr = glslang_c.glslang_program_SPIRV_get_ptr(program);

    const spirv_data = spirv_ptr[0..binary_size];

    std.log.info("Generated binary: len = {}", .{spirv_data.len});

    try std.fs.cwd().writeFile(arg_output_path, std.mem.sliceAsBytes(spirv_data));
}

const std = @import("std");
