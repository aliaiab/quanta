//!Namespace containing functions for use in zig gpu programs

///Returns the instance of the current vertex (only valid in a vertex program)
pub fn vertexIndex() u32 {
    return asm volatile (
        \\%p = OpVariable %P Input
        \\     OpDecorate %p BuiltIn VertexIndex
        \\%v = OpLoad %u32 %p
        : [v] "" (-> u32),
        : [P] "t" (*addrspace(.input) const u32),
          [u32] "t" (u32),
    );
}

///Returns the DrawIDARB for the current draw
pub fn drawIndex() u32 {
    return asm volatile (
        \\%p = OpVariable %P Input
        \\     OpDecorate %p BuiltIn DrawIndex
        \\%v = OpLoad %u32 %p
        : [v] "" (-> u32),
        : [P] "t" (*addrspace(.input) const u32),
          [u32] "t" (u32),
    );
}

///Returns index of the current instance
pub fn instanceIndex() u32 {
    return asm volatile (
        \\%p = OpVariable %P Input
        \\     OpDecorate %p BuiltIn InstanceIndex
        \\%v = OpLoad %u32 %p
        : [v] "" (-> u32),
        : [P] "t" (*addrspace(.input) const u32),
          [u32] "t" (u32),
    );
}

///Returns push constants of type T
pub fn pushConstants(comptime T: type) T {
    return asm volatile (
        \\%P = OpTypePointer PushConstant %PC
        \\%p = OpVariable %P PushConstant
        \\%v = OpLoad %PC %p
        : [v] "" (-> T),
        : [PC] "t" (T),
    );
}

pub fn storageBuffer(comptime T: type, comptime set: u32, comptime binding: u32) [*]addrspace(.storage_buffer) const T {
    return asm volatile (
        \\%p = OpVariable %P StorageBuffer
        \\     OpDecorate %p DescriptorSet $set
        \\     OpDecorate %p Binding $binding
    ++ if (@typeInfo(T) == .@"struct" and @typeInfo(T).@"struct".layout != .@"packed")
        "\nOpDecorate %T Block"
    else
        ""
    : [p] "" (-> [*]addrspace(.storage_buffer) const T),
    : [T] "t" (T),
      [P] "t" (*addrspace(.storage_buffer) const T),
      [set] "c" (set),
      [binding] "c" (binding),
    );
}
