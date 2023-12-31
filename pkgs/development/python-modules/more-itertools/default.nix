{ lib
, buildPythonPackage
, fetchPypi
, flit-core
, pytestCheckHook
, six
, stdenv
}:

buildPythonPackage rec {
  pname = "more-itertools";
  version = "10.1.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Ymw2n6DrN7rAKRvOglmzMv1ZrHkvpUl7WYNzCc1bEUo=";
  };

  nativeBuildInputs = [
    flit-core
  ];

  propagatedBuildInputs = [
    six
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # iterable = range(10 ** 10)  # Is efficiently reversible
  # OverflowError: Python int too large to convert to C long
  doCheck = !stdenv.hostPlatform.is32bit;

  meta = with lib; {
    homepage = "https://more-itertools.readthedocs.org";
    changelog = "https://more-itertools.readthedocs.io/en/stable/versions.html";
    description = "Expansion of the itertools module";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
