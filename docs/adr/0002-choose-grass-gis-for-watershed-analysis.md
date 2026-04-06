# ADR-0002: Choose GRASS GIS for Watershed Analysis

**Status**: Accepted  
**Date**: 2024-01-10  
**Deciders**: Development Team  
**Technical Story**: Initial project architecture design

---

## Context and Problem Statement

The watershed mapping project requires sophisticated geospatial processing capabilities for:

* Digital Elevation Model (DEM) processing
* Hydrological analysis (flow direction, flow accumulation)
* Watershed delineation
* Stream network extraction
* Terrain analysis

We need to choose a Free and Open Source Software (FOSS) GIS tool that:
* Provides robust hydrological analysis capabilities
* Can be automated via command-line interface
* Is actively maintained and well-documented
* Has good performance for large datasets
* Integrates well with other geospatial tools

## Decision Drivers

* **FOSS Requirement**: Must be open source with permissive license
* **CLI Automation**: Must support headless, scriptable operation
* **Hydrological Algorithms**: Needs specialized watershed analysis tools
* **Performance**: Handle regional-scale DEMs efficiently
* **Ecosystem**: Integrate with GDAL, Python, and other GIS tools
* **Community**: Active development and user community
* **Documentation**: Good tutorials and API documentation

## Considered Options

1. **GRASS GIS**
2. **SAGA-GIS**
3. **WhiteboxTools**
4. **Pure GDAL/Python (GeoPandas/Rasterio)**
5. **TauDEM**

## Decision Outcome

**Chosen option**: "GRASS GIS", because it provides the most comprehensive and proven hydrological analysis toolkit, excellent CLI automation, and is specifically designed for advanced terrain and watershed analysis.

### Positive Consequences

* Industry-proven hydrological algorithms (r.watershed, r.terraflow)
* Comprehensive terrain analysis capabilities
* Strong integration with Python (grass.script)
* Location-based data management handles coordinate systems well
* Active development community (40+ years of development)
* Excellent documentation and tutorials
* Fast performance on large datasets
* Free and open source (GPL)

### Negative Consequences

* Steeper learning curve than simpler tools
* Location/mapset concept can be confusing initially
* Requires environment setup (GRASS database)
* More complex installation than Python-only solutions
* Database-style workflow different from file-based tools

## Pros and Cons of the Options

### Option 1: GRASS GIS

Comprehensive FOSS GIS with advanced raster and vector analysis.

**Pros:**
* **Specialized hydrological tools**: r.watershed, r.terraflow, r.stream.extract
* **Proven algorithms**: Decades of development and scientific validation
* **Efficient processing**: Optimized C implementation for performance
* **Complete workflow**: DEM processing, watershed delineation, statistics in one tool
* **CLI automation**: Excellent scripting support (grass --exec)
* **Python integration**: grass.script and PyGRASS modules
* **Coordinate system handling**: Location-based approach prevents CRS errors
* **Active community**: Regular releases, extensive documentation

**Cons:**
* **Learning curve**: More complex than simple Python libraries
* **Setup overhead**: Requires GRASS database (location/mapset)
* **Installation complexity**: Native installation can be challenging
* **Workflow difference**: Database approach vs. file-based processing
* **Version compatibility**: GRASS 7 vs 8 differences

### Option 2: SAGA-GIS

Another comprehensive FOSS GIS with strong terrain analysis.

**Pros:**
* Good terrain and hydrological analysis tools
* CLI available (saga_cmd)
* Modular tool design
* Active development

**Cons:**
* **Less specialized for hydrology** than GRASS
* Smaller community than GRASS
* Documentation not as comprehensive
* Python integration less mature
* Performance similar to GRASS but less optimized for large datasets

### Option 3: WhiteboxTools

Modern Rust-based geospatial analysis library.

**Pros:**
* **Modern codebase** (Rust for safety and performance)
* **Simple CLI**: Easy to script
* **Good documentation**: Clear API
* **Fast development**: Actively adding features
* **Easy installation**: Single binary

**Cons:**
* **Newer tool**: Less proven in production
* **Limited Python integration**: Mostly CLI-based
* **Smaller ecosystem**: Fewer contributed modules
* **Less comprehensive**: Focused toolkit vs. complete GIS
* **Commercial version**: Some tools only in Whitebox GAT (paid)

### Option 4: Pure GDAL/Python (GeoPandas/Rasterio)

Build custom hydrological analysis using Python libraries.

**Pros:**
* **Full control**: Custom algorithms
* **Python native**: Easy integration with data science stack
* **Simple deployment**: pip install
* **No GIS database**: File-based workflow

**Cons:**
* **Reinvent the wheel**: Must implement complex algorithms ourselves
* **Performance**: Pure Python slower than optimized C/C++
* **Validation**: Must test and validate custom algorithms
* **Maintenance burden**: Responsible for algorithm correctness
* **Missing tools**: Would need to implement sink filling, flow routing, etc.
* **Not specialized**: General raster tools, not hydrological focus

### Option 5: TauDEM

Specialized terrain analysis toolset for hydrology.

**Pros:**
* **Hydrological focus**: Specialized for DEM and watershed analysis
* **Good algorithms**: Proven parallel flow methods
* **Academic backing**: Developed and maintained by university researchers

**Cons:**
* **Limited scope**: Only hydrological analysis (no complete GIS)
* **Installation complexity**: Requires MPI and specific dependencies
* **Small community**: Niche tool with limited user base
* **Documentation**: Less comprehensive than GRASS
* **Integration**: Would need additional tools for complete workflow

## Links and References

* [GRASS GIS Official Website](https://grass.osgeo.org/)
* [GRASS GIS Hydrology Tools](https://grass.osgeo.org/grass-stable/manuals/topic_hydrology.html)
* [r.watershed Documentation](https://grass.osgeo.org/grass-stable/manuals/r.watershed.html)
* [r.terraflow Documentation](https://grass.osgeo.org/grass-stable/manuals/r.terraflow.html)
* [GRASS Python Scripting](https://grass.osgeo.org/grass-stable/manuals/libpython/script_intro.html)

## Implementation Notes

### Key GRASS Modules Used

1. **r.in.gdal**: Import DEM rasters
2. **r.fill.dir**: Fill sinks in DEM for proper flow routing
3. **r.terraflow**: Advanced flow accumulation using Wang & Liu algorithm
4. **r.watershed**: Watershed and stream network delineation
5. **r.water.outlet**: Delineate specific watershed from outlet point
6. **r.to.vect / v.out.ogr**: Export results to standard formats

### Workflow Pattern

```bash
# Setup GRASS location
grass -c EPSG:27700 grassdb/aberdeenshire_bng

# Process within GRASS session
grass grassdb/aberdeenshire_bng/PERMANENT --exec bash -c "
    r.in.gdal input=dem.tif output=dem
    r.fill.dir input=dem output=dem_filled
    r.watershed elevation=dem_filled threshold=1000 stream=streams basin=watersheds
    r.water.outlet input=dem_filled coordinates=384500,801500 output=watershed_dee
    v.out.ogr input=watershed_dee output=watershed_dee.shp
"
```

### Integration with Pipeline

* GRASS used for core hydrological processing (Stage 3 in pipeline)
* GDAL for format conversions and reprojection
* Python for statistical analysis on GRASS outputs
* GMT for final cartographic rendering

## Validation and Acceptance Criteria

* ✅ Successfully processes regional-scale DEMs (100+ km²)
* ✅ Watershed delineation matches manual analysis
* ✅ CLI automation working in shell scripts
* ✅ Python integration functional for data processing
* ✅ Performance acceptable (<30 minutes for full region)
* ✅ Outputs compatible with standard GIS formats (Shapefiles, GeoTIFF)

## Review Date

To be reviewed: January 2026 (after 2 years of use)

---

**Related ADRs**:
* ADR-0003: Nix for Environment Management
* ADR-0001: Use YAML for Configuration Management
