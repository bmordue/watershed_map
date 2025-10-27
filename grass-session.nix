{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "grass-session";
  version = "0.5";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "7155314535790145da8e2e31b0d20cd2be91477d54083a738b5c319164e7f03b";
  };

  # grass-session has no dependencies beyond GRASS GIS itself
  propagatedBuildInputs = [ ];

  # Skip tests during build - they require GRASS GIS to be fully set up
  doCheck = false;

  meta = with lib; {
    description = "GRASS GIS session library for Python";
    homepage = "https://github.com/zarch/grass-session";
    license = licenses.gpl3Plus;
    maintainers = [ ];
  };
}
