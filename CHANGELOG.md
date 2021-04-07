## [3.4.2] - 2021-04-07
### Changed
- Update to GravitySync version 3.4.2

## [3.4.1] - 2021-04-07
### Changed
- Update to GravitySync version 3.4.1
- Fixed bug where passwordless sudo may not be granted in SSH container during testing
- Tidy up docker compose file
- Add support for new BACKUP_TIMEOUT option

## [3.4.0] - 2021-04-06
### Changed
- Update to GravitySync version 3.4.0

## [3.3.2] - 2021-02-17
### Added
- Added gsbuild, gstest and docker-testenvironment-compose.yml for scripted build and testing
- Added doocumentation and config options for remote SSH port and DNSMASQ directory locations

### Changed
- Update to GravitySync version 3.3.2

## [3.2.6.1] - 2021-02-08
### Added
- Added section to Readme to inform users to persist gravity-sync.md5
- Update Dockerfile to add util-linux for support of the namei command
- Create and backfill CHANGELOG.md
- Added timezone correction (as this does not come with Alpine by default)
- Added Healthcheck (Mission Report)
- Fix syntax error in configuration script

## [3.2.6] - 2021-02-05
### Changed
- Update to GravitySync version 3.2.6

## [3.2.5.1] - 2021-02-04
### Added
- Item in todo in Readme to document gravity-sync.md5 persist requirements
- Add placeholder for Git when running GravitySync Info
- Install Coreutils to allow for timeout --preserve-status

## [3.2.5] - 2021-02-03
### Changed
- Update to GravitySync version 3.2.5

## [3.2.4.1] - 2021-01-25
### Changed
- Correct indenting of Dockerfile

## [3.2.4] - 2021-01-19
### Added
- Initial commit at GravitySync version 3.2.4
