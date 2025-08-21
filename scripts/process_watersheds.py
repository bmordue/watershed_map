#!/usr/bin/env python3
# process_watersheds.py - Watershed processing with configuration support

import sys
import os
from pathlib import Path

# Add lib directory to Python path
script_dir = Path(__file__).parent
lib_dir = script_dir.parent / 'lib'
sys.path.insert(0, str(lib_dir))

from config import load_config, get_config, get_paths
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

def main():
    """Main processing function using configuration"""
    try:
        # Load configuration
        config = load_config()
        paths = get_paths()
        
        # Get configured paths with fallbacks
        processed_data_path = paths.get('processed_data', 'data/processed')
        
        print("Watershed Processing Configuration:")
        print(f"  Processed data path: {processed_data_path}")
        
        # Ensure output directory exists
        os.makedirs(processed_data_path, exist_ok=True)
        
        # Define file paths using configuration
        watersheds_raster = os.path.join(processed_data_path, 'watersheds.tif')
        watersheds_vector = os.path.join(processed_data_path, 'watersheds.shp')
        dem_path = os.path.join(processed_data_path, 'dem_filled.tif')
        watersheds_with_stats = os.path.join(processed_data_path, 'watersheds_with_stats.shp')
        
        # Check if required input files exist
        if os.path.exists(watersheds_raster):
            print(f"Processing watersheds from: {watersheds_raster}")
            vectorize_watersheds(watersheds_raster, watersheds_vector)
        else:
            print(f"Warning: Watershed raster {watersheds_raster} not found, skipping vectorization")
        
        # Calculate statistics if both watershed and DEM files exist
        if os.path.exists(watersheds_vector) and os.path.exists(dem_path):
            print(f"Calculating watershed statistics...")
            watershed_stats = calculate_watershed_stats(watersheds_vector, dem_path)
            watershed_stats.to_file(watersheds_with_stats)
            print(f"Watershed statistics saved to: {watersheds_with_stats}")
            
            # Print summary statistics
            print("\nWatershed Summary:")
            print(f"  Number of watersheds: {len(watershed_stats)}")
            print(f"  Total area: {watershed_stats['area_km2'].sum():.2f} km²")
            if 'mean_elev' in watershed_stats.columns:
                print(f"  Average elevation: {watershed_stats['mean_elev'].mean():.1f} m")
                
        else:
            print(f"Warning: Required files not found for statistics calculation")
            print(f"  Watersheds: {watersheds_vector} - {'exists' if os.path.exists(watersheds_vector) else 'missing'}")
            print(f"  DEM: {dem_path} - {'exists' if os.path.exists(dem_path) else 'missing'}")
            
        print("Watershed processing completed successfully")
        
    except Exception as e:
        print(f"Error in watershed processing: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
