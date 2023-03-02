
#include "imgui.h"
#include "ImGuizmo.h"

extern "C"
{
    void ImGuizmo_SetDrawlist(ImDrawList *drawlist = nullptr)
    {
        ImGuizmo::SetDrawlist(drawlist);
    }

    void ImGuizmo_BeginFrame()
    {
        ImGuizmo::BeginFrame();
    }

    void ImGuizmo_SetImGuiContext(ImGuiContext *ctx)
    {
        ImGuizmo::SetImGuiContext(ctx);
    }
    
    bool ImGuizmo_IsOver()
    {
        return ImGuizmo::IsOver();
    }

    bool ImGuizmo_IsUsing() 
    {
        return ImGuizmo::IsUsing();
    }

    void ImGuizmo_Enable(bool enable)
    {
        ImGuizmo::Enable(enable);
    }
    
    void ImGuizmo_DecomposeMatrixToComponents(const float *matrix, float *translation, float *rotation, float *scale)
    {
        ImGuizmo::DecomposeMatrixToComponents(matrix, translation, rotation, scale);
    }

    void ImGuizmo_RecomposeMatrixFromComponents(const float *translation, const float *rotation, const float *scale, float *matrix)
    {
        ImGuizmo::RecomposeMatrixFromComponents(translation, rotation, scale, matrix);
    }

    void ImGuizmo_SetRect(float x, float y, float width, float height)
    {
        ImGuizmo::SetRect(x, y, width, height);
    }

    void ImGuizmo_SetOrthographic(bool isOrthographic)
    {
        ImGuizmo::SetOrthographic(isOrthographic);
    }

    void ImGuizmo_DrawCubes(const float *view, const float *projection, const float *matrices, int matrixCount)
    {
        ImGuizmo::DrawCubes(view, projection, matrices, matrixCount);
    }

    void ImGuizmo_DrawGrid(const float *view, const float *projection, const float *matrix, const float gridSize)
    {
        ImGuizmo::DrawGrid(view, projection, matrix, gridSize);
    }

    bool ImGuizmo_Manipulate(const float *view, const float *projection, ImGuizmo::OPERATION operation, ImGuizmo::MODE mode, float *matrix, float *deltaMatrix, const float *snap, const float *localBounds, const float *boundsSnap)
    {
        return ImGuizmo::Manipulate(view, projection, operation, mode, matrix, deltaMatrix, boundsSnap);
    }
    
    void ImGuizmo_ViewManipulate(float *view, float length, ImVec2 position, ImVec2 size, ImU32 backgroundColor)
    {
        ImGuizmo::ViewManipulate(view, length, position, size, backgroundColor);    
    }

    void ImGuizmo_ViewManipulateExt(float *view, const float *projection, ImGuizmo::OPERATION operation, ImGuizmo::MODE mode, float *matrix, float length, ImVec2 position, ImVec2 size, ImU32 backgroundColor)
    {
        ImGuizmo::ViewManipulate(view, length, position, size, backgroundColor);    
    }

    void ImGuizmo_SetID(int id)
    {
        ImGuizmo::SetID(id);
    }

    bool ImGuizmo_IsOperationOver(ImGuizmo::OPERATION op)
    {
        return ImGuizmo::IsOver(op);
    }

    void ImGuizmo_SetGizmoSizeClipSpace(float value)
    {
        ImGuizmo::SetGizmoSizeClipSpace(value);
    }
    
    void ImGuizmo_AllowAxisFlip(bool value)
    {
        ImGuizmo::AllowAxisFlip(value);
    }
}