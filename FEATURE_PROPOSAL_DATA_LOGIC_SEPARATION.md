# Feature Proposal: Separate Data from Logic in Watershed Mapping Project

## Executive Summary

This proposal addresses the current tight coupling between data and processing logic in the watershed mapping project. While the existing implementation is functional, it suffers from maintainability, reusability, and testability issues due to hard-coded parameters, file paths, and configuration scattered throughout shell scripts and Python code.

## Problem Analysis

### Current Issues with Data/Logic Mixing

#### 1. Hard-coded Configuration Parameters
- **Stream threshold values** (`flow_acc > 1000`) embedded directly in shell scripts
- **Geographic coordinates** for watershed outlets (`384500,801500`) hard-coded in processing scripts
- **File paths** and directory structures assumed throughout the codebase
- **Processing parameters** like elevation band values, DPI settings, and color schemes mixed with logic

#### 2. Environment-Specific Dependencies
- **EPSG codes** and coordinate system definitions scattered across scripts
- **Region boundaries** defined inline rather than externally configurable
- **Data source URLs** and download parameters embedded in acquisition scripts

#### 3. Limited Modularity
- **Processing steps** tightly coupled to specific input/output file formats
- **Script interdependencies** based on implicit file naming conventions
- **No clear interfaces** between processing stages

### Arguments Supporting Better Separation

#### Strong Arguments FOR Separation:

1. **Reusability Across Regions**
   - Current implementation is Aberdeenshire-specific
   - Other watershed projects would require extensive script modification
   - Configuration externalization would enable easy adaptation to new regions

2. **Maintainability**
   - Parameter changes currently require editing multiple script files
   - Risk of inconsistencies when updating processing parameters
   - Centralized configuration would reduce maintenance overhead

3. **Testing and Quality Assurance**
   - Hard-coded paths prevent effective unit testing
   - Difficult to validate processing logic with test datasets
   - No clear separation makes mocking and stubbing challenging

4. **Collaboration and Version Control**
   - Multiple users modifying scripts leads to merge conflicts
   - Customizations for specific use cases pollute the main codebase
   - External configuration enables user-specific settings without code changes

5. **Reproducibility and Documentation**
   - Processing parameters scattered across files reduce transparency
   - Difficult to document complete parameter sets used for specific runs
   - Configuration files would serve as explicit documentation

#### Arguments AGAINST Separation:

1. **Implementation Simplicity**
   - Current approach is straightforward for single-use scenarios
   - Minimal abstraction reduces cognitive overhead for beginners
   - Self-contained scripts are easier to understand at first glance

2. **Performance Considerations**
   - Direct file access may have slight performance advantages
   - Less indirection in the processing pipeline
   - Reduced overhead from configuration parsing

3. **Operational Simplicity**
   - Fewer files to manage and coordinate
   - No additional configuration syntax to learn
   - Clear workflow visible in script content

### Conclusion on Merit

**The claim has substantial merit.** While the current approach works adequately for a single-use case, the benefits of separation significantly outweigh the costs:

- **Scalability**: Enable application to multiple watersheds and regions
- **Maintainability**: Reduce long-term maintenance burden
- **Quality**: Improve testing capabilities and reduce errors
- **Collaboration**: Support multiple users and use cases
- **Documentation**: Create explicit, trackable configurations

The slight increase in complexity is justified by the substantial improvements in project sustainability and broader applicability.

## Proposed Technical Solution

### 1. Configuration Management System

#### 1.1 Hierarchical Configuration Structure
```yaml
# config/default.yaml
project:
  name: "Aberdeenshire Watershed Mapping"
  coordinate_system: "EPSG:27700"
  region:
    bounds: [350000, 450000, 780000, 880000]
    name: "Aberdeenshire"

data_sources:
  dem:
    source: "EU-DEM"
    resolution: 25
    url: "https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1"
  osm:
    url: "https://download.geofabrik.de/europe/great-britain/scotland-latest.osm.pbf"

processing:
  watersheds:
    stream_threshold: 1000
    outlets:
      - name: "dee"
        coordinates: [384500, 801500]
      - name: "don" 
        coordinates: [390000, 820000]
  
  cartography:
    dpi: 300
    map_size: "15c"
    colors:
      watersheds: "set1"
      rivers: "blue"
      settlements: "red"

paths:
  data_dir: "data"
  raw_data: "${data_dir}/raw"
  processed_data: "${data_dir}/processed"
  output: "output"
  grassdb: "grassdb"
```

#### 1.2 Environment-Specific Overrides
```yaml
# config/environments/development.yaml
processing:
  watersheds:
    stream_threshold: 500  # Lower threshold for testing
  cartography:
    dpi: 150  # Faster rendering for development

# config/environments/production.yaml  
processing:
  cartography:
    dpi: 600  # High quality for final output
```

#### 1.3 User-Specific Customization
```yaml
# config/user/custom.yaml
project:
  name: "Custom Watershed Study"
  coordinate_system: "EPSG:4326"
  region:
    bounds: [-5.0, -3.0, 57.0, 58.0]
    name: "Custom Region"
```

### 2. Data Source Abstraction Layer

#### 2.1 Data Source Interface
```python
# lib/data_sources.py
from abc import ABC, abstractmethod
from typing import Dict, Any
import os

class DataSource(ABC):
    """Abstract base class for data sources"""
    
    @abstractmethod
    def acquire(self, config: Dict[str, Any], target_path: str) -> bool:
        """Download and prepare data from source"""
        pass
    
    @abstractmethod
    def validate(self, path: str) -> bool:
        """Validate downloaded data"""
        pass

class DEMSource(DataSource):
    def acquire(self, config: Dict[str, Any], target_path: str) -> bool:
        source_config = config['data_sources']['dem']
        # Implementation for DEM acquisition
        pass

class OSMSource(DataSource):
    def acquire(self, config: Dict[str, Any], target_path: str) -> bool:
        source_config = config['data_sources']['osm']
        # Implementation for OSM data acquisition
        pass
```

#### 2.2 Configurable Data Acquisition
```python
# scripts/acquire_data_v2.py
#!/usr/bin/env python3
import yaml
from lib.data_sources import DEMSource, OSMSource
from lib.config import load_config

def main():
    config = load_config()
    
    sources = {
        'dem': DEMSource(),
        'osm': OSMSource()
    }
    
    for source_name, source in sources.items():
        target_path = config['paths']['raw_data']
        if source.acquire(config, target_path):
            print(f"✓ {source_name} data acquired successfully")
        else:
            print(f"✗ Failed to acquire {source_name} data")

if __name__ == '__main__':
    main()
```

### 3. Parameterized Processing Pipeline

#### 3.1 Configuration-Driven Shell Scripts
```bash
#!/bin/bash
# scripts/process_dem_v2.sh

# Load configuration
source lib/config_loader.sh
load_config

# Use configuration variables
grass78 "$GRASS_DB/$LOCATION/PERMANENT"

# Set region from configuration
g.region -s raster=eudem_aberdeenshire

# Import DEM with configured parameters
r.in.gdal input="${CONFIG_PATHS_RAW_DATA}/eudem_aberdeenshire.tif" output=dem

# Fill sinks with configured algorithm
r.fill.dir input=dem output=dem_filled direction=flow_dir areas=problem_areas

# Calculate flow accumulation
r.flow elevation=dem_filled flowline=flowlines flowlength=flowlength \
  flowaccumulation=flow_acc

# Define stream network with configurable threshold
r.mapcalc "streams = if(flow_acc > ${CONFIG_PROCESSING_WATERSHEDS_STREAM_THRESHOLD}, 1, null())"

# Process each configured outlet
for outlet in $(echo "$CONFIG_PROCESSING_WATERSHEDS_OUTLETS" | jq -r '.[] | @base64'); do
    outlet_data=$(echo "$outlet" | base64 --decode | jq -r '.')
    name=$(echo "$outlet_data" | jq -r '.name')
    coords=$(echo "$outlet_data" | jq -r '.coordinates | join(",")')
    
    r.water.outlet input=dem_filled output="basin_${name}" coordinates="$coords"
    r.to.vect input="basin_${name}" output="watershed_${name}" type=area
    v.out.ogr input="watershed_${name}" output="${CONFIG_PATHS_PROCESSED_DATA}/watershed_${name}.shp"
done
```

#### 3.2 Configuration Loading Library
```bash
# lib/config_loader.sh
load_config() {
    CONFIG_FILE="${CONFIG_FILE:-config/default.yaml}"
    
    # Parse YAML and export as environment variables
    eval $(python3 -c "
import yaml
import os
import sys

try:
    with open('$CONFIG_FILE', 'r') as f:
        config = yaml.safe_load(f)
    
    def flatten_dict(d, parent_key='CONFIG', sep='_'):
        items = []
        for k, v in d.items():
            new_key = f'{parent_key}{sep}{k.upper()}' if parent_key else k.upper()
            if isinstance(v, dict):
                items.extend(flatten_dict(v, new_key, sep=sep).items())
            else:
                items.append((new_key, str(v)))
        return dict(items)
    
    flat_config = flatten_dict(config)
    for key, value in flat_config.items():
        print(f'export {key}=\"{value}\"')
        
except Exception as e:
    print(f'echo \"Error loading configuration: {e}\"', file=sys.stderr)
    sys.exit(1)
")
}
```

### 4. Modular Processing Components

#### 4.1 Processing Stage Interface
```python
# lib/processors.py
from abc import ABC, abstractmethod
from typing import Dict, Any
import logging

class ProcessingStage(ABC):
    """Abstract base class for processing stages"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.logger = logging.getLogger(self.__class__.__name__)
    
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
    def execute(self) -> bool:
        """Execute DEM processing with configured parameters"""
        # Implementation using configuration
        pass

class WatershedProcessor(ProcessingStage):
    def execute(self) -> bool:
        """Execute watershed delineation with configured outlets"""
        # Implementation using configuration
        pass
```

#### 4.2 Pipeline Orchestration
```python
# scripts/pipeline_v2.py
#!/usr/bin/env python3
import yaml
from typing import List
from lib.processors import DEMProcessor, WatershedProcessor, CartographyProcessor
from lib.config import load_config

class ProcessingPipeline:
    def __init__(self, config_path: str):
        self.config = load_config(config_path)
        self.stages = self._initialize_stages()
    
    def _initialize_stages(self) -> List[ProcessingStage]:
        return [
            DEMProcessor(self.config),
            WatershedProcessor(self.config),
            CartographyProcessor(self.config)
        ]
    
    def execute(self) -> bool:
        """Execute all pipeline stages"""
        for stage in self.stages:
            if not stage.validate_inputs():
                self.logger.error(f"Input validation failed for {stage.__class__.__name__}")
                return False
            
            if not stage.execute():
                self.logger.error(f"Execution failed for {stage.__class__.__name__}")
                return False
            
            if not stage.validate_outputs():
                self.logger.error(f"Output validation failed for {stage.__class__.__name__}")
                return False
        
        return True

def main():
    pipeline = ProcessingPipeline("config/default.yaml")
    success = pipeline.execute()
    exit(0 if success else 1)

if __name__ == '__main__':
    main()
```

### 5. Testing Infrastructure

#### 5.1 Test Configuration
```yaml
# config/test.yaml
project:
  name: "Test Watershed"
  coordinate_system: "EPSG:27700"
  region:
    bounds: [400000, 410000, 800000, 810000]  # Small test region

data_sources:
  dem:
    source: "test_data"
    path: "tests/fixtures/test_dem.tif"

processing:
  watersheds:
    stream_threshold: 100  # Lower threshold for small test area
    outlets:
      - name: "test_outlet"
        coordinates: [405000, 805000]

paths:
  data_dir: "tests/tmp/data"
  output: "tests/tmp/output"
```

#### 5.2 Unit Tests
```python
# tests/test_processors.py
import unittest
import tempfile
import shutil
from lib.processors import DEMProcessor
from lib.config import load_config

class TestDEMProcessor(unittest.TestCase):
    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.config = load_config('config/test.yaml')
        self.config['paths']['data_dir'] = self.test_dir
    
    def tearDown(self):
        shutil.rmtree(self.test_dir)
    
    def test_dem_processing(self):
        processor = DEMProcessor(self.config)
        self.assertTrue(processor.validate_inputs())
        self.assertTrue(processor.execute())
        self.assertTrue(processor.validate_outputs())

if __name__ == '__main__':
    unittest.main()
```

### 6. Migration Strategy

#### 6.1 Phase 1: Configuration System (4-6 weeks)
- Implement YAML configuration loading
- Create default configuration files
- Update environment setup scripts to use configuration
- **Deliverables**: Basic configuration system, backward compatibility maintained

#### 6.2 Phase 2: Data Source Abstraction (3-4 weeks)
- Create data source interfaces
- Implement configurable data acquisition
- Add validation and error handling
- **Deliverables**: Flexible data acquisition system

#### 6.3 Phase 3: Processing Pipeline Refactoring (6-8 weeks)
- Refactor shell scripts to use configuration
- Create Python processing stage interfaces
- Implement modular pipeline orchestration
- **Deliverables**: Configurable processing pipeline

#### 6.4 Phase 4: Testing and Documentation (2-3 weeks)
- Add comprehensive unit and integration tests
- Create configuration documentation
- Update user guides and examples
- **Deliverables**: Tested, documented system

#### 6.5 Phase 5: Legacy Deprecation (2-3 weeks)
- Mark old scripts as deprecated
- Provide migration guide for existing users
- Remove deprecated code after transition period
- **Deliverables**: Clean, maintainable codebase

### 7. Benefits Realization

#### 7.1 Immediate Benefits
- **Easy regional adaptation**: New watersheds configurable without code changes
- **Simplified testing**: Isolated processing logic with test configurations
- **Better documentation**: Explicit configuration serves as documentation

#### 7.2 Medium-term Benefits
- **Improved collaboration**: User-specific configurations without code conflicts
- **Quality improvement**: Comprehensive testing reduces processing errors
- **Maintenance reduction**: Centralized configuration reduces update overhead

#### 7.3 Long-term Benefits
- **Community adoption**: Easier for others to adapt for their regions
- **Feature development**: Clean interfaces enable new capabilities
- **Scientific reproducibility**: Explicit configurations improve research reproducibility

### 8. Risk Mitigation

#### 8.1 Complexity Risk
- **Mitigation**: Maintain backward compatibility during transition
- **Approach**: Gradual migration with parallel old/new systems

#### 8.2 Performance Risk
- **Mitigation**: Profile configuration loading and optimize if needed
- **Approach**: Cache parsed configurations, minimize overhead

#### 8.3 Adoption Risk
- **Mitigation**: Comprehensive documentation and examples
- **Approach**: Provide migration tools and clear upgrade path

### 9. Success Metrics

- **Configurability**: New watershed regions deployable without code changes
- **Testing Coverage**: >80% code coverage with automated tests
- **Documentation**: Complete configuration reference and examples
- **Performance**: <5% overhead from configuration system
- **User Satisfaction**: Positive feedback from early adopters

## Conclusion

The separation of data from logic in the watershed mapping project is not just beneficial but essential for its long-term sustainability and broader impact. While the current implementation serves its immediate purpose, the proposed improvements will transform it into a robust, reusable, and maintainable geospatial processing framework.

The benefits—improved reusability, maintainability, testability, and collaboration capabilities—far outweigh the modest increase in initial complexity. The phased implementation approach ensures a smooth transition while maintaining existing functionality.

This proposal provides a clear roadmap for evolving the project from a single-use script collection into a professional-grade geospatial processing system suitable for research, education, and operational use across diverse watershed mapping applications.