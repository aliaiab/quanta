const std = @import("std");
const builtin = @import("builtin");
const quanta = @import("quanta");
const windowing = quanta.windowing;
const GraphicsContext = quanta.graphics.Context;
const Swapchain = quanta.graphics.Swapchain;
const CommandBuffer = quanta.graphics.CommandBuffer;
const GraphicsPipeline = quanta.graphics.GraphicsPipeline;
const Buffer = quanta.graphics.Buffer;
const Image = quanta.graphics.Image;
const Sampler = quanta.graphics.Sampler;
const png = quanta.asset.importers.png;
const gltf = quanta.asset.importers.gltf;
const zalgebra = quanta.math.zalgebra;
const imgui = quanta_imgui.cimgui;
const imguizmo = quanta_imgui.guizmo;
const entity_editor = quanta_imgui.entity_editor;
const asset = quanta.asset;
const quanta_imgui = @import("quanta_imgui");

const quanta_components = quanta.components;
const velocity_system = quanta.systems.velocity_system;
const acceleration_system = quanta.systems.acceleration_system;

const graphics = quanta.graphics;
const Renderer3D = quanta.renderer_3d.Renderer3D;
const renderer_3d_graph = quanta.renderer_3d.renderer_3d_graph;
const RendererGui = quanta_imgui.RendererGui;

const log = std.log.scoped(.example);

var state: struct {
    gpa: std.heap.GeneralPurposeAllocator(.{}) = .{},
    allocator: std.mem.Allocator = undefined,
    window_system: windowing.WindowSystem = undefined,
    window: windowing.Window = undefined,
    swapchain: graphics.Swapchain = undefined,
    asset_archive_blob: []align(std.mem.page_size) u8 = undefined,
    asset_archive: asset.Archive = undefined,

    test_scene_meshes: []Renderer3D.MeshHandle = &.{},
    test_scene_textures: []Renderer3D.TextureHandle = &.{},
    test_scene_materials: []Renderer3D.MaterialHandle = &.{},

    renderer_scene: Renderer3D.SceneHandle = undefined,
    ecs_scene: quanta.ecs.ComponentStore = undefined,
    asset_storage: asset.AssetStorage = undefined,

    entity_debugger_commands: quanta.ecs.CommandBuffer = undefined,

    camera: Renderer3D.Camera = .{
        .translation = .{ 0, 3, 12.5 },
        .target = .{ 0, 0, 0 },
        .fov = 60,
        .exposure = 2.8,
    },

    camera_position: @Vector(3, f32) = .{ 8.7, 5.7, 0.9 },
    camera_front: @Vector(3, f32) = .{ -0.9, -0.1, -0.2 },
    camera_up: @Vector(3, f32) = .{ 0, 1, 0 },
    yaw: f32 = 168.1,
    pitch: f32 = -9.1,

    last_mouse_x: f32 = 0,
    last_mouse_y: f32 = 0,
    camera_enable: bool = false,
    camera_enable_changed: bool = false,

    selected_entity: ?quanta.ecs.ComponentStore.Entity = null,
    selected_entities: std.ArrayList(quanta.ecs.ComponentStore.Entity) = undefined,
    cloned_entity_last_frame: bool = false,
    mouse_pressed_last_Frame: bool = false,

    ///Main window render graph
    render_graph: quanta.rendering.graph.Builder = undefined,
    render_graph_compile_context: quanta.rendering.graph.CompileContext = undefined,

    graph_renderer_scene: renderer_3d_graph.Scene = undefined,

    delta_time: f32 = 0.016,
} = .{};

const enable_pipeline_cache = true;
const pipeline_cache_file_path = "pipeline_cache";

pub fn init() !void {
    log.debug("All your {s} are belong to us.", .{"codebase"});
    log.debug("{s}", .{"debug"});
    log.warn("{s}", .{"warn"});
    log.err("{s}", .{"err"});

    state.gpa = std.heap.GeneralPurposeAllocator(.{}){};
    state.allocator = if (builtin.mode == .Debug) state.gpa.allocator() else std.heap.c_allocator;

    state.window_system = try windowing.WindowSystem.init();
    errdefer state.window_system.deinit();

    state.window = try state.window_system.createWindow(state.allocator, .{
        .preferred_width = 1600,
        .preferred_height = 900,
        .title = "Quanta Example",
    });
    errdefer state.window.deinit(state.allocator);

    {
        var pipeline_cache_data: []u8 = &[_]u8{};

        if (enable_pipeline_cache) {
            const file = std.fs.cwd().openFile(pipeline_cache_file_path, .{ .mode = .read_only }) catch try std.fs.cwd().createFile(pipeline_cache_file_path, .{ .read = true });
            defer file.close();

            pipeline_cache_data = try file.readToEndAlloc(state.allocator, std.math.maxInt(usize));

            log.debug("pipeline_cache_data.len = {}", .{pipeline_cache_data.len});
        }

        try GraphicsContext.init(state.allocator, &state.window, pipeline_cache_data);

        state.allocator.free(pipeline_cache_data);
    }

    state.swapchain = try Swapchain.init(
        state.allocator,
        GraphicsContext.self.surface.surface,
    );

    const imgui_context = imgui.igCreateContext(null);

    std.debug.assert(imgui_context != null);
    imgui.igSetCurrentContext(imgui_context);

    try quanta_imgui.driver.init();

    const io: *imgui.ImGuiIO = @as(*imgui.ImGuiIO, @ptrCast(imgui.igGetIO()));

    const preferred_font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf";

    const preffered_font_file = std.fs.cwd().openFile(preferred_font_path, .{}) catch null;

    if (preffered_font_file) |font_file| {
        const font_config: imgui.ImFontConfig = std.mem.zeroes(imgui.ImFontConfig);
        _ = font_config;
        io.FontAllowUserScaling = true;
        io.FontGlobalScale = @as(f32, 1) / @as(f32, 2);

        _ = imgui.ImFontAtlas_AddFontFromFileTTF(
            io.Fonts,
            preferred_font_path,
            32,
            null,
            null,
        );
        font_file.close();
    }

    const asset_archive_file_path = "example_assets_archive";

    const asset_archive_fd = try std.os.open(asset_archive_file_path, .{}, std.os.S.IRUSR | std.os.S.IWUSR);
    defer std.os.close(asset_archive_fd);

    const asset_archive_fd_stat = try std.os.fstat(asset_archive_fd);

    log.info("assets_archive size = {}", .{asset_archive_fd_stat.size});

    state.asset_archive_blob = try std.os.mmap(
        null,
        @as(usize, @intCast(asset_archive_fd_stat.size)),
        std.os.PROT.READ,
        .{
            .TYPE = .PRIVATE,
        },
        asset_archive_fd,
        0,
    );

    state.asset_archive = try asset.Archive.decode(state.allocator, state.asset_archive_blob);

    log.info("asset_archive.assets.len = {any}", .{state.asset_archive.assets.len});

    state.asset_storage = asset.AssetStorage.init(state.allocator, state.asset_archive);
    errdefer state.asset_storage.deinit();

    const test_scene_handle = try state.asset_storage.load(gltf.Import, "light_test/light_test.gltf");

    const test_scene_import = state.asset_storage.get(gltf.Import, test_scene_handle).?;

    state.test_scene_meshes = try state.allocator.alloc(Renderer3D.MeshHandle, test_scene_import.sub_meshes.len);
    state.test_scene_textures = try state.allocator.alloc(Renderer3D.TextureHandle, test_scene_import.textures.len);
    state.test_scene_materials = try state.allocator.alloc(Renderer3D.MaterialHandle, test_scene_import.materials.len);

    for (test_scene_import.sub_meshes, 0..) |sub_mesh, i| {
        _ = sub_mesh; // autofix
        _ = i; // autofix
        // state.test_scene_meshes[i] = try Renderer3D.createMesh(
        //     test_scene_import.vertex_positions[sub_mesh.vertex_offset .. sub_mesh.vertex_offset + sub_mesh.vertex_count],
        //     test_scene_import.vertices[sub_mesh.vertex_offset .. sub_mesh.vertex_offset + sub_mesh.vertex_count],
        //     test_scene_import.indices[sub_mesh.index_offset .. sub_mesh.index_offset + sub_mesh.index_count],
        //     sub_mesh.bounding_min,
        //     sub_mesh.bounding_max,
        // );
    }

    for (test_scene_import.textures, 0..) |texture, i| {
        _ = texture; // autofix
        _ = i; // autofix
        // state.test_scene_textures[i] = try Renderer3D.createTexture(
        //     texture.data,
        //     texture.width,
        //     texture.height,
        // );
    }

    for (test_scene_import.materials, 0..) |material, i| {
        _ = i; // autofix
        log.info("material albedo index {}", .{material.albedo_texture_index});
        log.info("material albedo {any}", .{material.albedo});

        // state.test_scene_materials[i] = try Renderer3D.createMaterial(
        //     if (material.albedo_texture_index != 0) state.test_scene_textures[material.albedo_texture_index - 1] else null,
        //     material.albedo,
        //     null,
        //     material.metalness,
        //     if (material.roughness_texture_index != 0) state.test_scene_textures[material.roughness_texture_index - 1] else null,
        //     material.roughness,
        // );
    }

    const environment_map = try state.asset_storage.load(asset.CubeMap, "skybox/skybox.png");
    const environment_map_data = state.asset_storage.get(asset.CubeMap, environment_map).?;
    _ = environment_map_data; // autofix

    state.ecs_scene = try quanta.ecs.ComponentStore.init(state.allocator);

    for (test_scene_import.sub_meshes, 0..) |sub_mesh, i| {
        const decomposed = zalgebra.Mat4.decompose(.{ .data = sub_mesh.transform });
        const translation = decomposed.t;
        const scale = decomposed.s;

        var rotation: @Vector(3, f32) = undefined;

        {
            const quaternion = decomposed.r;

            const yaw = std.math.atan2(
                2 * (quaternion.y * quaternion.z + quaternion.w * quaternion.x),
                quaternion.w * quaternion.w - quaternion.x * quaternion.x - quaternion.y * quaternion.y + quaternion.z * quaternion.z,
            );
            const pitch = std.math.asin(
                -2 * (quaternion.x * quaternion.z - quaternion.w * quaternion.y),
            );
            const roll = std.math.atan2(
                2 * (quaternion.x * quaternion.y + quaternion.w * quaternion.z),
                quaternion.w * quaternion.w + quaternion.x * quaternion.x - quaternion.y * quaternion.y - quaternion.z * quaternion.z,
            );

            rotation = .{ zalgebra.toDegrees(yaw), zalgebra.toDegrees(pitch), zalgebra.toDegrees(roll) };
        }

        const material = test_scene_import.materials[sub_mesh.material_index];

        _ = try state.ecs_scene.entityCreate(.{
            // quanta.components.Position{ .x = translation.x(), .y = translation.y(), .z = translation.z() },
            // quanta.components.Orientation{ .x = rotation[0], .y = rotation[1], .z = rotation[2] },
            // quanta.components.NonUniformScale{ .x = scale.x(), .y = scale.y(), .z = scale.z() },
            quanta.components.RigidTransform{
                .position = .{ .x = translation.x(), .y = translation.y(), .z = translation.z() },
                .orientation = .{ .x = rotation[0], .y = rotation[1], .z = rotation[2] },
                .scale = .{ .x = scale.x(), .y = scale.y(), .z = scale.z() },
            },
            quanta.components.RendererMeshInstance{
                .mesh = @intCast(i),
                .material = .{
                    .albedo_texture_index = 0,
                    .albedo = packUnorm4x8(material.albedo),
                    .metalness_texture_index = 0,
                    .metalness = material.metalness,
                    .roughness_texture_index = 0,
                    .roughness = material.roughness,
                },
            },
        });
    }

    //the render graph scene
    {
        state.graph_renderer_scene = .{
            .ambient_light = .{ .diffuse = packUnorm4x8(.{ 0.005, 0.005, 0.005, 1 }) },
            .point_lights = &.{},
        };

        for (test_scene_import.sub_meshes, 0..) |sub_mesh, i| {
            _ = i; // autofix
            const mesh_positions = test_scene_import.vertex_positions[sub_mesh.vertex_offset .. sub_mesh.vertex_offset + sub_mesh.vertex_count];
            const mesh_vertices = test_scene_import.vertices[sub_mesh.vertex_offset .. sub_mesh.vertex_offset + sub_mesh.vertex_count];
            const mesh_indices = test_scene_import.indices[sub_mesh.index_offset .. sub_mesh.index_offset + sub_mesh.index_count];

            try state.graph_renderer_scene.meshes.append(state.allocator, .{
                .positions_data = std.mem.sliceAsBytes(mesh_positions),
                .vertex_data = std.mem.sliceAsBytes(mesh_vertices),
                .index_data = std.mem.sliceAsBytes(mesh_indices),
            });
        }
    }

    const target_frame_time: f32 = 16;

    state.delta_time = target_frame_time;

    _ = try state.ecs_scene.entityCreate(.{
        quanta_components.Orientation{ .x = -0.5, .y = -1, .z = -0.3 },
        quanta_components.DirectionalLight{
            .intensity = 1,
            .diffuse = .{
                0.45,
                0.45,
                0.45,
            },
        },
    });

    const TestEnumComponent = enum {
        no_state,
        state_0,
        state_1,
        ect_state,
    };

    const TestUnionComponent = union(enum) {
        no_state: void,
        state_0: u32,
        state_1: void,
        ect_state: void,
    };

    _ = try state.ecs_scene.entityCreate(.{
        quanta_components.Position{ .x = 0, .y = 2, .z = 0 },
        quanta_components.Velocity{ .x = 0, .y = 1, .z = 0 },
        TestEnumComponent.state_1,
        TestUnionComponent{ .state_1 = {} },
    });

    _ = try state.ecs_scene.entityCreate(.{
        quanta_components.Position{ .x = 0, .y = 2, .z = 0 },
        quanta_components.Velocity{ .x = 0, .y = 1, .z = 0 },
        TestEnumComponent.state_1,
        TestUnionComponent{ .state_1 = {} },
    });

    const test_entity = try state.ecs_scene.entityCreate(.{
        quanta_components.Position{ .x = 0, .y = 50, .z = 0 },
        quanta_components.PointLight{
            .intensity = 1000,
            .diffuse = .{ 1, 1, 1 },
        },
        quanta_components.Visibility{ .is_visible = true },
    });

    state.selected_entity = test_entity;

    _ = try state.ecs_scene.entityCreate(.{
        quanta_components.Position{ .x = 0, .y = 4, .z = 0 },
        quanta_components.Velocity{ .x = 0, .y = 0.5, .z = 0 },
        quanta.ecs.ComponentStore.Entity.nil,
    });

    const entity_b = try state.ecs_scene.entityCreate(.{
        quanta_components.Position{ .x = 0, .y = -2, .z = 0 },
        quanta_components.Velocity{ .x = 0, .y = 1, .z = 0 },
        quanta_components.Force{ .x = 2, .y = 9.81, .z = 0 },
        quanta_components.Mass{ .value = 10 },
        quanta_components.TerminalVelocity{ .x = 0, .y = 0.01, .z = 0 },
        quanta_components.RendererMesh{ .mesh = state.test_scene_meshes[0], .material = state.test_scene_materials[0] },
    });

    const entity_a = try state.ecs_scene.entityCreate(.{
        quanta_components.Mass{ .value = 10 },
        quanta_components.Force{ .x = 2, .y = 9.81, .z = 0 },
        quanta_components.Position{ .x = 0, .y = -2, .z = 0 },
        quanta_components.RendererMesh{ .mesh = state.test_scene_meshes[0], .material = state.test_scene_materials[0] },
        quanta_components.Velocity{ .x = 0, .y = 1, .z = 0 },
        quanta_components.TerminalVelocity{ .x = 0, .y = 0.01, .z = 0 },
    });

    std.debug.assert(state.ecs_scene.entitiesAreIsomers(entity_a, entity_b));

    _ = try state.ecs_scene.entityCreate(.{
        quanta_components.Position{ .x = 0, .y = 1, .z = -4 },
        quanta_components.PointLight{
            .intensity = 10 + 40,
            .diffuse = .{ 0.8, 0.4, 0.1 },
        },
    });

    _ = try state.ecs_scene.entityCreate(.{
        quanta_components.Position{ .x = 4, .y = 4, .z = 4 },
        quanta_components.PointLight{
            .intensity = 10 + 40,
            .diffuse = .{ 0.4, 0.8, 0.1 },
        },
    });

    _ = try state.ecs_scene.entityCreate(.{
        quanta_components.Position{ .x = 80, .y = 4, .z = 4 },
        quanta_components.PointLight{
            .intensity = 1000,
            .diffuse = .{ 0.6, 0.6, 0.8 },
        },
    });

    state.entity_debugger_commands = quanta.ecs.CommandBuffer.init(state.allocator);
    state.selected_entities = std.ArrayList(quanta.ecs.ComponentStore.Entity).init(state.allocator);

    state.render_graph = quanta.rendering.graph.Builder.init(state.allocator);
    errdefer state.render_graph.deinit();

    state.render_graph_compile_context = quanta.rendering.graph.CompileContext.init(state.allocator);
    errdefer state.render_graph_compile_context.deinit();
}

pub fn deinit() void {
    GraphicsContext.self.vkd.deviceWaitIdle(GraphicsContext.self.device) catch unreachable;

    defer log.info("Exiting gracefully", .{});
    defer if (builtin.mode == .Debug) std.debug.assert(state.gpa.deinit() != .leak);

    defer state.window_system.deinit();
    defer state.window.deinit(state.allocator);
    defer GraphicsContext.deinit();

    defer if (enable_pipeline_cache) {
        const pipeline_cache_data = GraphicsContext.getPipelineCacheData() catch unreachable;
        defer state.allocator.free(pipeline_cache_data);

        const file = std.fs.cwd().openFile(pipeline_cache_file_path, .{ .mode = .write_only }) catch unreachable;
        defer file.close();

        file.setEndPos(0) catch unreachable;
        file.seekTo(0) catch unreachable;

        file.writeAll(pipeline_cache_data) catch unreachable;
    };

    defer state.swapchain.deinit();
    defer imgui.igDestroyContext(imgui.igGetCurrentContext());
    defer quanta_imgui.driver.deinit();
    defer std.os.munmap(state.asset_archive_blob);
    defer state.allocator.free(state.test_scene_meshes);
    defer state.allocator.free(state.test_scene_textures);
    defer state.allocator.free(state.test_scene_materials);
    defer state.ecs_scene.deinit();
    defer state.entity_debugger_commands.deinit();
    defer state.selected_entities.deinit();
    defer state.asset_storage.deinit();
    defer state.render_graph.deinit();
    defer state.render_graph_compile_context.deinit();
    defer state.graph_renderer_scene.deinit(state.allocator);
}

pub fn update() !UpdateResult {
    if (state.window.shouldClose()) return .exit;

    const time_begin = std.time.nanoTimestamp();

    if (!state.camera_enable_changed and state.window.getKey(.tab) == .press) {
        state.camera_enable = !state.camera_enable;

        if (state.camera_enable) {
            state.window.captureCursor();
        } else {
            state.window.uncaptureCursor();
        }

        state.camera_enable_changed = true;
    }

    if (state.window.getKey(.tab) == .release) {
        state.camera_enable_changed = false;
    }

    //update
    {
        const x_position: f32 = @floatFromInt(state.window.getCursorPosition()[0]);
        const y_position: f32 = @floatFromInt(state.window.getCursorPosition()[1]);

        // const mouse_motion: @Vector(2, f32) = @floatFromInt(state.window.getMouseMotion());

        const x_offset = x_position - state.last_mouse_x;
        const y_offset = state.last_mouse_y - y_position;

        // const x_offset: f32 = mouse_motion[0];
        // const y_offset: f32 = -mouse_motion[1];

        state.last_mouse_x = x_position;
        state.last_mouse_y = y_position;

        if (state.camera_enable) {
            const sensitivity = 0.1;
            var camera_speed: @Vector(3, f32) = @splat(30 * state.delta_time / 1000);

            if (state.window.getKey(.left_control) == .down) {
                camera_speed *= @splat(2);
            }

            state.yaw += x_offset * sensitivity;
            state.pitch += y_offset * sensitivity;

            state.pitch = std.math.clamp(state.pitch, -89, 89);

            state.camera_front = zalgebra.Vec3.norm(.{ .data = .{
                @cos(zalgebra.toRadians(state.yaw)) * @cos(zalgebra.toRadians(-state.pitch)),
                @sin(zalgebra.toRadians(state.pitch)),
                @sin(zalgebra.toRadians(state.yaw)) * @cos(zalgebra.toRadians(-state.pitch)),
            } }).data;

            if (state.window.getKey(.w) == .down) {
                state.camera_position += camera_speed * state.camera_front;
            } else if (state.window.getKey(.s) == .down) {
                state.camera_position -= camera_speed * state.camera_front;
            }

            if (state.window.getKey(.a) == .down) {
                state.camera_position -= zalgebra.Vec3.norm(zalgebra.Vec3.cross(.{ .data = state.camera_front }, .{ .data = state.camera_up })).mul(.{ .data = camera_speed }).data;
            } else if (state.window.getKey(.d) == .down) {
                state.camera_position += zalgebra.Vec3.norm(zalgebra.Vec3.cross(.{ .data = state.camera_front }, .{ .data = state.camera_up })).mul(.{ .data = camera_speed }).data;
            }

            if (state.window.getKey(.space) == .down) {
                state.camera_position[1] += camera_speed[1];
            } else if (state.window.getKey(.left_shift) == .down) {
                state.camera_position[1] -= camera_speed[1];
            }
        }

        state.camera.target = state.camera_position + state.camera_front;
        state.camera.translation = state.camera_position;
    }

    state.ecs_scene.beginQueryWindow();

    acceleration_system.run(&state.ecs_scene, state.delta_time);
    quanta.systems.force_system.run(&state.ecs_scene, state.delta_time);

    try quanta.ecs.system_scheduler.run(&state.ecs_scene, &state.entity_debugger_commands, .{velocity_system});

    quanta.systems.terminal_velocity_system.run(&state.ecs_scene);

    const image = state.swapchain.swap_images[state.swapchain.image_index];

    //sneaky hack due to our incomplete swapchain abstraction
    const color_image: Image = .{
        .handle = image.image,
        .type = .@"2d",
        .view = image.view,
        .memory_page = undefined,
        .size = undefined,
        .alignment = undefined,
        .format = state.swapchain.surface_format.format,
        .layout = .color_attachment_optimal,
        .aspect_mask = .{ .color_bit = true },
        .width = state.swapchain.extent.width,
        .height = state.swapchain.extent.height,
        .depth = 1,
        .levels = 1,
    };

    const enable_imgui = true;

    //imgui gui
    if (enable_imgui) {
        //Process UI logic
        {
            try quanta_imgui.driver.begin(&state.window);
            defer quanta_imgui.driver.end();

            const widgets = quanta_imgui.widgets;

            const io: *imgui.ImGuiIO = @as(*imgui.ImGuiIO, @ptrCast(imgui.igGetIO()));

            var pixel_pointer: [*c]u8 = undefined;
            var width: c_int = 0;
            var height: c_int = 0;
            var out_bytes_per_pixel: c_int = 0;

            //TODO: MASSIVE(?) hack: imgui asserts that we've called this function before imgui::NewFrame.
            //We call this in the render graph build for renderer_gui, which hasn't ran yet.s
            //We need to solve this as an high level api problem (when do we run grap build?)
            imgui.ImFontAtlas_GetTexDataAsRGBA32(
                io.Fonts,
                &pixel_pointer,
                &width,
                &height,
                &out_bytes_per_pixel,
            );

            imgui.igNewFrame();
            imguizmo.ImGuizmo_SetOrthographic(false);
            imguizmo.ImGuizmo_BeginFrame();

            imgui.igShowDemoWindow(null);

            if (widgets.begin("Basic properties")) {
                widgets.textFormat("Frame time {d:.2}ms", .{state.delta_time});
                widgets.textFormat("Frame rate {d:.2}Hz", .{1 / (state.delta_time / 1000)});

                if (widgets.button("Button test")) {
                    log.info("Praise be the {s}", .{"BIG BUTTON"});
                }

                widgets.text("Renderer Statistics:");

                widgets.textFormat("depth_pre_pass_time = {d:.2}ms", .{@as(f64, @floatFromInt(Renderer3D.getStatistics().depth_prepass_time)) / @as(f64, @floatFromInt(std.time.ns_per_ms))});

                widgets.textFormat("geometry_pass_time = {d:.2}ms", .{@as(f64, @floatFromInt(Renderer3D.getStatistics().geometry_pass_time)) / @as(f64, @floatFromInt(std.time.ns_per_ms))});

                _ = imgui.igDragFloat("Camera Exposure: ", &state.camera.exposure, 0.1, 0.1, 15, null, 0);
            }
            widgets.end();

            try entity_editor.entitySelector(
                &state.ecs_scene,
                &state.entity_debugger_commands,
                state.camera,
                &state.selected_entities,
                &state.window,
            );

            const primary_selected_entity = if (state.selected_entities.items.len != 0) state.selected_entities.items[0] else quanta.ecs.ComponentStore.Entity.nil;

            if (state.selected_entities.items.len != 0 and state.ecs_scene.entityHasComponent(primary_selected_entity, quanta.components.Position)) {
                const entity_position = state.ecs_scene.entityGetComponent(primary_selected_entity, quanta.components.Position) orelse unreachable;
                const entity_rotation = state.ecs_scene.entityGetComponent(primary_selected_entity, quanta.components.Orientation);
                const entity_scale = state.ecs_scene.entityGetComponent(primary_selected_entity, quanta.components.NonUniformScale);

                imguizmo.ImGuizmo_SetImGuiContext(imgui.igGetCurrentContext());
                imguizmo.ImGuizmo_Enable(true);
                imguizmo.ImGuizmo_SetDrawlist(imgui.igGetBackgroundDrawList_Nil());
                imguizmo.ImGuizmo_AllowAxisFlip(false);
                imguizmo.ImGuizmo_SetID(0);
                imguizmo.ImGuizmo_SetRect(0, 0, @as(f32, @floatFromInt(state.window.getWidth())), @as(f32, @floatFromInt(state.window.getHeight())));

                const camera_view = state.camera.getView();
                const camera_projection = state.camera.getProjectionNonInverse(&state.window);
                const camera_view_projection = zalgebra.Mat4.mul(.{ .data = camera_projection }, .{ .data = camera_view });

                var operation = imguizmo.Operation.translate;

                var manip_matrix = zalgebra.Mat4.identity();

                manip_matrix = manip_matrix.mul(zalgebra.Mat4.fromTranslate(.{ .data = .{ entity_position.x, entity_position.y, entity_position.z } }));

                if (entity_rotation != null) {
                    manip_matrix = manip_matrix.mul(zalgebra.Mat4.fromEulerAngles(.{ .data = .{ entity_rotation.?.x, entity_rotation.?.y, entity_rotation.?.z } }));

                    operation.rotate_x = true;
                    operation.rotate_y = true;
                    operation.rotate_z = true;
                    operation.rotate_screen = true;
                }

                if (entity_scale != null) {
                    manip_matrix = manip_matrix.mul(zalgebra.Mat4.fromScale(.{ .data = .{ entity_scale.?.x, entity_scale.?.y, entity_scale.?.z } }));

                    operation.scale_x = true;
                    operation.scale_y = true;
                    operation.scale_z = true;
                }

                _ = imguizmo.ImGuizmo_Manipulate(
                    @as([*]const f32, @ptrCast(&camera_view)),
                    @as([*]const f32, @ptrCast(&camera_projection)),
                    operation,
                    imguizmo.Mode.world,
                    @as([*]f32, @ptrCast(&manip_matrix.data)),
                    null,
                    null,
                    null,
                    null,
                );

                const decomposed = manip_matrix.decompose();

                const position = decomposed.t.data;
                const scale = decomposed.s.data;

                var rotation: @Vector(3, f32) = undefined;

                {
                    const quaternion = decomposed.r;

                    const yaw = std.math.atan2(
                        2 * (quaternion.y * quaternion.z + quaternion.w * quaternion.x),
                        quaternion.w * quaternion.w - quaternion.x * quaternion.x - quaternion.y * quaternion.y + quaternion.z * quaternion.z,
                    );
                    const pitch = std.math.asin(
                        -2 * (quaternion.x * quaternion.z - quaternion.w * quaternion.y),
                    );
                    const roll = std.math.atan2(
                        2 * (quaternion.x * quaternion.y + quaternion.w * quaternion.z),
                        quaternion.w * quaternion.w + quaternion.x * quaternion.x - quaternion.y * quaternion.y - quaternion.z * quaternion.z,
                    );

                    rotation = .{ zalgebra.toDegrees(yaw), zalgebra.toDegrees(pitch), zalgebra.toDegrees(roll) };
                }

                const position_change = position - @Vector(3, f32){ entity_position.x, entity_position.y, entity_position.z };
                const scale_change = if (entity_scale != null) scale - @Vector(3, f32){ entity_scale.?.x, entity_scale.?.y, entity_scale.?.z } else @Vector(3, f32){ 0, 0, 0 };
                const rotation_change = if (entity_rotation != null) rotation - @Vector(3, f32){ entity_rotation.?.x, entity_rotation.?.y, entity_rotation.?.z } else @Vector(3, f32){ 0, 0, 0 };

                for (state.selected_entities.items) |selected_entity| {
                    const selected_position = state.ecs_scene.entityGetComponent(selected_entity, quanta_components.Position);
                    const selected_rotation = state.ecs_scene.entityGetComponent(selected_entity, quanta_components.Orientation);
                    const selected_scale = state.ecs_scene.entityGetComponent(selected_entity, quanta_components.NonUniformScale);

                    if (selected_position != null) {
                        selected_position.?.* = .{
                            .x = selected_position.?.x + position_change[0],
                            .y = selected_position.?.y + position_change[1],
                            .z = selected_position.?.z + position_change[2],
                        };
                    }

                    if (selected_rotation != null) {
                        selected_rotation.?.* = .{
                            .x = selected_rotation.?.x + rotation_change[0],
                            .y = selected_rotation.?.y + rotation_change[1],
                            .z = selected_rotation.?.z + rotation_change[2],
                        };
                    }

                    if (selected_scale != null) {
                        selected_scale.?.* = .{
                            .x = selected_scale.?.x + scale_change[0],
                            .y = selected_scale.?.y + scale_change[1],
                            .z = selected_scale.?.z + scale_change[2],
                        };
                    }

                    if (state.ecs_scene.entityGetComponent(selected_entity, quanta_components.RendererMesh)) |mesh| {
                        const mesh_box = Renderer3D.getMeshBox(mesh.mesh);

                        const bounding_min = mesh_box.min;
                        const bounding_max = mesh_box.max;

                        var matrix = zalgebra.Mat4.identity();

                        matrix = matrix.mul(zalgebra.Mat4.fromTranslate(.{ .data = .{ selected_position.?.x, selected_position.?.y, selected_position.?.z } }));

                        if (selected_rotation != null) {
                            matrix = matrix.mul(zalgebra.Mat4.fromEulerAngles(.{ .data = .{ selected_rotation.?.x, selected_rotation.?.y, selected_rotation.?.z } }));

                            operation.rotate_x = true;
                            operation.rotate_y = true;
                            operation.rotate_z = true;
                            operation.rotate_screen = true;
                        }

                        if (selected_scale != null) {
                            matrix = matrix.mul(zalgebra.Mat4.fromScale(.{ .data = .{ selected_scale.?.x, selected_scale.?.y, selected_scale.?.z } }));

                            operation.scale_x = true;
                            operation.scale_y = true;
                            operation.scale_z = true;
                        }

                        widgets.drawBoundingBox(camera_view_projection, matrix, bounding_min, bounding_max);
                    }
                }
            }

            entity_editor.entityViewer(&state.ecs_scene, &state.entity_debugger_commands, &state.selected_entities);
            entity_editor.chunkViewer(&state.ecs_scene);
            quanta_imgui.log.viewer("Log");

            try state.entity_debugger_commands.execute(&state.ecs_scene);
        }

        //Draw point light gizmos
        {
            const camera_view = state.camera.getView();
            const camera_projection = state.camera.getProjectionNonInverse(&state.window);
            const camera_view_projection = zalgebra.Mat4.mul(.{ .data = camera_projection }, .{ .data = camera_view });

            var query = state.ecs_scene.query(.{quanta_components.Position}, .{});

            while (query.nextBlock()) |block| {
                for (block.Position) |position| {
                    quanta_imgui.widgets.drawBillboard(camera_view_projection, .{ position.x, position.y, position.z }, 10);
                }
            }
        }

        quanta_imgui.render_graph_debug.renderGraphDebug(&state.render_graph);

        imgui.igRender();
    }

    for (state.ecs_scene.changes.added_chunks.items) |added_chunk| {
        std.log.info("added chunk to scene: {any}", .{added_chunk});
    }

    state.ecs_scene.endQueryWindow();

    state.render_graph.clear();

    var graph_swap_image = state.render_graph_compile_context.importExternalImage(
        &state.render_graph,
        @src(),
        color_image,
    );

    var scene_point_lights: std.ArrayListUnmanaged(renderer_3d_graph.PointLight) = .{};
    defer scene_point_lights.deinit(state.allocator);

    {
        const without = quanta.ecs.ComponentStore.filterWithout;
        const filterOr = quanta.ecs.ComponentStore.filterOr;
        _ = filterOr;

        var query = state.ecs_scene.query(.{
            quanta.components.Position,
            quanta.components.PointLight,
        }, .{
            without(quanta.components.Visibility), // !Visibility
        });

        while (query.nextBlock()) |block| {
            for (block.Position, block.PointLight) |position, point_light| {
                try scene_point_lights.append(state.allocator, .{
                    .position = .{ position.x, position.y, position.z },
                    .intensity = point_light.intensity,
                    .diffuse = packUnorm4x8(.{ point_light.diffuse[0], point_light.diffuse[1], point_light.diffuse[2], 1 }),
                });
            }
        }
    }

    const Statics = struct {
        var enable_renderer_3d: bool = true;
    };

    if (state.window.getKey(.F2) == .press) {
        Statics.enable_renderer_3d = !Statics.enable_renderer_3d;
    }

    if (Statics.enable_renderer_3d) {
        state.graph_renderer_scene.point_lights = scene_point_lights.items;

        state.graph_renderer_scene.clearInstances();

        quanta.systems.mesh_instance_system.run(
            &state.ecs_scene,
            &state.graph_renderer_scene,
            state.allocator,
        );

        renderer_3d_graph.buildGraph(
            &state.render_graph,
            &state.graph_renderer_scene,
            .{
                .camera = state.camera,
            },
            &graph_swap_image,
        );
    }

    if (imgui.igGetDrawData() != null) {
        RendererGui.renderToGraph(
            &state.render_graph,
            imgui.igGetDrawData(),
            &graph_swap_image,
        );
    }

    state.render_graph.export_resource = .{ .image = graph_swap_image };

    const render_graph_compiled = try state.render_graph_compile_context.compile(
        &state.render_graph,
    );

    render_graph_compiled.graphics_command_buffer.imageBarrier(color_image, .{
        .source_stage = .{ .color_attachment_output = true },
        .source_access = .{ .color_attachment_write = true },
        .destination_stage = .{},
        .destination_access = .{},
        .source_layout = .attachment_optimal,
        .destination_layout = .present_src_khr,
    });

    render_graph_compiled.graphics_command_buffer.end();

    try render_graph_compiled.graphics_command_buffer.submitSemaphore(
        render_graph_compiled.graphics_command_buffer.wait_fence,
        image.image_acquired,
        image.render_finished,
    );

    try state.swapchain.present();
    try state.swapchain.swap();

    state.delta_time = @as(f32, @floatFromInt(std.time.nanoTimestamp() - time_begin)) / @as(f32, @floatFromInt(std.time.ns_per_ms));

    return .pass;
}

pub const UpdateResult = enum(u8) {
    ///Indicates to the app runner the app should exit
    exit,
    ///Indicates to the app runner the app should continue to next update
    pass,
};

pub fn main() !void {
    try init();
    defer deinit();

    while (true) {
        switch (try update()) {
            .pass => continue,
            .exit => break,
        }
    }
}

pub fn logFn(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const log_to_terminal = true;

    if (log_to_terminal) {
        const terminal_red = "\x1B[31m";
        const terminal_yellow = "\x1B[33m";
        const terminal_blue = "\x1B[34m";
        const terminal_green = "\x1B[32m";

        const color_begin = switch (message_level) {
            .err => terminal_red,
            .warn => terminal_yellow,
            .info => terminal_blue,
            .debug => terminal_green,
        };

        const color_end = "\x1B[0;39m";

        const level_txt = "[" ++ color_begin ++ comptime message_level.asText() ++ color_end ++ "]";
        const prefix2 = if (scope == .default) ": " else "[" ++ @tagName(scope) ++ "]: ";
        const stderr = std.io.getStdErr().writer();
        std.debug.getStderrMutex().lock();
        defer std.debug.getStderrMutex().unlock();
        nosuspend stderr.print(level_txt ++ prefix2 ++ format ++ "\n", args) catch return;
    }

    quanta_imgui.log.logMessage(message_level, scope, format, args) catch return;
}

pub const std_options: std.Options = .{
    .logFn = logFn,
};

fn packUnorm4x8(v: [4]f32) u32 {
    const Unorm4x8 = packed struct(u32) {
        x: u8,
        y: u8,
        z: u8,
        w: u8,
    };

    const x = @as(u8, @intFromFloat(v[0] * @as(f32, @floatFromInt(std.math.maxInt(u8)))));
    const y = @as(u8, @intFromFloat(v[1] * @as(f32, @floatFromInt(std.math.maxInt(u8)))));
    const z = @as(u8, @intFromFloat(v[2] * @as(f32, @floatFromInt(std.math.maxInt(u8)))));
    const w = @as(u8, @intFromFloat(v[3] * @as(f32, @floatFromInt(std.math.maxInt(u8)))));

    return @as(u32, @bitCast(Unorm4x8{
        .x = x,
        .y = y,
        .z = z,
        .w = w,
    }));
}
