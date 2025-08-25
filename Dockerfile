# Use an official R image as a parent image
FROM r-base:4.2.0

# Install system dependencies required for R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    cargo \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the R scripts and data into the container
COPY . .

# Run the setup script to install all R packages
# We run this during the build process so the container is ready to go.
RUN R -e "source('R/setup.R')"

# The command to run when the container starts
# This will run the entire analysis from start to finish.
CMD ["R", "-e", "source('full_analysis_runner.R')"]
