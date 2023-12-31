{ stdenv
, lib
, fetchurl
, autoreconfHook
, gtk-doc
, vala
, gobject-introspection
, wrapGAppsHook
, gsettings-desktop-schemas
, gspell
, libgedit-amtk
, libgedit-gtksourceview
, libgee
, tepl
, gnome
, glib
, pkg-config
, gettext
, itstool
, libxml2
}:

stdenv.mkDerivation rec {
  version = "3.46.0";
  pname = "gnome-latex";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1nVVY5sqFaiuvVTzNTVORP40MxQ648s8ynqOJvgRKto=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    gtk-doc
    vala
    gobject-introspection
    wrapGAppsHook
    itstool
    gettext
  ];

  buildInputs = [
    gnome.adwaita-icon-theme
    glib
    gsettings-desktop-schemas
    gspell
    libgedit-amtk
    libgedit-gtksourceview
    libgee
    libxml2
    tepl
  ];

  configureFlags = [
    "--disable-dconf-migration"
  ];

  doCheck = true;

  env.NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";

  passthru.updateScript = gnome.updateScript {
    packageName = pname;
    versionPolicy = "odd-unstable";
  };

  meta = with lib; {
    homepage = "https://wiki.gnome.org/Apps/GNOME-LaTeX";
    description = "A LaTeX editor for the GNOME desktop";
    maintainers = with maintainers; [ manveru bobby285271 ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = "gnome-latex";
  };
}
