# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-04-27

### Added
- **Directory backup support**: The wrapper now handles both files and directories
  with identical backup logic. Moving a folder into a destination that already
  contains a folder with the same name triggers a timestamped backup of the old
  folder.
- **Collision-proof naming**: If two moves happen within the same second, a counter
  (`_1`, `_2`, …) is appended to the backup name to guarantee uniqueness.

### Changed
- **Backup naming from numeric (`.001.bak`) to timestamped** (`YYYY-MM-DD--HH-MM-SS.bak`).
  This avoids octal interpretation bugs and provides better chronological sorting.

### Changed (Documentation)
- Updated README to reflect the new timestamped backup feature.
- Added directory backup examples and collision-proof naming details.
- Removed outdated references to file-only limitation.

## [1.0.1] - 2026-04-06

### Fixed
- **Octal interpretation error** for backup numbers with leading zeros
  (e.g., `008` caused "value too great for base" error). Numbers are now
  interpreted in base‑10 using the `10#$num` conversion.
- **Uncommented line** in the script that caused unexpected behavior.

## [1.0.0] - 2026-03-27

### Added
- Initial release of the `mv` wrapper with automatic numbered backups
  (`name.ext.001.bak`, `name.ext.002.bak`, …).
- Restriction to `$HOME` only; outside `$HOME` the original `mv` behavior is preserved.
- Python virtual environment detection: backups are automatically disabled when
  the target directory resides inside an active `$VIRTUAL_ENV`.
- Full support for all standard `mv` options (`-i`, `-f`, `-n`, `-v`, `--`, etc.).
- Clean three‑digit backup numbering with automatic increment detection.
- Comprehensive README with installation and usage instructions.
- MIT License file.
- Author name "Jack MainHack BrotherHood" in README and LICENSE.

[1.1.0]: https://github.com/setuju/bash-mv-auto-backup/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/setuju/bash-mv-auto-backup/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/setuju/bash-mv-auto-backup/releases/tag/v1.0.0
