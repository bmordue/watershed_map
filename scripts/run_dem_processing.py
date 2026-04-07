#!/usr/bin/env python3
"""
Entry point script for running the DEM processing workflow.
"""

import os
import sys

# Add lib directory to Python path to allow for module imports
# This is necessary because the script is in a subdirectory
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(project_root)

from lib.config import ConfigLoader
from lib.dem_processing import DEMProcessor

def main():
    """
    Main function to run the DEM processing.
    """
    # The config file path can be passed as a command-line argument
    config_path = None
    if len(sys.argv) > 1:
        config_path = sys.argv[1]
    else:
        # Default to config/default.yaml if no path is provided
        config_path = os.path.join(project_root, 'config', 'default.yaml')


    try:
        # Load configuration
        print(f"Loading configuration from: {config_path}")
        config_loader = ConfigLoader(config_path=config_path)
        config_loader.load()
        config_loader.validate()
        print("Configuration loaded and validated successfully.")

        # Initialize and run the DEM processor
        processor = DEMProcessor(config_loader)
        processor.run_processing()

    except (FileNotFoundError, ValueError) as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
