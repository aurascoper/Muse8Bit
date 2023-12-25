# Using a Debian base image
FROM debian:bookworm-slim

# Installing necessary tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    g++ \
    gcc \
    git \
    libc6-dev \
    make \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    gdb \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Creating a Python virtual environment and activate it
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Installing Python packages
RUN pip install --default-timeout=777 numpy scipy matplotlib jupyter
RUN protoc --ccp_out=. Muse_V2.proto

# Set environment variables for Julia
ENV JULIA_PATH /usr/local/julia
ENV PATH $JULIA_PATH/bin:$PATH

# Julia installation
ENV JULIA_VERSION 1.10.0-rc3
RUN curl -sSL "https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | tar -xz -C /usr/local --strip-components 1

RUN apt-get update && apt-get install -y --no-install-recommends \
    protobuf-compiler

# Compile Muse.proto file for C++
RUN protoc --cpp_out=. Muse_v2.proto
RUN apt-get install -y --no-install-recommends \

# Install Julia packages
RUN julia -e using Pkg; Pkg.add(["DSP", "FFTW", "FileTypes", "OpenSoundControl", "BlueZ_jll", "RxInfer", "Evolutionary,"])

# Set environment variables for Go
ENV GOLANG_VERSION 1.18
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Go installation
RUN curl -sSL "https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local

# Install Go package for Python interaction
RUN go install github.com/go-python/gopy@latest

# Set up working directory
WORKDIR /app

# Clone necessary GitHub repositories
## Clone necessary GitHub repositories

RUN git clone https://github.com/crgimenes/go-osc.git /app/go-osc
RUN git clone https://github.com/stanfordnlp/dspy.git /app/dspy
RUN git clone https://github.com/tsunrise/dsp.git /app/tsunrise_dsp
RUN git clone https://github.com/Enigma644/OSCMonitor.git /app/OSCMonitor
RUN git clone https://github.com/amisepa/import_muse.git /app/import_muse
RUN git clone https://github.com/sccn/eeglab_musemonitor_plugin.git /app/eeglab_musemonitor_plugin
RUN git clone https://github.com/kaczmarj/rteeg.git /app/rteeg
RUN git clone https://github.com/giordano/julia-on-ookami.git /app/julia-on-ookami
RUN git clone https://github.com/wildart/Evolutionary.jl.git
RUN git clone https://github.com/JuliaIO/FileTypes.jl.git /app/FileTypes.jl
RUN git clone https://github.com/vipsimage/vips.git /app/vips
RUN git clone https://github.com/openbci-archive/OpenBCI_8bit.git /app/OpenBCI_8bit
RUN git clone https://github.com/rob-luke/Neuroimaging.jl.git /app/Neuroimaging.jl
RUN git clone https://github.com/simonster/Synchrony.jl.git /app/Synchrony.jl
RUN git clone https://github.com/grpc/grpc-go.git /app/grpc-go
# Add a script for handling git clone with retries
# ... (retry-git-clone.sh related commands as before)
# Add a script for handling git clone with retries
COPY retry-git-clone.sh /usr/local/bin/retry-git-clone.sh
RUN chmod +x /usr/local/bin/retry-git-clone.sh

# Retry the git clone commands using the script
RUN retry-git-clone.sh https://github.com/NiubilityDiu/BayesInferenceEEGBCI.git /app/BayesInferenceEEGBCI
# ... (add other retry-git-clone commands as needed)

# Copy Go application source
COPY muse_dsp/ /app/go-app

# Set working directory for Go application
WORKDIR /app/go-app

# Build your Go application
RUN go build -o myapp .



#Install Delve for Go Debugging

RUN go install github.com/go-delve/delve/cmd/dlv@latest
EXPOSE 2345
# Set up working directory for Julia application
WORKDIR /app/julia_muse

# Copy Julia application source
COPY julia_muse/ /app/julia_muse

# Set script as entrypoint
ENTRYPOINT ["dlv", "debug", "/app/dsp_application.go", "--headless", "--listen2345", "--api-version=2", "--log"] && ["/app/start_dsp_application.sh"]

