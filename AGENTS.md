# Agent Instructions

This repository packages the upstream `mgba` emulator (https://github.com/mgba-emu/mgba) for Fedora COPR.

## Scope And Safety

- Keep edits minimal and packaging-focused.
- Do not commit or track generated RPM build outputs from `BUILD/`, `BUILDROOT/`, `RPMS/`, `SRPMS/`, `SOURCES/*.tar.gz`, `tmp/`, or `*.log`. `SOURCES/io.mgba.metainfo.xml` is tracked and maintained here.
- Preserve the existing org-mode README style when editing `README.org`; use `~code~` or `=literal=` consistently with nearby text.
- Prefer adding focused packaging notes to `TROUBLESHOOTING.org` instead of expanding this agent instruction file.
- COPR writes (`copr-cli modify`, `build`, `new-api-token`, `delete*`) change the public project; get the owner's approval first.

## Upstream Version Discipline

- Before building or submitting to COPR, run:

  ```sh
  make check-upstream-version
  ```

- If upstream has a newer GitHub release tag, update `Version:`, reset `Release:`, and add a `%changelog` entry in `SPECS/mgba.spec` before creating an SRPM.
- Build COPR upload artifacts with `make srpm`; do not hand-write the SRPM command unless diagnosing the Makefile.

## COPR Workflow

- COPR project: `archjun/mgba`
- Enabled chroots: `fedora-43`, `fedora-44`, and `fedora-45`, each on `aarch64` and `x86_64`. Check the current set with `copr-cli get archjun/mgba`.
- `copr-cli modify --chroot` replaces the whole chroot list; always name the existing chroots too.
- Build the SRPM on a host running the target Fedora release so the dist tag matches, and test it with `mock -r fedora-<N>-aarch64` first.
- Use explicit chroots when submitting Fedora-version-specific builds, for example:

  ```sh
  copr-cli build archjun/mgba \
    -r fedora-45-aarch64 \
    -r fedora-45-x86_64 \
    SRPMS/mgba-<version>-<release>.fc45.src.rpm
  ```

- Prefer `copr-cli status <build-id>`, `copr-cli list-builds archjun/mgba`, and COPR build logs to infer build state.
- If `copr-cli` returns an authentication/API response error, check `~/.config/copr` token expiration before changing packaging. `copr-cli whoami` does not verify the token; see `TROUBLESHOOTING.org`.

## Known Packaging Lessons

- Upstream 0.10.5 supports only Qt5 for the Qt frontend; keep the `qt5-*` BuildRequires until upstream moves to Qt6.
- FFmpeg is disabled (`-DUSE_FFMPEG=OFF`) because `ffmpeg-devel` is unavailable in COPR buildroots.
- CMake 4 (Fedora 44 and later) needs `-DCMAKE_POLICY_VERSION_MINIMUM=3.5` because upstream declares `cmake_minimum_required(VERSION 3.1)`.

## Verification

- For Makefile/spec metadata changes, run at least:

  ```sh
  make check-upstream-version
  make test
  rpmspec -q --srpm SPECS/mgba.spec
  ```

- For COPR packaging changes, run `make srpm`, inspect the SRPM with `rpm -qpi`, and run a local `mock` rebuild before upload.
