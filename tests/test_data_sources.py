#!/usr/bin/env python3
"""
Unit tests for data sources and processors
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

from lib.data_sources import DEMSource, OSMSource
from lib.config import load_config


class TestDEMSource(unittest.TestCase):
    """Test the DEM data source"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.test_dir = tempfile.mkdtemp()
        self.config = load_config('config/test.yaml')
        # Update config paths for testing
        self.config['paths']['data_dir'] = self.test_dir
        self.config['paths']['raw_data'] = os.path.join(self.test_dir, 'raw')
        
    def tearDown(self):
        """Clean up test fixtures"""
        shutil.rmtree(self.test_dir)
    
    def test_dem_source_initialization(self):
        """Test DEM source initialization"""
        source = DEMSource()
        self.assertEqual(source.name, "DEM")
    
    def test_dem_source_validation(self):
        """Test DEM source validation"""
        source = DEMSource()
        
        # Test validation of non-existent file
        self.assertFalse(source.validate("/non/existent/file.tif"))
        
        # Test validation of existing file
        test_file = os.path.join(self.test_dir, "test_dem.tif")
        Path(test_file).touch()  # Create empty file
        self.assertTrue(source.validate(test_file))
    
    def test_dem_source_acquire_test_data(self):
        """Test acquiring test DEM data"""
        source = DEMSource()
        raw_data_path = self.config['paths']['raw_data']
        
        # Test acquiring test data
        success = source.acquire(self.config, raw_data_path)
        self.assertTrue(success)
        
        # Check that file was created
        expected_file = os.path.join(raw_data_path, "test_dem.tif")
        self.assertTrue(os.path.exists(expected_file))


class TestOSMSource(unittest.TestCase):
    """Test the OSM data source"""
    
    def setUp(self):
        """Set up test fixtures"""
        self.test_dir = tempfile.mkdtemp()
        self.config = load_config('config/test.yaml')
        # Update config paths for testing
        self.config['paths']['data_dir'] = self.test_dir
        self.config['paths']['raw_data'] = os.path.join(self.test_dir, 'raw')
        
    def tearDown(self):
        """Clean up test fixtures"""
        shutil.rmtree(self.test_dir)
    
    def test_osm_source_initialization(self):
        """Test OSM source initialization"""
        source = OSMSource()
        self.assertEqual(source.name, "OSM")
    
    def test_osm_source_validation(self):
        """Test OSM source validation"""
        source = OSMSource()
        
        # Test validation of non-existent file
        self.assertFalse(source.validate("/non/existent/file.osm.pbf"))
        
        # Test validation of existing file
        test_file = os.path.join(self.test_dir, "test_data.osm.pbf")
        Path(test_file).touch()  # Create empty file
        self.assertTrue(source.validate(test_file))


if __name__ == '__main__':
    unittest.main()