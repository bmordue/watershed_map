{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "watershed-mapping-env";
  
  buildInputs = with pkgs; [
    # Core GIS Analysis Tools
    grass
    gdal
    saga
    whitebox-tools
    
    # Spatial Database
    postgis
    postgresql
    
    # Cartography and Visualization
    gmt
    qgis
    inkscape
    imagemagick
    
    # Programming Languages and Core Tools
    python3
    python3Packages.pip
    python3Packages.virtualenv
    R
    
    # Essential Python Geospatial Packages
    python3Packages.geopandas
    python3Packages.rasterio
    python3Packages.shapely
    python3Packages.fiona
    python3Packages.pyproj
    python3Packages.matplotlib
    python3Packages.numpy
    python3Packages.pandas
    python3Packages.scipy
    python3Packages.pillow
    python3Packages.requests
    python3Packages.beautifulsoup4
    
    # Additional Python packages for spatial analysis
    python3Packages.folium
    python3Packages.contextily
    python3Packages.xarray
    python3Packages.netcdf4
    python3Packages.h5py
    
    # R Spatial Packages (using rWrapper for package management)
    (rWrapper.override {
      packages = with rPackages; [
        sf
        raster
        terra
        stars
        tmap
        ggplot2
        dplyr
        tidyr
        leaflet
        mapview
        rgdal
        sp
        rgeos
        rasterVis
        RColorBrewer
        viridis
        plotly
        htmlwidgets
        knitr
        rmarkdown
      ];
    })
    
    # Command Line Tools
    curl
    wget
    unzip
    git
    gnumake
    which
    file
    tree
    
    # OSM Tools
    osmium-tool
    osmctools
    
    # Additional Geospatial Utilities
    proj
    geos
    sqlite
    spatialite-tools
    
    # Development and Documentation
    pandoc
    texlive.combined.scheme-medium
    
    # Optional: Docker for containerization
    docker
    docker-compose
    
    # Shell utilities
    bash
    coreutils
    findutils
    gnugrep
    gnused
    gawk

    # AAaaa IIiiii
    gemini-cli
    claude-code

  ];

  # Python packages that might not be available in nixpkgs
  pythonPackages = ps: with ps; [
    # rasterstats for zonal statistics
    # Note: Some packages might need to be installed via pip in shellHook
  ];

  # Environment variables
  shellHook = ''
    # Set up environment variables
    export GRASS_PYTHON=${pkgs.python3}/bin/python3
    export GRASS_MESSAGE_FORMAT=plain
    
    # GMT defaults
    export GMT_SESSION_NAME=$$
    
    # PostGIS setup (optional)
    export PGDATA=$PWD/.postgres
    export PGHOST=$PWD/.postgres
    export PGPORT=5432
    export PGDATABASE=gis
    
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
    pip install --quiet \
      rasterstats \
      whitebox \
      elevation \
      pysheds \
      richdem \
      salem \
      cartopy \
      descartes \
      geoplot \
      osmnx \
      earthpy \
      pycrs \
      geocoder \
      geopy \
      owslib \
      requests-oauthlib
    
    # R library path (libraries will be available automatically)
    
    # GRASS GIS setup
    echo "Setting up GRASS GIS environment..."
    export GISBASE=$(grass --config path 2>/dev/null || echo "")
    if [ -n "$GISBASE" ]; then
      export PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
      export LD_LIBRARY_PATH="$GISBASE/lib:$LD_LIBRARY_PATH"
      export PYTHONPATH="$GISBASE/etc/python:$PYTHONPATH"
    fi
    
    # SAGA setup
    export SAGA_MLB=$(saga_cmd --version 2>&1 | grep "library path" | cut -d: -f2 | tr -d ' ' || echo "")
    
    # GDAL configuration
    export GDAL_DATA=${pkgs.gdal}/share/gdal
    export PROJ_LIB=${pkgs.proj}/share/proj
    
    # Create project directories
    mkdir -p data/{raw,processed} output scripts grassdb
    
    # Initialize PostGIS database (optional)
    init_postgis() {
      if [ ! -d "$PGDATA" ]; then
        echo "Initializing PostgreSQL database..."
        initdb -D "$PGDATA" --auth=trust >/dev/null
        pg_ctl -D "$PGDATA" -l "$PGDATA/logfile" start
        createdb "$PGDATABASE"
        psql -d "$PGDATABASE" -c "CREATE EXTENSION postgis;"
        psql -d "$PGDATABASE" -c "CREATE EXTENSION postgis_topology;"
        echo "PostGIS database initialized. Connect with: psql -d $PGDATABASE"
      fi
    }
    
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
    ║                        FOSS Tools Available                                  ║
    ╠══════════════════════════════════════════════════════════════════════════════╣
    ║                                                                              ║
    ║  GIS Analysis:  GRASS GIS, GDAL, SAGA, WhiteboxTools, PostGIS               ║
    ║  Cartography:   GMT, QGIS, Inkscape                                         ║
    ║  Languages:     Python (with geospatial packages), R (with spatial libs)   ║
    ║  Data Tools:    OSM tools, spatial utilities                                ║
    ║                                                                              ║
    ║  Helper Commands:                                                            ║
    ║    setup_grass_location <name> <epsg>  - Create GRASS location              ║
    ║    init_postgis                        - Initialize PostGIS database        ║
    ║                                                                              ║
    ║  Quick Start:                                                                ║
    ║    setup_grass_location aberdeenshire_bng 27700                             ║
    ║    grass grassdb/aberdeenshire_bng/PERMANENT                                ║
    ║                                                                              ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    
EOF
    
    # Check that key tools are available
    echo "Checking tool availability..."
    for tool in grass gdal_translate gmt saga_cmd python3 R; do
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
packages = ['geopandas', 'rasterio', 'fiona', 'shapely', 'pyproj', 'matplotlib', 'rasterstats']
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
