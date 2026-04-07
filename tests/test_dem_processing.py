import unittest
from unittest.mock import patch, MagicMock, call
import os
import sys

# Add project root to path for imports
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(project_root)

from lib.dem_processing import DEMProcessor
from lib.config import ConfigLoader

class TestDEMProcessor(unittest.TestCase):

    def setUp(self):
        """Set up a mock config loader for tests."""
        self.mock_config = {
            'paths': {
                'grassdb': 'grassdb',
                'raw_data': 'data/raw',
                'processed_data': 'data/processed'
            },
            'environment': {
                'grass_location': 'test_location',
                'grass_mapset': 'PERMANENT'
            },
            'data_sources': {
                'dem': {
                    'filename': 'test_dem.tif'
                }
            },
            'processing': {
                'watersheds': {
                    'stream_threshold': 500,
                    'outlets': [
                        {'name': 'outlet1', 'coordinates': [100, 200]}
                    ]
                }
            }
        }

        # Mock the ConfigLoader
        self.mock_config_loader = MagicMock(spec=ConfigLoader)
        self.mock_config_loader.get.side_effect = lambda key, default=None: self.get_mock_config(key, default)

    def get_mock_config(self, key_path, default=None):
        """Helper to get values from the mock config dict."""
        keys = key_path.split('.')
        value = self.mock_config
        try:
            for key in keys:
                value = value[key]
            return value
        except (KeyError, TypeError):
            return default

    @patch('lib.dem_processing.Session')
    @patch('os.path.exists', return_value=True)
    def test_run_processing_workflow(self, mock_os_exists, mock_session):
        """Test the main run_processing workflow calls all steps in order."""
        # Mocks for GRASS modules
        mock_g = MagicMock()
        mock_r = MagicMock()
        mock_v = MagicMock()

        processor = DEMProcessor(self.mock_config_loader, grass_g=mock_g, grass_r=mock_r, grass_v=mock_v)

        # Use a mock for the processor instance to track calls on its methods
        processor.import_dem = MagicMock()
        processor.set_region = MagicMock()
        processor.fill_sinks = MagicMock()
        processor.extract_streams = MagicMock()
        processor.process_outlets = MagicMock()
        processor.export_streams = MagicMock()

        processor.run_processing()

        # Check that the GRASS session was started
        mock_session.assert_called_once()

        # Check that all processing methods were called
        processor.import_dem.assert_called_once()
        processor.set_region.assert_called_once()
        processor.fill_sinks.assert_called_once()
        processor.extract_streams.assert_called_once()
        processor.process_outlets.assert_called_once()
        processor.export_streams.assert_called_once()

    def test_import_dem(self):
        """Test the import_dem method."""
        mock_r = MagicMock()
        processor = DEMProcessor(self.mock_config_loader, grass_r=mock_r)
        processor.import_dem()
        mock_r.in_gdal.assert_called_once_with(
            input=os.path.join('data/raw', 'test_dem.tif'),
            output='dem',
            overwrite=True
        )

    def test_set_region(self):
        """Test the set_region method."""
        mock_g = MagicMock()
        processor = DEMProcessor(self.mock_config_loader, grass_g=mock_g)
        processor.set_region()
        mock_g.region.assert_called_once_with(raster='dem')

    def test_fill_sinks(self):
        """Test the fill_sinks method."""
        mock_r = MagicMock()
        processor = DEMProcessor(self.mock_config_loader, grass_r=mock_r)
        processor.fill_sinks()
        mock_r.terraflow.assert_called_once_with(
            elevation='dem',
            filled='dem_filled',
            direction='flow_dir',
            swatershed='watersheds',
            accumulation='flow_acc',
            overwrite=True
        )

    def test_extract_streams(self):
        """Test the extract_streams method."""
        mock_r = MagicMock()
        processor = DEMProcessor(self.mock_config_loader, grass_r=mock_r)
        processor.extract_streams()
        mock_r.mapcalc.assert_called_once_with(
            expression="streams = if(flow_acc > 500, 1, null())",
            overwrite=True
        )
        mock_r.to_vect.assert_called_once_with(
            input='streams',
            output='stream_network',
            type='line',
            overwrite=True
        )

    @patch('os.makedirs')
    def test_process_outlets(self, mock_makedirs):
        """Test the process_outlets method."""
        mock_r = MagicMock()
        mock_v = MagicMock()
        processor = DEMProcessor(self.mock_config_loader, grass_r=mock_r, grass_v=mock_v)
        processor.process_outlets()

        # Check calls for the single outlet in mock_config
        mock_r.water_outlet.assert_called_once_with(
            input='flow_dir',
            output='basin_outlet1',
            coordinates=[100, 200],
            overwrite=True
        )
        mock_r.to_vect.assert_called_once_with(
            input='basin_outlet1',
            output='watershed_outlet1',
            type='area',
            overwrite=True
        )
        mock_v.out_ogr.assert_called_once_with(
            input='watershed_outlet1',
            output=os.path.join('data/processed', 'watershed_outlet1.shp'),
            format='ESRI_Shapefile',
            overwrite=True
        )

    @patch('os.makedirs')
    def test_export_streams(self, mock_makedirs):
        """Test the export_streams method."""
        mock_v = MagicMock()
        processor = DEMProcessor(self.mock_config_loader, grass_v=mock_v)
        processor.export_streams()
        mock_v.out_ogr.assert_called_once_with(
            input='stream_network',
            output=os.path.join('data/processed', 'streams.shp'),
            format='ESRI_Shapefile',
            overwrite=True
        )

if __name__ == '__main__':
    unittest.main()
