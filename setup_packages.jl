using Pkg

# List of required packages
required_packages = [
    "CSV",
    "DataFrames",
    "VideoIO",
    "Images",
    "Logging",
    "Agents",
    "ProgressMeter",
    "FileIO"
]

# Function to ensure all packages are installed and loaded
function ensure_packages_installed(packages)
    for package in packages
        try
            @eval using $(Symbol(package))
        catch
            println("Installing $package...")
            Pkg.add(package)
            @eval using $(Symbol(package))
        end
    end
    println("All required packages are installed and loaded successfully!")
end

# Call the function
ensure_packages_installed(required_packages)