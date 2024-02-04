
//rendering function which encodes its commands and resources and passes into a graph passed in
//similar to an imgui
void render_main(*GraphBuilder graph) {
    const outputs_from_other_pass = :blk {
        _ = imGraphBeginPass(graph, "");

        //some unrelated pass work
        break :blk imGraphEndPass();
    }

    {
        _ = imGraphBeginPass(graph, "", .{});
        defer _ = imGraphEndPass();

        //some unrelated pass work
    }

    {
        //do we create retained resources as thus?:
        //on a second run of this function (and second compile) this should ALWAYS resolve to the same resource
        //This would allow (or require depending on how you look at it) for just in time/lazy compilation of pipleines
        //Is this really what we want?
        //This may call for taht VK_EXT_shader_object extension.
        //We could also just mandate that this is a retained object with retained semantics. 
        //(A potentially reasonable comprimise between retained and immediate mode api)
        const modules = .{
            .{ .code = @embedFile("...spv"), },
        };

        //Resource 'creation' builtins. Backing resources (allocations) are reused between frames given reasonable inputs
        //As such, these only really 'create' resources once (generally)
        const pipeline = imGraphCreatePipeline(modules, ...);
        const index_buffer = imGraphCreateBuffer(... data size);

        //the index buffer with the data in it
        var updated_index_buffer: BufferResource(.general) = index_buffer;

        {
            const inputs = imGraphBeginPass(graph, .{
                .index_buffer = index_buffer,
            });

            //writes to memory will produce a new buffer resource in ssa form
            //same thing for updates to textures, attachments, staging buffers
            //should staging buffers be abstracted away?
            const written_buffer = imGraphUpdateBuffer(graph, inputs.index_buffer, .{ 0, 1, 2, 3, 4, 5 ... }); //some index data

            const outputs = imGraphEndPass(graph, .{ .index_buffer = written_buffer });

            updated_index_buffer = outputs.index_buffer;
        }

        //eg... could come from a loaded asset file 
        //also, if initial data changes, a new resource will get 'created' (or the old one will get updated)
        //this is paramount for asset streaming
        const some_texture = imGraphCreateImage(... inital data);

        //each pass, resource ect.. needs a ~~persistant~~ id: could be a string, source location, hash ect..
        //imGraphBeginPass produces pass inputs for use in the pass
        //pass inputs are ONLY valid during the begin/end of the pass
        const inputs = imGraphBeginPass(graph, "forward color pass", .{
            //represents a resource transition and memory write barrier (so writes are observable to coming pass)
            .radiance_color = imGraphResourceLayoutCast(outputs_from_other_pass.radiance_color, Layout.attachment),
            .shadow_map = imGraphResourceLayoutCast(outputs_from_other_pass.shadow_map, Layout.general),
            //no layout transition required, so no casting required (and vice versa)
            .indirect_commands = indirect_commands,
        }));

        //encoding into pass

        //get transient resource handle
        //acts as an ssa assignment from one input to a transient "reference" with the given layout
        //encodes both the idea of a layout transition AND memory barrier 
        const radiance_color = inputs.radiance_color; //(from begin pass)

        //Could we specify these as inputs to imGraphBeginPass?
        //Perhaps render pass resource inputs are implicitly input attachments and vice versa for outputs 
        const shadow_map = inputs.shadow_map;

        //specify that we want the outputed indirect_commands from a previous pass (culling)
        const indirect_commands = inputs.indirect_commands;

        //set some dynamic state 
        //these don't read or write to a resource, so no need for resource objects (simples)
        imGraphPassSetViewport(...);
        imGraphPassSetScissor(...);

        _ = imGraphPassBeginRasterPass(.{
            .attachment_color = radiance_color, 
            .depth = ..., //pass depth
        });

        {
            //the case of what a pipeline is in this api is strange.
            //do we defer compilation of pipelines to the graph compile? (maybe, maybe...)
            imGraphPassBeginPipeline(pipeline);
            defer imGraphPassEndPipeline();

            //this needs to set an index buffer resource. Where do we get that.... hmmmmm...
            setIndexBuffer(index_buffer);

            //draw our thingies
            //There are complications to this, because indirect commands are gpu resources
            //commands are being read, not written to, so no outputs are generated
            drawIndexedIndirectCount(indirect_commands, count_buffer...);
        }

        ///end raster pass provides the buffers that have been written to
        const outputs = imGraphPassEndRasterPass();

        //Writes to memory are always defined in terms of outputs (as are reads as inputs)
        //in this sense, passes are functional in nature: taking inputs and producing outputs
        //if you want to read something, you take it as input. If you want to write something, you output
        //This is where ssa comes in. If you want to 'write' to an input, you create a new ssa assignemnt
        //this means that all resources are viewed as immutable

        //imGraphPassEnd produces pass outputs
        _ = imGraphPassEnd(graph, outputs);
    }
} 

