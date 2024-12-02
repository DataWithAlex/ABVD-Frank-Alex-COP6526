   # src/abm_processing.jl

   using CSV
   using DataFrames
   using VideoIO
   using Images
   using Logging
   using Agents
   using ProgressMeter
   using FileIO

   @agent PixelAgent GridAgent{2} begin
       hsl_value::HSL
       active::Bool
       unattractive_steps::Int
   end

   @agent PixelAgent GridAgent{2} begin
    hsl_value::HSL
    active::Bool
    unattractive_steps::Int
end

   # Define logging function with log levels
   function log_message(msg, level="INFO")
       if level == "ERROR" || level == "WARNING" || level == "INFO"
           println("[$level] $msg")
       end
   end

   function despawn!(agent, model)
       # Despawn agent if unattractive steps exceed threshold
       remove_agent!(agent, model)
   end

   # Utility functions
   function motivated_move(current_pos, positions, hsl_matrix)
       max_lightness = 0
       max_position = rand(positions)

       for (y, x) in positions
           lightness = hsl_matrix[y, x].l
           if lightness > max_lightness
               max_lightness = lightness
               max_position = (y, x)
           end
       end

       return max_position
   end

   function move!(agent, model, hsl_matrix)
       pixel_color = hsl_matrix[agent.pos[1], agent.pos[2]]

       if inactive_test(agent.unattractive_steps, pixel_color)
           agent.active = false
       else
           neighboring_positions = collect(nearby_positions(agent, model, rand(1:3)))

           if rand() < 0.10
               move_agent!(agent, rand(neighboring_positions), model)
           elseif pixel_color.l > 0.7
               neighboring_positions = collect(nearby_positions(agent, model, 1))
               move_agent!(agent, rand(neighboring_positions), model)
           elseif pixel_color.l > 0.5
               neighboring_positions = collect(nearby_positions(agent, model, 1))
               if !isempty(neighboring_positions)
                   new_pos = motivated_move(agent.pos, neighboring_positions, hsl_matrix)
                   move_agent!(agent, new_pos, model)
               end
           else
               neighboring_positions = collect(nearby_positions(agent, model, 3))
               if !isempty(neighboring_positions)
                   new_pos = motivated_move(agent.pos, neighboring_positions, hsl_matrix)
                   move_agent!(agent, new_pos, model)
               end
           end
       end
   end

   function inactive_test(steps, hsl)
       global parameters
       return rand() < (steps * parameters[:unattractive_tolerance])
   end

   function mutate_color!(agent, p_hsl)
       global parameters
       mutation_strength = parameters[:mutation_strength]
       mutation_rate = parameters[:mutation_rate]
       a_hsl = agent.hsl_value

       old_hue, old_saturation, old_lightness = a_hsl.h, a_hsl.s, a_hsl.l

       if rand() < parameters[:random_color_rate]
           agent.hsl_value = HSL(rand() * 360, rand(), rand() * 0.5)
       elseif a_hsl.l > 0.3
           agent.hsl_value = HSL(
               clamp(a_hsl.h + (p_hsl.h - a_hsl.h) * mutation_rate, 0, 360),
               clamp((a_hsl.s + p_hsl.s) / 2, 0.5, 1),
               clamp((a_hsl.l + p_hsl.l) / 2, 0, 1)
           )
       else
           agent.hsl_value = HSL(
               clamp(a_hsl.h + rand() * 360 * mutation_strength, 0, 360),
               clamp(a_hsl.s + (rand() - 0.5) * mutation_strength, 0.5, 1),
               clamp(a_hsl.l + (rand() - 0.5) * mutation_strength - 0.01, 0.1, 0.5)
           )
       end
   end

   function initialize_abm_model(input_image, population_mod)
       hsl_matrix = convert(Matrix{HSL}, input_image)
       frame_dims = size(hsl_matrix)
       grid_dims = (frame_dims[1], frame_dims[2])

       model = ABM(PixelAgent, GridSpace(grid_dims, periodic=false))
       global agent_id_counter = 1
       position_to_agent = Dict()

       for y in 1:population_mod:frame_dims[1], x in 1:population_mod:frame_dims[2]
           hsl_value = hsl_matrix[y, x]
           agent = PixelAgent(agent_id_counter, (y, x), hsl_value, true, 0)
           add_agent!(agent, model)
           position_to_agent[(y, x)] = agent
           global agent_id_counter += 1
       end

       log_message("Model initialized with $(nagents(model)) agents.")
       return model, grid_dims, agent_id_counter, position_to_agent
   end

   # Function to process video frames and save them to a folder
   function apply_abm_distortion_to_video(input_video_path; parameters)
       frame_folder = "../outputs/frames_temp/"
       processed_folder = "../outputs/processed_frames_temp/"

       isdir(frame_folder) || mkpath(frame_folder)
       isdir(processed_folder) || mkpath(processed_folder)

       log_message("Processing video $input_video_path")

       video = VideoIO.openvideo(input_video_path)
       frame_index = 1
       while !eof(video)
           frame = read(video)
           save("$frame_folder/frame_$frame_index.png", frame)
           frame_index += 1
       end
       close(video)
       log_message("Extracted $(frame_index - 1) frames from $input_video_path.")

       first_frame = load("$frame_folder/frame_1.png")
       global model, grid_dims, agent_id_counter, position_to_agent = initialize_abm_model(first_frame, parameters[:pixel_pop_mod])

       # Create a progress bar
       progress = Progress(frame_index - 1, 1, "Processing frames")

       for i in 1:frame_index - 1
           original_frame = load("$frame_folder/frame_$i.png")
           distorted_frame = apply_abm_distortion(original_frame, model, agent_id_counter)
           save("$processed_folder/frame_$i.png", distorted_frame)
           
           # Update progress bar
           next!(progress)
           
           # Log every 10 frames
           if i % 10 == 0
               flush(stdout)  # Ensure the output is immediately displayed
           end
       end

       # Log a summary of the processing
       log_message("Completed processing of $frame_index frames.")
   end

   function apply_abm_distortion(input_image, model, agent_id_counter)
       hsl_matrix = convert(Matrix{HSL}, input_image)
       frame_dims = size(hsl_matrix)

       despawn_counter = 0
       global parameters

       # Initialize the distorted frame with a default color
       distorted_frame = fill(RGB(0, 0, 0), frame_dims[1], frame_dims[2])

       for agent in allagents(model)
           old_pos = agent.pos  # Store the old position

           move!(agent, model, hsl_matrix)
           mutate_color!(agent, hsl_matrix[agent.pos[1], agent.pos[2]])

           if !agent.active
               despawn!(agent, model)
               despawn_counter += 1
           end

           if hsl_matrix[agent.pos[1], agent.pos[2]].l < parameters[:unattractive_threshold]
               agent.unattractive_steps += 1
           else
               agent.unattractive_steps = 0
           end

           # Update the current position with the agent's color
           color = RGB(agent.hsl_value)
           for i in 0:parameters[:pixel_size]-1
               for j in 0:parameters[:pixel_size]-1
                   y = clamp(agent.pos[1] + i, 1, frame_dims[1])
                   x = clamp(agent.pos[2] + j, 1, frame_dims[2])
                   distorted_frame[y, x] = color
               end
           end

           # Clear the old position if trailing is false
           if !parameters[:trailing] && old_pos != agent.pos
               for i in 0:parameters[:pixel_size]-1
                   for j in 0:parameters[:pixel_size]-1
                       y = clamp(old_pos[1] + i, 1, frame_dims[1])
                       x = clamp(old_pos[2] + j, 1, frame_dims[2])
                       distorted_frame[y, x] = RGB(0, 0, 0)  # Clear the trail
                   end
               end
           end
       end

       return colorview(RGB, distorted_frame)
   end