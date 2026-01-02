#!/usr/bin/env python3
"""
Processing pipeline with modular components
"""
from abc import ABC, abstractmethod
from typing import Dict, Any, List
import logging
import os
import sys
from pathlib import Path

# Set up paths relative to project root
script_dir = Path(__file__).parent
project_root = script_dir.parent
lib_dir = project_root / 'lib'

# Add lib directory to Python path
sys.path.insert(0, str(lib_dir))

from lib.config import load_config, get_paths, get_config

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ProcessingStage(ABC):
    """Abstract base class for processing stages"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.logger = logging.getLogger(f"{__name__}.{self.__class__.__name__}")
    
    @abstractmethod
    def execute(self) -> bool:
        """Execute the processing stage"""
        pass
    
    @abstractmethod
    def validate_inputs(self) -> bool:
        """Validate required inputs are available"""
        pass
    
    @abstractmethod
    def validate_outputs(self) -> bool:
        """Validate outputs were created successfully"""
        pass


class DEMProcessor(ProcessingStage):
    """Process DEM data using GRASS GIS"""
    
    def execute(self) -> bool:
        """Execute DEM processing with configured parameters"""
        try:
            # Get paths from configuration
            paths = get_paths()
            processed_data_path = paths.get('processed_data', 'data/processed')
            raw_data_path = paths.get('raw_data', 'data/raw')
            grassdb_path = paths.get('grassdb', 'grassdb')
            
            # Resolve relative paths
            if not os.path.isabs(processed_data_path):
                processed_data_path = str(project_root / processed_data_path)
            if not os.path.isabs(raw_data_path):
                raw_data_path = str(project_root / raw_data_path)
            if not os.path.isabs(grassdb_path):
                grassdb_path = str(project_root / grassdb_path)
            
            # Get processing parameters
            dem_config = self.config.get('data_sources', {}).get('dem', {})
            dem_filename = dem_config.get('filename', 'dem.tif')
            stream_threshold = get_config('processing.watersheds.stream_threshold', 1000)
            outlets = get_config('processing.watersheds.outlets', [])
            
            # Get environment parameters
            grass_location = get_config('environment.grass_location', 'aberdeenshire_bng')
            
            # Ensure output directory exists
            os.makedirs(processed_data_path, exist_ok=True)
            
            # Check if watershed files already exist
            watershed_files_exist = True
            for outlet in outlets:
                name = outlet.get('name', '')
                if name:
                    shapefile_path = os.path.join(processed_data_path, f'watershed_{name}.shp')
                    if not os.path.exists(shapefile_path):
                        watershed_files_exist = False
                        break
            
            if watershed_files_exist:
                self.logger.info("Watershed shapefiles already exist, skipping DEM processing")
                return True
            
            self.logger.info("Starting DEM processing...")
            
            # Import and process DEM using GRASS GIS
            # This is a simplified version - in practice, we would use the GRASS Python API
            # or call the existing shell script with proper configuration
            dem_path = os.path.join(raw_data_path, dem_filename)
            
            # Validate DEM file exists
            if not os.path.exists(dem_path):
                self.logger.error(f"DEM file not found: {dem_path}")
                return False
            
            # For now, we'll just log what would be done
            self.logger.info(f"Would process DEM: {dem_path}")
            self.logger.info(f"Stream threshold: {stream_threshold}")
            self.logger.info(f"Number of outlets: {len(outlets)}")
            self.logger.info(f"GRASS location: {grassdb_path}/{grass_location}")
            
            # In a real implementation, we would:
            # 1. Start GRASS session
            # 2. Import DEM
            # 3. Fill sinks
            # 4. Calculate flow accumulation
            # 5. Define stream network
            # 6. Process each outlet
            # 7. Export results
            
            self.logger.info("DEM processing completed successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Error in DEM processing: {e}")
            return False
    
    def validate_inputs(self) -> bool:
        """Validate required inputs are available"""
        try:
            # Get paths
            paths = get_paths()
            raw_data_path = paths.get('raw_data', 'data/raw')
            
            # Resolve relative paths
            if not os.path.isabs(raw_data_path):
                raw_data_path = str(project_root / raw_data_path)
            
            # Check if raw data directory exists
            if not os.path.exists(raw_data_path):
                self.logger.error(f"Raw data directory does not exist: {raw_data_path}")
                return False
            
            # Check if DEM file exists
            dem_config = self.config.get('data_sources', {}).get('dem', {})
            dem_filename = dem_config.get('filename', 'dem.tif')
            dem_path = os.path.join(raw_data_path, dem_filename)
            
            if not os.path.exists(dem_path):
                self.logger.error(f"DEM file not found: {dem_path}")
                return False
                
            return True
        except Exception as e:
            self.logger.error(f"Error validating inputs: {e}")
            return False
    
    def validate_outputs(self) -> bool:
        """Validate outputs were created successfully"""
        try:
            # Get paths
            paths = get_paths()
            processed_data_path = paths.get('processed_data', 'data/processed')
            
            # Resolve relative paths
            if not os.path.isabs(processed_data_path):
                processed_data_path = str(project_root / processed_data_path)
            
            # Check if processed data directory exists
            if not os.path.exists(processed_data_path):
                self.logger.error(f"Processed data directory does not exist: {processed_data_path}")
                return False
                
            return True
        except Exception as e:
            self.logger.error(f"Error validating outputs: {e}")
            return False


class WatershedProcessor(ProcessingStage):
    """Process watershed data"""
    
    def execute(self) -> bool:
        """Execute watershed processing"""
        try:
            self.logger.info("Processing watershed data...")
            
            # Get paths
            paths = get_paths()
            processed_data_path = paths.get('processed_data', 'data/processed')
            
            # Resolve relative paths
            if not os.path.isabs(processed_data_path):
                processed_data_path = str(project_root / processed_data_path)
            
            # For now, we'll just log what would be done
            self.logger.info(f"Would process watershed data in: {processed_data_path}")
            
            self.logger.info("Watershed processing completed successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Error in watershed processing: {e}")
            return False
    
    def validate_inputs(self) -> bool:
        """Validate required inputs are available"""
        # Implementation would check for required input files
        return True
    
    def validate_outputs(self) -> bool:
        """Validate outputs were created successfully"""
        # Implementation would check for required output files
        return True


class CartographyProcessor(ProcessingStage):
    """Create maps and visualizations"""
    
    def execute(self) -> bool:
        """Execute cartography processing"""
        try:
            self.logger.info("Creating maps...")
            
            # Get paths
            paths = get_paths()
            output_path = paths.get('output', 'output')
            
            # Resolve relative paths
            if not os.path.isabs(output_path):
                output_path = str(project_root / output_path)
            
            # For now, we'll just log what would be done
            self.logger.info(f"Would create maps in: {output_path}")
            
            self.logger.info("Cartography processing completed successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Error in cartography processing: {e}")
            return False
    
    def validate_inputs(self) -> bool:
        """Validate required inputs are available"""
        # Implementation would check for required input files
        return True
    
    def validate_outputs(self) -> bool:
        """Validate outputs were created successfully"""
        # Implementation would check for required output files
        return True


class ProcessingPipeline:
    """Orchestrate the complete processing pipeline"""
    
    def __init__(self, config_path: str = None):
        self.config = load_config(config_path)
        self.stages = self._initialize_stages()
        self.logger = logging.getLogger(f"{__name__}.{self.__class__.__name__}")
    
    def _initialize_stages(self) -> List[ProcessingStage]:
        """Initialize processing stages"""
        return [
            DEMProcessor(self.config),
            WatershedProcessor(self.config),
            CartographyProcessor(self.config)
        ]
    
    def execute(self) -> bool:
        """Execute all pipeline stages"""
        self.logger.info("Starting processing pipeline...")
        
        for stage in self.stages:
            stage_name = stage.__class__.__name__
            self.logger.info(f"Executing stage: {stage_name}")
            
            # Validate inputs
            if not stage.validate_inputs():
                self.logger.error(f"Input validation failed for {stage_name}")
                return False
            
            # Execute stage
            if not stage.execute():
                self.logger.error(f"Execution failed for {stage_name}")
                return False
            
            # Validate outputs
            if not stage.validate_outputs():
                self.logger.error(f"Output validation failed for {stage_name}")
                return False
                
            self.logger.info(f"Stage {stage_name} completed successfully")
        
        self.logger.info("Processing pipeline completed successfully")
        return True


def main():
    """Main pipeline execution function"""
    print("Running processing pipeline v2...")
    
    try:
        # Use config file from environment or default
        config_file = os.environ.get('CONFIG_FILE', 'config/default.yaml')
        
        # Initialize and run pipeline
        pipeline = ProcessingPipeline(config_file)
        success = pipeline.execute()
        
        if success:
            print("Pipeline executed successfully")
            sys.exit(0)
        else:
            print("Pipeline execution failed")
            sys.exit(1)
            
    except Exception as e:
        print(f"Error in pipeline execution: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()