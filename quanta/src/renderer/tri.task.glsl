#version 450
#extension GL_EXT_mesh_shader : require

void main() 
{
	EmitMeshTasksEXT(3, 1, 1);
}