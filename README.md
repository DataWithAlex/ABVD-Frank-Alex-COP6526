# ABVD-Frank-Alex-COP6526 Project

[Project Demo Video](https://youtu.be/FJEV8tFJ8F4)

## Theoretical Background

### Agent-Based Video Distortion (ABVD)

![Structure of the Digital Petri Dish](/assets/notebook-images/Structure.jpg)

#### Introduction

Our project is on a special method we developed for video distortion. Most distortion tools translate the color values of the source pixel or exploit the quirks in compression algorithms to create what's called 'data moshing'. However, independently the term data moshing evokes crowds of people pushing into one another at a punk show—got us thinking if we could use agent-based modeling to make pixels mosh.

To do this, we thought about an image as a petri dish, filled with all different kinds of nutrients and poisons, and the pixels as bacteria moving towards nutrients and away from poisons. Then, video frames are just a snapshot of a petri dish in time, followed by another petri dish in time.

The goal, then, is to create an agent (or bacteria) that will create visually interesting effects.

We've created a system where pixels behave like microscopic organisms, responding to their environment in ways that create emergent visual patterns. Each video frame becomes a moment in time of this digital ecosystem.

### The Digital Petri Dish

In our model, each frame is treated as a nutrient environment where:

- Light areas are "nutrients" that attract our pixel-organisms
- Dark areas are "toxic" zones that organisms try to avoid
- Pixels can mutate their colors based on environmental pressures
- Population dynamics emerge from birth and death cycles

This biological metaphor creates organic, flowing distortions that feel more alive than traditional effects.

### Key Parameters

- **Pixel Size**: Determines the granularity of the distortion.
- **Mutation Strength**: Controls the degree of color variation.
- **Unattractive Tolerance**: Influences agent despawning behavior.

The ABM approach allows for complex, emergent patterns that are difficult to achieve with traditional image processing techniques.

For a detailed explanation and further insights, refer to the [Project Report Notebook](notebooks/ABDV-Final-Report.ipynb).

## Setup Instructions

### Prerequisites

- **Julia**: Ensure you have Julia installed. You can download it from [JuliaLang.org](https://julialang.org/downloads/).
- **Python**: Ensure you have Python installed. It's recommended to use a virtual environment.
- **Git**: Ensure Git is installed for version control.

### Clone the Repository

```bash
git clone https://github.com/yourusername/ABVD-Frank-Alex-COP6526.git
cd ABVD-Frank-Alex-COP6526
```

### Julia Environment Setup

1. **Activate the Julia Environment**:

   Open a terminal and navigate to the project directory, then start the Julia REPL:

   ```bash
   julia
   ```

   In the Julia REPL, activate the project environment:

   ```julia
   using Pkg
   Pkg.activate(".")
   Pkg.instantiate()
   ```

2. **Install Required Packages**:

   Run the `setup_packages.jl` script to ensure all necessary Julia packages are installed:

   ```bash
   julia setup_packages.jl
   ```

### Python Environment Setup

1. **Create a Virtual Environment**:

   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   ```

2. **Install Python Dependencies**:

   ```bash
   pip install -r requirements.txt
   ```

## Running the Application

### Start the Julia Server

1. **Run the Genie Server**:

   In the project root directory, start the server:

   ```bash
   julia genie.jl
   ```

   The server will start and listen on `http://localhost:8080`.

2. **Process a Video**:

   Use `curl` or a similar tool to send a POST request to the server:

   ```bash
   curl -X POST http://localhost:8080/process_video -H "Content-Type: application/json" -d '{"video_path": "inputs/eye.mp4"}'
   ```

   The processed video will be saved to `outputs/output_video.mp4`.

## Accessing the Jupyter Notebook

1. **Start Jupyter Notebook**:

   Ensure your Python virtual environment is activated, then start Jupyter:

   ```bash
   jupyter notebook
   ```

2. **Open the Notebook**:

   Navigate to the `notebooks` directory and open the relevant notebook file to explore data analysis and visualization.

## Starting the Streamlit App

1. **Run the Streamlit App**:

   With the virtual environment activated, start the Streamlit app:

   ```bash
   streamlit run app.py
   ```

   Access the app in your browser at `http://localhost:8501`.

## Project Structure

- **`src/`**: Contains the Julia source code for video processing and ABM logic.
- **`inputs/`**: Directory for input video files.
- **`outputs/`**: Directory for processed video files.
- **`notebooks/`**: Jupyter notebooks for data analysis and visualization.
- **`venv/`**: Python virtual environment directory.
- **`video-compiler.py`**: Python script for compiling processed frames into a video.

## Conclusion

This project demonstrates the integration of Julia and Python for advanced video processing using agent-based modeling. The combination of Genie for server-side operations and OpenCV for video manipulation provides a powerful framework for creating dynamic visual effects.

For further details, refer to the project report and documentation within the repository.
