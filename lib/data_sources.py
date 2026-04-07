#!/usr/bin/env python3
"""
Data source abstraction layer for watershed mapping project
"""
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
import os
import logging
from pathlib import Path
import requests
import shutil

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DataSource(ABC):
    """Abstract base class for data sources"""
    
    def __init__(self, name: str):
        self.name = name
        self.logger = logging.getLogger(f"{__name__}.{self.__class__.__name__}")
    
    @abstractmethod
    def acquire(self, config: Dict[str, Any], target_path: str) -> bool:
        """Download and prepare data from source"""
        pass
    
    @abstractmethod
    def validate(self, path: str) -> bool:
        """Validate downloaded data"""
        pass


class DEMSource(DataSource):
    """Data source for Digital Elevation Models"""
    
    def __init__(self):
        super().__init__("DEM")
    
    def acquire(self, config: Dict[str, Any], target_path: str) -> bool:
        """Acquire DEM data based on configuration"""
        try:
            dem_config = config.get('data_sources', {}).get('dem', {})
            source_type = dem_config.get('source', 'file')
            
            # Create target directory if it doesn't exist
            Path(target_path).mkdir(parents=True, exist_ok=True)
            
            if source_type == 'url':
                return self._acquire_from_url(dem_config, target_path)
            elif source_type == 'file':
                return self._acquire_from_file(dem_config, target_path)
            elif source_type == 'test_data':
                return self._acquire_test_data(dem_config, target_path)
            else:
                self.logger.error(f"Unknown DEM source type: {source_type}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error acquiring DEM data: {e}")
            return False
    
    def _acquire_from_url(self, dem_config: Dict[str, Any], target_path: str) -> bool:
        """Download DEM from URL"""
        url = dem_config.get('url')
        filename = dem_config.get('filename', 'dem.tif')
        
        if not url:
            self.logger.error("No URL provided for DEM source")
            return False
            
        target_file = os.path.join(target_path, filename)
        
        # Check if file already exists
        if os.path.exists(target_file):
            self.logger.info(f"DEM file already exists: {target_file}")
            return True
            
        self.logger.info(f"Downloading DEM from {url} to {target_file}")
        
        try:
            response = requests.get(url, stream=True, timeout=300)
            response.raise_for_status()
            
            with open(target_file, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
                    
            self.logger.info(f"DEM downloaded successfully to {target_file}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to download DEM: {e}")
            return False
    
    def _acquire_from_file(self, dem_config: Dict[str, Any], target_path: str) -> bool:
        """Copy DEM from local file path"""
        source_path = dem_config.get('path')
        filename = dem_config.get('filename', 'dem.tif')
        
        if not source_path or not os.path.exists(source_path):
            self.logger.error(f"DEM source file not found: {source_path}")
            return False
            
        target_file = os.path.join(target_path, filename)
        
        # Check if file already exists
        if os.path.exists(target_file):
            self.logger.info(f"DEM file already exists: {target_file}")
            return True
            
        try:
            shutil.copy2(source_path, target_file)
            self.logger.info(f"DEM copied from {source_path} to {target_file}")
            return True
        except Exception as e:
            self.logger.error(f"Failed to copy DEM: {e}")
            return False
    
    def _acquire_test_data(self, dem_config: Dict[str, Any], target_path: str) -> bool:
        """Create or copy test DEM data"""
        source_path = dem_config.get('path')
        filename = dem_config.get('filename', 'test_dem.tif')
        
        target_file = os.path.join(target_path, filename)
        
        # Check if file already exists
        if os.path.exists(target_file):
            self.logger.info(f"Test DEM file already exists: {target_file}")
            return True
            
        # If we have a source path, copy it
        if source_path and os.path.exists(source_path):
            try:
                shutil.copy2(source_path, target_file)
                self.logger.info(f"Test DEM copied from {source_path} to {target_file}")
                return True
            except Exception as e:
                self.logger.error(f"Failed to copy test DEM: {e}")
                return False
        else:
            # Create a minimal test DEM file
            self.logger.info(f"Creating minimal test DEM file: {target_file}")
            # In a real implementation, we would create a proper test DEM here
            # For now, we'll just create an empty file
            try:
                Path(target_file).touch()
                self.logger.info(f"Created empty test DEM file: {target_file}")
                return True
            except Exception as e:
                self.logger.error(f"Failed to create test DEM: {e}")
                return False
    
    def validate(self, path: str) -> bool:
        """Validate DEM data file"""
        if not os.path.exists(path):
            self.logger.error(f"DEM file does not exist: {path}")
            return False
            
        # Check file size (should be substantial for DEM data)
        file_size = os.path.getsize(path)
        if file_size < 1024:  # Minimum 1KB
            self.logger.warning(f"DEM file appears small ({file_size} bytes): {path}")
            
        # In a real implementation, we would use GDAL to validate the file format
        # For now, we'll just check if it's a readable file
        try:
            with open(path, 'rb') as f:
                f.read(1024)  # Try to read first 1KB
            return True
        except Exception as e:
            self.logger.error(f"DEM file validation failed: {e}")
            return False


class OSMSource(DataSource):
    """Data source for OpenStreetMap data"""
    
    def __init__(self):
        super().__init__("OSM")
    
    def acquire(self, config: Dict[str, Any], target_path: str) -> bool:
        """Acquire OSM data based on configuration"""
        try:
            osm_config = config.get('data_sources', {}).get('osm', {})
            url = osm_config.get('url')
            filename = osm_config.get('filename', 'data.osm.pbf')
            
            if not url:
                self.logger.error("No URL provided for OSM source")
                return False
                
            # Create target directory if it doesn't exist
            Path(target_path).mkdir(parents=True, exist_ok=True)
            
            target_file = os.path.join(target_path, filename)
            
            # Check if file already exists
            if os.path.exists(target_file):
                self.logger.info(f"OSM file already exists: {target_file}")
                return True
                
            self.logger.info(f"Downloading OSM data from {url} to {target_file}")
            
            try:
                response = requests.get(url, stream=True, timeout=300)
                response.raise_for_status()
                
                with open(target_file, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)
                        
                self.logger.info(f"OSM data downloaded successfully to {target_file}")
                return True
                
            except Exception as e:
                self.logger.error(f"Failed to download OSM data: {e}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error acquiring OSM data: {e}")
            return False
    
    def validate(self, path: str) -> bool:
        """Validate OSM data file"""
        if not os.path.exists(path):
            self.logger.error(f"OSM file does not exist: {path}")
            return False
            
        # Check file extension
        if not path.endswith(('.osm.pbf', '.osm', '.xml')):
            self.logger.warning(f"OSM file has unexpected extension: {path}")
            
        # Check file size
        file_size = os.path.getsize(path)
        if file_size < 1024:  # Minimum 1KB
            self.logger.warning(f"OSM file appears small ({file_size} bytes): {path}")
            
        # In a real implementation, we would validate the OSM format
        # For now, we'll just check if it's a readable file
        try:
            with open(path, 'rb') as f:
                f.read(1024)  # Try to read first 1KB
            return True
        except Exception as e:
            self.logger.error(f"OSM file validation failed: {e}")
            return False


def create_data_source(source_type: str) -> Optional[DataSource]:
    """Factory function to create data sources"""
    sources = {
        'dem': DEMSource,
        'osm': OSMSource
    }
    
    source_class = sources.get(source_type.lower())
    if source_class:
        return source_class()
    else:
        logger.error(f"Unknown data source type: {source_type}")
        return None


# Example usage
if __name__ == '__main__':
    # This would typically be called from a script that loads the configuration
    import sys
    from lib.config import load_config
    
    if len(sys.argv) > 1:
        config_path = sys.argv[1]
    else:
        config_path = 'config/default.yaml'
        
    try:
        config = load_config(config_path)
        
        # Create and use DEM source
        dem_source = DEMSource()
        raw_data_path = config.get('paths', {}).get('raw_data', 'data/raw')
        success = dem_source.acquire(config, raw_data_path)
        
        if success:
            print("DEM data acquisition successful")
        else:
            print("DEM data acquisition failed")
            
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)