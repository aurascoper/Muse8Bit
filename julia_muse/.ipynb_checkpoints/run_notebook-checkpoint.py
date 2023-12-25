import os
import subprocess

# Activate the eeg-env environment
activate_command = "source activate eeg-env"  # For Linux or macOS
# or
# activate_command = "activate eeg-env"  # For Windows

# Start Jupyter Notebook
notebook_command = "jupyter notebook"

# Run commands
os.system(activate_command)
os.system(notebook_command)
