//When this file is compiled as the root source file of a spirv object, alongside a "module".zig file
//This will do the std.start style work of exporting the main entrypoint in "module".zig
comptime {
    const module = @import("module");

    if (@hasDecl(module, "main")) {
        const main = @field(module, "main");

        @export(&main, .{
            .name = "main",
        });
    }
}
