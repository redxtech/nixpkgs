{ lib, buildPythonPackage, fetchPypi, python-dateutil, lxml }:

buildPythonPackage rec {
  pname = "feedgen";
  version = "0.9.0";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0jl0b87l7v6c0f1nx6k81skjhdj5i11kmchdjls00mynpvdip0cf";
  };

  propagatedBuildInputs = [ python-dateutil lxml ];

  # No tests in archive
  doCheck = false;

  meta = with lib; {
    description = "Python module to generate ATOM feeds, RSS feeds and Podcasts.";
    downloadPage = "https://github.com/lkiesow/python-feedgen/releases";
    homepage = "https://github.com/lkiesow/python-feedgen";
    license = with licenses; [ bsd2 lgpl3 ];
    maintainers = with maintainers; [ casey ];
  };
}
