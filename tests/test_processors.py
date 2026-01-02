#!/usr/bin/env python3
"""
Unit tests for processing components
"""
import unittest
import tempfile
import shutil
import os
import sys
from pathlib import Path

# Add project root to path for imports
project_root = Path(__file__).parent.parent
lib_dir = project_root / 'lib'
sys.path.insert(0, str(lib_dir))

from lib.config import load_config
from scripts.pipeline_v2 import DEMProcessor, WatershedProcessor, CartographyProcessor


class TestProcessors(unittest.TestCase):
    """Test the processing components"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.test_dir = tempfile.mkdtemp()
        self.config = load_config('config/test.yaml')
        # Update config paths for testing
        self.config['paths']['data_dir'] = self.test_dir
        self.config['paths']['raw_data'] = os.path.join(self.test_dir, 'raw')
        self.config['paths']['processed_data'] = os.path.join(self.test_dir, 'processed')
        self.config['paths']['output'] = os.path.join(self.test_dir, 'output')
        
    def tearDown(self):
        """Clean up test fixtures"""
        shutil.rmtree(self.test_dir)
    
    def test_dem_processor_initialization(self):
        """Test DEM processor initialization"""
        processor = DEMProcessor(self.config)
        self.assertIsNotNone(processor)
        self.assertEqual(processor.config, self.config)
    
    def test_dem_processor_input_validation(self):
        """Test DEM processor input validation"""
        processor = DEMProcessor(self.config)
        
        # Should fail initially because directories don't exist
        self.assertFalse(processor.validate_inputs())
        
        # Create required directories and files
        raw_data_path = self.config['paths']['raw_data']
        os.makedirs(raw_data_path, exist_ok=True)
        
        # Create a test DEM file
        dem_config = self.config.get('data_sources', {}).get('dem', {})
        dem_filename = dem_config.get('filename', 'test_dem.tif')
        test_dem_path = os.path.join(raw_data_path, dem_filename)
        Path(test_dem_path).touch()
        
        # Should now pass validation
        self.assertTrue(processor.validate_inputs())
    
    def test_dem_processor_output_validation(self):
        """Test DEM processor output validation"""
        processor = DEMProcessor(self.config)
        
        # Should fail initially because directory doesn't exist
        self.assertFalse(processor.validate_outputs())
        
        # Create required directory
        processed_data_path = self.config['paths']['processed_data']
        os.makedirs(processed_data_path, exist_ok=True)
        
        # Should now pass validation
        self.assertTrue(processor.validate_outputs())
    
    def test_watershed_processor(self):
        """Test watershed processor"""
        processor = WatershedProcessor(self.config)
        
        # These are placeholder tests since the actual implementation
        # would require more complex setup
        self.assertIsNotNone(processor)
        self.assertTrue(processor.validate_inputs())
        self.assertTrue(processor.validate_outputs())
    
    def test_cartography_processor(self):
        """Test cartography processor"""
        processor = CartographyProcessor(self.config)
        
        # These are placeholder tests since the actual implementation
        # would require more complex setup
        self.assertIsNotNone(processor)
        self.assertTrue(processor.validate_inputs())
        self.assertTrue(processor.validate_outputs())


if __name__ == '__main__':
    unittest.main()