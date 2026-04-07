#!/usr/bin/env python3
"""
Acquire data using the data source abstraction layer
"""
import sys
import os
from pathlib import Path

# Set up paths relative to project root
script_dir = Path(__file__).parent
project_root = script_dir.parent
lib_dir = project_root / 'lib'
config_dir = project_root / 'config'

# Add lib directory to Python path
sys.path.insert(0, str(lib_dir))

# Set default config path relative to project root
default_config_path = str(config_dir / 'default.yaml')
os.environ.setdefault('CONFIG_FILE', default_config_path)

from lib.config import load_config, get_paths
from lib.data_sources import DEMSource, OSMSource


def main():
    """Main data acquisition function using configuration"""
    print("Running acquire_data_v2.py")
    
    try:
        # Load configuration
        config = load_config()
        paths = get_paths()
        
        # Get configured paths with fallbacks - resolve relative to project root
        raw_data_path = paths.get('raw_data', 'data/raw')
        if not os.path.isabs(raw_data_path):
            raw_data_path = str(project_root / raw_data_path)
        
        print("Data Acquisition Configuration:")
        print(f"  Project root: {project_root}")
        print(f"  Raw data path: {raw_data_path}")
        
        # Ensure output directory exists
        os.makedirs(raw_data_path, exist_ok=True)
        
        # Create data sources
        sources = {
            'dem': DEMSource(),
            'osm': OSMSource()
        }
        
        # Acquire data from each source
        for source_name, source in sources.items():
            print(f"\nAcquiring {source_name} data...")
            if source.acquire(config, raw_data_path):
                print(f"✓ {source_name} data acquired successfully")
            else:
                print(f"✗ Failed to acquire {source_name} data")
                
        print("\nData acquisition completed")
        
    except Exception as e:
        print(f"Error in data acquisition: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()