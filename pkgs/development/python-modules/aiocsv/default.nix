{ lib
, aiofiles
, buildPythonPackage
, cython
, fetchFromGitHub
, pytest-asyncio
, pytestCheckHook
, pythonOlder
}:

buildPythonPackage rec {
  pname = "aiocsv";
  version = "1.2.5";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "MKuranowski";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-4QvVYcTpwhFH57r+iMgmYciWIC2prRnL+ih7qx/CA/U=";
  };

  nativeBuildInputs = [
    cython
  ];

  nativeCheckInputs = [
    aiofiles
    pytest-asyncio
    pytestCheckHook
  ];

  preBuild = ''
    export CYTHONIZE=1
  '';

  pythonImportsCheck = [
    "aiocsv"
  ];

  disabledTestPaths = [
    # Import issue
    "tests/test_parser.py"
  ];

  meta = with lib; {
    description = "Library for for asynchronous CSV reading/writing";
    homepage = "https://github.com/MKuranowski/aiocsv";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ fab ];
  };
}
