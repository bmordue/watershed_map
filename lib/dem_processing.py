#!/usr/bin/env python3
"""
Module for processing Digital Elevation Models (DEMs) using GRASS GIS.
"""

import os
import sys
from grass_session import Session
from grass.pygrass.modules.shortcuts import general as g
from grass.pygrass.modules.shortcuts import raster as r
from grass.pygrass.modules.shortcuts import vector as v

class DEMProcessor:
    """
    A class to encapsulate DEM processing steps.
    """
    def __init__(self, config, grass_g=g, grass_r=r, grass_v=v):
        """
        Initializes the DEMProcessor with configuration.

        :param config: A ConfigLoader instance with loaded configuration.
        :param grass_g: GRASS general module shortcut.
        :param grass_r: GRASS raster module shortcut.
        :param grass_v: GRASS vector module shortcut.
        """
        self.config = config
        self.g = grass_g
        self.r = grass_r
        self.v = grass_v

        self.grass_db = self.config.get('paths.grassdb')
        self.grass_location = self.config.get('environment.grass_location')
        self.grass_mapset = self.config.get('environment.grass_mapset')

        raw_data_path = self.config.get('paths.raw_data')
        dem_filename = self.config.get('data_sources.dem.filename')
        self.dem_filepath = os.path.join(raw_data_path, dem_filename)

        self.processed_data_path = self.config.get('paths.processed_data')
        self.stream_threshold = self.config.get('processing.watersheds.stream_threshold')
        self.outlets = self.config.get('processing.watersheds.outlets', [])

    def run_processing(self):
        """
        Executes the full DEM processing workflow within a GRASS session.
        """
        if not os.path.exists(self.dem_filepath):
            print(f"Error: DEM file not found at {self.dem_filepath}", file=sys.stderr)
            sys.exit(1)

        gisdb_path = os.path.join(os.getcwd(), self.grass_db)

        with Session(gisdb=gisdb_path, location=self.grass_location, mapset=self.grass_mapset, create_opts=''):
            print("Starting DEM processing in GRASS...")
            self.import_dem()
            self.set_region()
            self.fill_sinks()
            self.extract_streams()
            self.process_outlets()
            self.export_streams()
            print("DEM processing completed successfully.")

    def import_dem(self):
        """Imports the DEM into the GRASS mapset."""
        print(f"Importing DEM: {self.dem_filepath}")
        self.r.in_gdal(input=self.dem_filepath, output='dem', overwrite=True)

    def set_region(self):
        """Sets the computational region to the extent of the DEM."""
        print("Setting GRASS region...")
        self.g.region(raster='dem')

    def fill_sinks(self):
        """
        Fills sinks in the DEM using r.terraflow.
        This also calculates flow accumulation and direction.
        """
        print("Filling sinks and calculating flow accumulation with r.terraflow...")
        self.r.terraflow(elevation='dem', filled='dem_filled', direction='flow_dir',
                    swatershed='watersheds', accumulation='flow_acc', overwrite=True)

    def extract_streams(self):
        """Extracts stream networks based on a flow accumulation threshold."""
        print(f"Extracting streams with threshold: {self.stream_threshold}")
        expression = f"streams = if(flow_acc > {self.stream_threshold}, 1, null())"
        self.r.mapcalc(expression=expression, overwrite=True)
        self.r.to_vect(input='streams', output='stream_network', type='line', overwrite=True)

    def process_outlets(self):
        """Delineates watersheds for a list of outlets."""
        if not self.outlets:
            print("Warning: No outlets defined in configuration.")
            return

        print("Processing watershed outlets...")
        for outlet in self.outlets:
            name = outlet.get('name')
            coords = outlet.get('coordinates')
            if not name or not coords:
                print(f"Skipping invalid outlet: {outlet}")
                continue

            print(f"  - Processing outlet: {name} at coordinates {coords}")
            basin_name = f'basin_{name}'
            watershed_name = f'watershed_{name}'
            output_shp = os.path.join(self.processed_data_path, f'watershed_{name}.shp')

            self.r.water_outlet(input='flow_dir', output=basin_name, coordinates=coords, overwrite=True)
            self.r.to_vect(input=basin_name, output=watershed_name, type='area', overwrite=True)

            # Ensure the output directory exists
            os.makedirs(self.processed_data_path, exist_ok=True)
            self.v.out_ogr(input=watershed_name, output=output_shp, format='ESRI_Shapefile', overwrite=True)

    def export_streams(self):
        """Exports the vectorized stream network to a Shapefile."""
        print("Exporting stream network...")
        output_shp = os.path.join(self.processed_data_path, 'streams.shp')
        os.makedirs(self.processed_data_path, exist_ok=True)
        self.v.out_ogr(input='stream_network', output=output_shp, format='ESRI_Shapefile', overwrite=True)
