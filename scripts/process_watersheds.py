#!/usr/bin/env python3
# process_watersheds.py

import geopandas as gpd
import rasterio
import numpy as np
from rasterio.features import shapes
import fiona

def vectorize_watersheds(raster_path, output_path):
    """Convert watershed raster to vector polygons"""
    with rasterio.open(raster_path) as src:
        image = src.read(1)
        mask = image != src.nodata
        
        results = (
            {'properties': {'watershed_id': v}, 'geometry': s}
            for i, (s, v) in enumerate(
                shapes(image, mask=mask, transform=src.transform))
        )
    
    with fiona.open(output_path, 'w', 
                    driver='ESRI Shapefile',
                    crs=src.crs,
                    schema={'properties': [('watershed_id', 'int')],
                           'geometry': 'Polygon'}) as dst:
        dst.writerecords(results)

def calculate_watershed_stats(watersheds_path, dem_path):
    """Calculate watershed statistics"""
    watersheds = gpd.read_file(watersheds_path)
    
    with rasterio.open(dem_path) as dem:
        # Calculate area (already in GeoDataFrame)
        watersheds['area_km2'] = watersheds.geometry.area / 1000000
        
        # Calculate mean elevation for each watershed
        from rasterstats import zonal_stats
        stats = zonal_stats(watersheds, dem_path, stats=['mean', 'min', 'max'])
        
        for i, stat in enumerate(stats):
            watersheds.loc[i, 'mean_elev'] = stat['mean']
            watersheds.loc[i, 'min_elev'] = stat['min']
            watersheds.loc[i, 'max_elev'] = stat['max']
    
    return watersheds

# Usage
vectorize_watersheds('data/processed/watersheds.tif', 
                    'data/processed/watersheds.shp')
                    
watershed_stats = calculate_watershed_stats('data/processed/watersheds.shp',
                                          'data/processed/dem_filled.tif')
watershed_stats.to_file('data/processed/watersheds_with_stats.shp')
