# genie.jl

using Genie
using Genie.Router
using Genie.Renderer.Json
using Genie.Requests
using Genie.Responses
using JSON
include("src/abm_processing.jl")
include("src/video_compilation.jl")

Genie.config.run_as_server = true
Genie.config.server_host = "0.0.0.0"
Genie.config.server_port = 8080

global parameters = Dict(
    :pixel_size => 8,          # Smaller pixel size for more detail
    :pixel_pop_mod => 10,      # More initial agents
    :sim_per_frames => 1,      # Keep as is
    :mutation_strength => 0.6, # Increase for more color variation
    :unattractive_tolerance => 0.02,  # Lower tolerance to reduce despawning
    :unattractive_threshold => 0.2,   # Lower threshold to keep agents active longer
    :mutation_rate => 0.5,     # Increase for more color change
    :random_color_rate => 0.1, # Increase for more random color generation
    :trailing => false         # Keep as is
)

function compile_video_from_frames(input_dir, output_file, fps)
    python_path = "/Users/alexsciuto/Library/Mobile Documents/com~apple~CloudDocs/DataWithAlex/ABM-Project-Frank-Alex-COP6526/ABVD-Frank-Alex-COP6526/venv/bin/python"
    script_path = "video-compiler.py"  # Ensure this is correct relative to your project root
    command = `$python_path $script_path $input_dir $output_file --fps $fps`
    try
        run(command)
    catch e
        println("Error executing Python script: ", e)
    end
end

route("/process_video", method = POST) do
    payload = jsonpayload()
    video_path = payload["video_path"]
    apply_abm_distortion_to_video(video_path; parameters)
    compile_video_from_frames("outputs/processed_frames_temp", "outputs/output_video.mp4", 30)
    return JSON.json(Dict("success" => true, "output_path" => "outputs/output_video.mp4"))
end

# Start the Genie server
up()