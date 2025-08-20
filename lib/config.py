#!/usr/bin/env python3
"""
Configuration loading utilities for watershed mapping scripts
"""

import yaml
import os
import sys
from typing import Dict, Any, Optional
from pathlib import Path


class ConfigLoader:
    """Load and manage configuration for watershed mapping"""
    
    def __init__(self, config_path: Optional[str] = None):
        self.config_path = config_path or os.environ.get('CONFIG_FILE', 'config/default.yaml')
        self.config = None
        
    def load(self) -> Dict[str, Any]:
        """Load configuration from YAML file"""
        config_file = Path(self.config_path)
        
        if not config_file.exists():
            raise FileNotFoundError(f"Configuration file '{self.config_path}' not found")
            
        try:
            with open(config_file, 'r') as f:
                self.config = yaml.safe_load(f)
        except yaml.YAMLError as e:
            raise ValueError(f"Error parsing configuration file: {e}")
            
        # Expand path variables
        self._expand_path_variables()
        
        return self.config
    
    def _expand_path_variables(self):
        """Expand variables like ${data_dir} in path values"""
        if 'paths' not in self.config:
            return
            
        paths = self.config['paths']
        
        # Multiple passes to handle nested variable expansion
        for _ in range(3):  # Max 3 levels of nesting
            for key, value in paths.items():
                if isinstance(value, str) and '${' in value:
                    for var_name, var_value in paths.items():
                        if isinstance(var_value, str) and '${' not in var_value:
                            value = value.replace(f'${{{var_name}}}', var_value)
                    paths[key] = value
    
    def get(self, key_path: str, default=None):
        """Get configuration value using dot notation (e.g., 'processing.watersheds.stream_threshold')"""
        if self.config is None:
            self.load()
            
        keys = key_path.split('.')
        value = self.config
        
        try:
            for key in keys:
                value = value[key]
            return value
        except (KeyError, TypeError):
            return default
    
    def get_paths(self) -> Dict[str, str]:
        """Get all configured paths"""
        return self.get('paths', {})
    
    def get_processing_config(self) -> Dict[str, Any]:
        """Get processing configuration"""
        return self.get('processing', {})
    
    def get_data_sources_config(self) -> Dict[str, Any]:
        """Get data sources configuration"""
        return self.get('data_sources', {})
    
    def get_project_config(self) -> Dict[str, Any]:
        """Get project configuration"""
        return self.get('project', {})
    
    def validate(self) -> bool:
        """Validate configuration has required sections"""
        if self.config is None:
            self.load()
            
        required_sections = ['project', 'data_sources', 'processing', 'paths', 'environment']
        
        for section in required_sections:
            if section not in self.config:
                raise ValueError(f"Required configuration section '{section}' missing")
                
        return True


# Global configuration loader instance
_config_loader = None

def load_config(config_path: Optional[str] = None) -> Dict[str, Any]:
    """Load configuration (convenience function)"""
    global _config_loader
    if _config_loader is None or config_path is not None:
        _config_loader = ConfigLoader(config_path)
    return _config_loader.load()

def get_config(key_path: str, default=None):
    """Get configuration value (convenience function)"""
    global _config_loader
    if _config_loader is None:
        _config_loader = ConfigLoader()
    return _config_loader.get(key_path, default)

def get_paths() -> Dict[str, str]:
    """Get configured paths (convenience function)"""
    global _config_loader
    if _config_loader is None:
        _config_loader = ConfigLoader()
    return _config_loader.get_paths()


if __name__ == '__main__':
    # Command line usage for testing
    if len(sys.argv) > 1:
        config_path = sys.argv[1]
    else:
        config_path = None
        
    try:
        config = load_config(config_path)
        print("Configuration loaded successfully:")
        print(yaml.dump(config, default_flow_style=False))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)