{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, pytestCheckHook
, hypothesis
, levenshtein
}:

buildPythonPackage rec {
  pname = "thefuzz";
  version = "0.20.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ol5JeGscRgPH/G4taea8ZgmCopGWmLU2/4NU4GMcxA0=";
  };

  propagatedBuildInputs = [ levenshtein ];

  # Skip linting
  postPatch = ''
    substituteInPlace test_thefuzz.py --replace "import pycodestyle" ""
  '';

  pythonImportsCheck = [
    "thefuzz"
  ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  disabledTests = [
    # Skip linting
    "test_pep8_conformance"
  ];

  meta = with lib; {
    description = "Fuzzy string matching for Python";
    homepage = "https://github.com/seatgeek/thefuzz";
    changelog = "https://github.com/seatgeek/thefuzz/blob/${version}/CHANGES.rst";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ sumnerevans ];
  };
}
