#!/bin/bash
# Configuration loader library for watershed mapping scripts

load_config() {
    # Use provided config file or default
    CONFIG_FILE="${CONFIG_FILE:-config/default.yaml}"
    
    # If config file doesn't exist, try to find it relative to repo root
    if [ ! -f "$CONFIG_FILE" ]; then
        # Try from current directory
        if [ -f "../$CONFIG_FILE" ]; then
            CONFIG_FILE="../$CONFIG_FILE"
        # Try from scripts directory perspective
        elif [ -f "../../$CONFIG_FILE" ]; then
            CONFIG_FILE="../../$CONFIG_FILE"
        else
            echo "Error: Configuration file '$CONFIG_FILE' not found" >&2
            echo "Searched in: $PWD/$CONFIG_FILE, $PWD/../$CONFIG_FILE, $PWD/../../$CONFIG_FILE" >&2
            return 1
        fi
    fi
    
    # Check if Python with yaml is available
    if ! python3 -c "import yaml" >/dev/null 2>&1; then
        echo "Error: Python3 with PyYAML is required for configuration loading" >&2
        return 1
    fi
    
    # Parse YAML and export as environment variables
    eval $(python3 -c "
import yaml
import os
import sys
import json

try:
    with open('$CONFIG_FILE', 'r') as f:
        config = yaml.safe_load(f)
    
    def expand_variables(value, context):
        if isinstance(value, str) and '\${' in value:
            for key, val in context.items():
                if isinstance(val, str):
                    value = value.replace(f'\${{{key}}}', val)
        return value
    
    def flatten_dict(d, parent_key='CONFIG', sep='_'):
        items = []
        for k, v in d.items():
            new_key = f'{parent_key}{sep}{k.upper()}' if parent_key else k.upper()
            if isinstance(v, dict):
                items.extend(flatten_dict(v, new_key, sep=sep).items())
            elif isinstance(v, list):
                # Handle lists by converting to JSON
                items.append((new_key, json.dumps(v)))
            else:
                items.append((new_key, str(v)))
        return dict(items)
    
    # First pass: flatten the config
    flat_config = flatten_dict(config)
    
    # Second pass: expand variables (simple expansion for paths)
    paths = {}
    if 'paths' in config:
        paths = config['paths']
    
    for key, value in flat_config.items():
        if 'PATHS' in key and isinstance(value, str):
            value = expand_variables(value, paths)
            flat_config[key] = value
    
    # Export as environment variables
    for key, value in flat_config.items():
        # Escape special characters for shell
        escaped_value = str(value).replace('\"', '\\\\\"').replace('\$', '\\\\\$')
        print(f'export {key}=\"{escaped_value}\"')
        
except Exception as e:
    print(f'echo \"Error loading configuration: {e}\" >&2', file=sys.stderr)
    sys.exit(1)
")
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to parse configuration file" >&2
        return 1
    fi
    
    echo "Configuration loaded from $CONFIG_FILE" >&2
}

# Function to get a specific config value
get_config_value() {
    local key="$1"
    local config_file="${CONFIG_FILE:-config/default.yaml}"
    
    python3 -c "
import yaml
import sys

try:
    with open('$config_file', 'r') as f:
        config = yaml.safe_load(f)
    
    # Navigate nested keys (e.g., 'processing.watersheds.stream_threshold')
    keys = '$key'.split('.')
    value = config
    for k in keys:
        value = value[k]
    
    print(value)
except Exception as e:
    sys.exit(1)
"
}

# Function to validate configuration
validate_config() {
    local config_file="${CONFIG_FILE:-config/default.yaml}"
    
    echo "Validating configuration file: $config_file" >&2
    
    # Check required sections exist
    local required_sections="project data_sources processing paths environment"
    
    for section in $required_sections; do
        if ! get_config_value "$section" >/dev/null 2>&1; then
            echo "Error: Required configuration section '$section' missing" >&2
            return 1
        fi
    done
    
    echo "Configuration validation passed" >&2
    return 0
}