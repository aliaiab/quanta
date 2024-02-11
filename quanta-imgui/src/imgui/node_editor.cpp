#include "imgui_node_editor.h"

extern "C" {
    using Editor = void;  

    Editor* im_node_create_editor() {
        ax::NodeEditor::Config config;
        return (Editor*)ax::NodeEditor::CreateEditor(&config);
    }

    void im_node_destroy_editor(Editor* editor) {
        ax::NodeEditor::DestroyEditor(reinterpret_cast<ax::NodeEditor::EditorContext*>(editor));
    }

    void im_node_set_current_editor(Editor* context) {
        ax::NodeEditor::SetCurrentEditor(reinterpret_cast<ax::NodeEditor::EditorContext*>(context));
    }

    void im_node_begin(const char* id, const ImVec2 size) {
        ax::NodeEditor::PushStyleVar(ax::NodeEditor::StyleVar_FlowSpeed, 150 * ImGui::GetIO().DeltaTime);
        ax::NodeEditor::Begin(id, size);
    }

    void im_node_end() {
        ax::NodeEditor::End();
    }

    void im_node_begin_node(unsigned int id) {
        ax::NodeEditor::BeginNode(id);
    }

    void im_node_end_node() {
        ax::NodeEditor::EndNode();
    }

    void im_node_begin_pin(unsigned int id, ax::NodeEditor::PinKind kind) {
        ax::NodeEditor::BeginPin(id, kind);
    }

    void im_node_end_pin() {
        ax::NodeEditor::EndPin();
    }

    void im_node_pin_rect(const ImVec2 a, const ImVec2 b) {
        ax::NodeEditor::PinRect(a, b);
    }

    void im_node_group(const ImVec2 size) {
        ax::NodeEditor::Group(size);
    }

    void im_node_set_node_position(unsigned int node, const ImVec2 pos) {
        ax::NodeEditor::SetNodePosition(node, pos);
    }

    bool im_node_link(unsigned int id, unsigned int startPinId, unsigned int endPinId) {
        return ax::NodeEditor::Link(id, startPinId, endPinId);
    }

    void im_node_link_flow(unsigned int linkId, ax::NodeEditor::FlowDirection direction) {
        ax::NodeEditor::Flow(linkId, direction);
    }

    unsigned long im_node_get_selected_nodes(ax::NodeEditor::NodeId* nodes, int size) {
        return ax::NodeEditor::GetSelectedNodes(nodes, size);
    }
}