# grass-session Nix Derivation

This directory contains a custom Nix derivation for the `grass-session` Python package.

## Overview

The `grass-session` package is not available in nixpkgs, so we created a custom derivation to install it from PyPI. This package is required by `lib/dem_processing.py` to manage GRASS GIS sessions in Python.

## Files

- `grass-session.nix` - The Nix derivation for grass-session v0.5
- `shell.nix` - Updated to include grass-session in the Python environment

## Implementation Details

### grass-session.nix

The derivation:
- Fetches grass-session 0.5 from PyPI
- Uses SHA256 hash verification for security
- Disables tests during build (they require GRASS GIS to be fully configured)
- Sets metadata including license (GPL-3.0+) and homepage

### shell.nix Integration

The shell.nix has been updated to:
1. Create a custom `grassSession` package using `callPackage`
2. Build a `pythonWithGrass` environment that includes all geospatial packages plus grass-session
3. Use this custom Python environment throughout the shell
4. Include grass_session in the package availability checks

## Usage

When you enter the Nix shell (`nix-shell`), grass-session will be automatically available:

```python
from grass_session import Session

# Use GRASS session
with Session(gisdb="/path/to/grassdb", location="location_name", 
             mapset="PERMANENT", create_opts=""):
    # Your GRASS operations here
    pass
```

## Testing

Run the test suite to verify the derivation:

```bash
python3 tests/test_grass_session_derivation.py
```

This will verify:
- The derivation file structure
- shell.nix integration
- SHA256 hash correctness
- Package installability

## References

- [grass-session on PyPI](https://pypi.org/project/grass-session/)
- [grass-session GitHub repository](https://github.com/zarch/grass-session)
- [Nix Python buildPythonPackage documentation](https://nixos.org/manual/nixpkgs/stable/#python)
