{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "watershed-mapping-env";
  
  buildInputs = with pkgs; [
    # Core GIS Analysis Tools (used in scripts)
    grass
    gdal
    gmt
    qgis
    
    # Programming Languages and Core Tools
    python3
    python3Packages.pip
    
    # Essential Python Geospatial Packages (used in scripts)
    python3Packages.geopandas
    python3Packages.rasterio
    python3Packages.shapely
    python3Packages.fiona
    python3Packages.pyproj
    python3Packages.numpy
    
    # Data Acquisition Tools
    wget
    osmium-tool
    
    # Required system libraries (dependencies)
    proj

  ];

  # Environment variables
  shellHook = ''
    # Set up environment variables
    export GRASS_PYTHON=${pkgs.python3}/bin/python3
    export GRASS_MESSAGE_FORMAT=plain
    
    # GMT defaults
    export GMT_SESSION_NAME=$$
    
    # Python virtual environment for additional packages
    export VENV_DIR="$PWD/.venv"
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "$VENV_DIR" ]; then
      echo "Creating Python virtual environment..."
      python3 -m venv "$VENV_DIR"
    fi
    
    # Activate virtual environment
    source "$VENV_DIR/bin/activate"
    
    # Install additional Python packages not available in nixpkgs
    pip install --quiet rasterstats
    
    # GRASS GIS setup
    echo "Setting up GRASS GIS environment..."
    export GISBASE=$(grass --config path 2>/dev/null || echo "")
    if [ -n "$GISBASE" ]; then
      export PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
      export LD_LIBRARY_PATH="$GISBASE/lib:$LD_LIBRARY_PATH"
      export PYTHONPATH="$GISBASE/etc/python:$PYTHONPATH"
    fi
    
    # GDAL configuration
    export GDAL_DATA=${pkgs.gdal}/share/gdal
    export PROJ_LIB=${pkgs.proj}/share/proj
    
    # Create project directories
    mkdir -p data/{raw,processed} output scripts grassdb
    
    # Helper functions
    setup_grass_location() {
      local location_name=$1
      local epsg=$2
      if [ -z "$location_name" ] || [ -z "$epsg" ]; then
        echo "Usage: setup_grass_location <location_name> <epsg_code>"
        echo "Example: setup_grass_location aberdeenshire_bng 27700"
        return 1
      fi
      
      mkdir -p grassdb
      grass -c EPSG:$epsg grassdb/$location_name
      echo "GRASS location '$location_name' created with EPSG:$epsg"
    }
    
    # Print welcome message
    cat << 'EOF'
    
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                    Watershed Mapping Environment                             ║
    ║                      Required Tools for Scripts                              ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                                                                              ║
    ║  GIS Analysis:  GRASS GIS, GDAL, GMT, QGIS                                  ║
    ║  Languages:     Python3 (with geospatial packages)                          ║
    ║  Data Tools:    wget, osmium-tool                                           ║
    ║                                                                              ║
    ║  Helper Commands:                                                            ║
    ║    setup_grass_location <name> <epsg>  - Create GRASS location              ║
    ║                                                                              ║
    ║  Quick Start:                                                                ║
    ║    setup_grass_location aberdeenshire_bng 27700                             ║
    ║    grass grassdb/aberdeenshire_bng/PERMANENT                                ║
    ║                                                                              ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    
EOF
    
    # Check that key tools are available
    echo "Checking tool availability..."
    for tool in grass gdal_translate gmt python3 wget osmium; do
      if command -v $tool >/dev/null 2>&1; then
        echo "  ✓ $tool"
      else
        echo "  ✗ $tool (not found)"
      fi
    done
    
    # Check Python packages
    echo "Checking Python geospatial packages..."
    python3 -c "
import sys
packages = ['geopandas', 'rasterio', 'fiona', 'shapely', 'pyproj', 'numpy', 'rasterstats']
for pkg in packages:
    try:
        __import__(pkg)
        print(f'  ✓ {pkg}')
    except ImportError:
        print(f'  ✗ {pkg} (not available)')
" 2>/dev/null || echo "  Python check failed"
    
    echo ""
    echo "Environment ready! Start with: setup_grass_location <name> <epsg>"
    echo ""
  '';

  # Additional environment variables that might be needed
  LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  
  # Ensure graphics work in headless environments
  QT_QPA_PLATFORM = "offscreen";
  MPLBACKEND = "Agg";
}
