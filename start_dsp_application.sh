#!/bin/bash

# Start the Julia DSP application
julia /app/dsp_application.jl &

# Start the Go application
/app/dsp_application &

# Keep the script running
wait
