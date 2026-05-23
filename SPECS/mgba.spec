Name:           mgba
Version:        0.10.5
Release:        3%{?dist}
Summary:        mGBA Game Boy Advance Emulator
License:        MPL-2.0
URL:            https://mgba.io
Source0:        https://github.com/mgba-emu/mgba/archive/refs/tags/%{version}.tar.gz#/%{name}-%{version}.tar.gz
Source1:        io.mgba.metainfo.xml

BuildRequires:  gcc-c++
BuildRequires:  cmake
BuildRequires:  elfutils-libelf-devel
BuildRequires:  SDL2-devel
BuildRequires:  json-c-devel
BuildRequires:  desktop-file-utils
BuildRequires:  appstream
BuildRequires:  libedit-devel
BuildRequires:  libepoxy-devel
BuildRequires:  libzip-devel
BuildRequires:  qt5-qtbase-devel
BuildRequires:  qt5-qtmultimedia-devel
BuildRequires:  qt5-qtsvg-devel
BuildRequires:  wayland-devel
BuildRequires:  pkgconf-pkg-config

Requires:       hicolor-icon-theme

ExclusiveArch:  x86_64 aarch64

%description
mGBA is an emulator for running Game Boy Advance games. It aims to
be faster and more accurate than many existing Game Boy Advance emulators,
as well as adding features that other emulators lack. It also supports
Game Boy and Game Boy Color games.

Features:
- Highly accurate Game Boy Advance hardware support[1].
- Game Boy/Game Boy Color hardware support.
- Fast emulation. Known to run at full speed even on low end hardware, such as netbooks.
- Qt and SDL ports for a heavy-weight and a light-weight frontend.
- Local, same computer, link cable support.
- Save type detection, even for flash memory size[2].
- Support for cartridges with motion sensors and rumble
- Real-time clock support, even without configuration.
- Solar sensor support for Boktai games.
- Game Boy Camera and Game Boy Printer support.
- A built-in BIOS implementation, and ability to load external BIOS files.
- Scripting support using Lua.
- Turbo/fast-forward support by holding Tab.
- Rewind by holding Backquote.
- Frameskip, configurable up to 10.
- Screenshot support.
- Cheat code support.
- 9 savestate slots. Savestates are also viewable as screenshots.
- Video, GIF, WebP, and APNG recording.
- e-Reader support.
- Remappable controls for both keyboards and gamepads.
- Loading from ZIP and 7z files.
- IPS, UPS and BPS patch support.
- Game debugging via a command-line interface and GDB remote support, compatible with Ghidra and IDA Pro.
- Configurable emulation rewinding.
- Support for loading and exporting GameShark and Action Replay snapshots.
- Cores available for RetroArch/Libretro and OpenEmu.
- Community-provided translations for several languages via Weblate.
- Many, many smaller things.

%prep
%autosetup -n %{name}-%{version}

%build
%cmake \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_DO_STRIP=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DBUILD_QT=ON \
    -DUSE_FFMPEG=OFF \
    -DSKIP_GIT=ON
%cmake_build

%install
%cmake_install
install -Dm0644 %{SOURCE1} %{buildroot}%{_metainfodir}/io.mgba.mGBA.metainfo.xml

# Desktop file validation
desktop-file-validate %{buildroot}%{_datadir}/applications/*.desktop

%check
# AppStream metadata validation
appstream-util validate-relax --nonet %{buildroot}%{_metainfodir}/*.xml || :

%files
%license LICENSE
%doc README.md
%{_bindir}/mgba
%{_bindir}/mgba-qt
%{_libdir}/libmgba.so*
%{_includedir}/mgba
%{_includedir}/mgba-util
%{_mandir}/man6/mgba.6*
%{_mandir}/man6/mgba-qt.6*
%{_datadir}/applications/io.mgba.mGBA.desktop
%{_datadir}/icons/hicolor/*/apps/io.mgba.mGBA.png
%{_datadir}/mgba
%{_metainfodir}/io.mgba.mGBA.metainfo.xml
%doc %{_datadir}/doc/mGBA/*

%changelog
* Sat May 23 2026 Peter Jun Koh <gopeterjun@naver.com> - 0.10.5-3
- Build the mGBA Qt frontend with Qt5, matching upstream 0.10.5 CMake support
- Add CMake policy compatibility flag required by Fedora 44 CMake

* Sat May 23 2026 Peter Jun Koh <gopeterjun@naver.com> - 0.10.5-2
- Disable FFmpeg support because ffmpeg-devel is unavailable in Fedora Copr buildroots

* Sat May 23 2026 Peter Jun Koh <gopeterjun@naver.com> - 0.10.5-1
- Package upstream release 0.10.5

* Fri Dec 05 2025 Peter Jun Koh <gopeterjun@naver.com> - 0.11.0-0.1.git
- Initial package for Fedora COPR
- Built with Qt6 support
- Supports x86_64 and aarch64 architectures
- From upstream master branch HEAD e338ea5
