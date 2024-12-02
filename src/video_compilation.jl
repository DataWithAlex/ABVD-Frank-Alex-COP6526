   # src/video_compilation.jl

   function compile_video_from_frames(input_folder, output_video_path, fps=30)
    println("Starting video compilation...")
    python_path = "/path/to/your/python"  # Adjust this path
    script_path = "../video-compiler.py"  # Adjusted path to the script
    try
        command = `$python_path $script_path $input_folder $output_video_path --fps $fps`
        println("Running Python script to compile video...")
        println("Command: $command")

        output = read(command, String)
        println("Python script output:\n$output")
        log_message("Python script output:\n$output")

        log_message("Video saved to $output_video_path.")
        println("Video saved to $output_video_path.")
    catch e
        log_message("Error executing Python script: $e")
        println("Error executing Python script: $e")
    end
end