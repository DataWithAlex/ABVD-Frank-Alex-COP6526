import streamlit as st
import requests
import os

# Streamlit app for uploading a video and calling the Genie server
st.title("Video Uploader and Processor")

# Set Genie server URL for local processing
genie_url = "http://localhost:8080/process_video"

# Upload video file
uploaded_file = st.file_uploader("Choose a video...", type=["mp4"])

# Parameter inputs
st.sidebar.title("Parameter Settings")
pixel_size = st.sidebar.slider("Pixel Size", min_value=1, max_value=20, value=8)
pixel_pop_mod = st.sidebar.slider("Pixel Population Modulation", min_value=1, max_value=50, value=10)
sim_per_frames = st.sidebar.slider("Simulations per Frame", min_value=1, max_value=10, value=1)
mutation_strength = st.sidebar.slider("Mutation Strength", min_value=0.0, max_value=1.0, value=0.6)
unattractive_tolerance = st.sidebar.slider("Unattractive Tolerance", min_value=0.0, max_value=1.0, value=0.02)
unattractive_threshold = st.sidebar.slider("Unattractive Threshold", min_value=0.0, max_value=1.0, value=0.2)
mutation_rate = st.sidebar.slider("Mutation Rate", min_value=0.0, max_value=1.0, value=0.5)
random_color_rate = st.sidebar.slider("Random Color Rate", min_value=0.0, max_value=1.0, value=0.1)
trailing = st.sidebar.checkbox("Trailing", value=True)

if uploaded_file is not None:
    # Save the uploaded video to a temporary local file
    temp_video_path = os.path.join(os.getcwd(), f"temp_{uploaded_file.name}")
    
    with open(temp_video_path, "wb") as f:
        f.write(uploaded_file.read())
    
    st.video(temp_video_path)

    # Use local file path for the Local server endpoint
    payload = {
        "video_path": temp_video_path,
        "parameters": {
            "pixel_size": pixel_size,
            "pixel_pop_mod": pixel_pop_mod,
            "sim_per_frames": sim_per_frames,
            "mutation_strength": mutation_strength,
            "unattractive_tolerance": unattractive_tolerance,
            "unattractive_threshold": unattractive_threshold,
            "mutation_rate": mutation_rate,
            "random_color_rate": random_color_rate,
            "trailing": trailing
        }
    }

    st.write("Sending video for processing...")

    try:
        # Send request to Genie server
        response = requests.post(genie_url, json=payload)
        response_data = response.json()
        
        if response_data.get("success"):
            st.success("Video processed successfully!")
            processed_video_path = response_data.get("output_path")
            
            # Display the processed video if using local processing
            if os.path.exists(processed_video_path):
                st.video(processed_video_path)
        else:
            st.error(f"Processing failed: {response_data.get('message')}")
            st.write("Error details:", response_data.get("error"))
    except requests.exceptions.RequestException as e:
        st.error(f"Failed to connect to the Genie server: {e}")

    # Clean up the temporary file after processing
    if os.path.exists(temp_video_path):
        os.remove(temp_video_path)