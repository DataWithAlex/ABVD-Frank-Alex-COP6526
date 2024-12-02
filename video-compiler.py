import cv2
import os
import glob
import argparse

def create_video_from_frames(input_folder, output_path, fps=30):
    # Get all PNG files in the folder and sort them
    frames = glob.glob(os.path.join(input_folder, "frame_*.png"))
    frames.sort(key=lambda x: int(x.split('frame_')[1].split('.')[0]))
    
    if not frames:
        raise ValueError("No frames found in the specified folder")
    
    # Read the first frame to get dimensions
    first_frame = cv2.imread(frames[0])
    height, width, _ = first_frame.shape
    
    # Initialize video writer with H.264 codec
    fourcc = cv2.VideoWriter_fourcc(*'avc1')  # H.264 codec
    out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
    
    # Write frames to video
    for i, frame_path in enumerate(frames):
        frame = cv2.imread(frame_path)
        out.write(frame)
        if i % 100 == 0:  # Progress indicator every 100 frames
            print(f"Processing frame {i+1}/{len(frames)}")
    
    # Release the video writer
    out.release()
    print(f"Video created successfully at: {output_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create a video from frames.")
    parser.add_argument("input_folder", type=str, help="Folder containing the frames")
    parser.add_argument("output_path", type=str, help="Output video file path")
    parser.add_argument("--fps", type=int, default=30, help="Frames per second for the video")
    args = parser.parse_args()

    create_video_from_frames(args.input_folder, args.output_path, fps=args.fps)