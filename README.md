# Inochi Creator Nightly Builds

This build system is based on the [tenacity flatpak nightly](https://github.com/tenacityteam/tenacity-flatpak-nightly) build system.

## Installation

Make sure to have the [Flathub remote](https://flatpak.org/setup/) added.

```
flatpak remote-add gdm-inochi-creator oci+https://grillo-delmal.github.io/ inochi-creator-nightly
flatpak install gdm-inochi-creator com.inochi2d.inochi-creator
```

(Use `--user` flag in all commands to install per user.)

## How does this work

There are 2 workflows that do the heavy lifting.

### update.yaml

This workflow runs the `update-creator.sh` and `update-dependencies.sh` scripts, which updates the 
`dub-add-local-sources.json` and the `latest-creator.yml` files. If those files suffer changes, 
they are commited to the main branch.

This workflow runs once each day and can get triggered manually.

### flatpak.yaml

This workflow was imported from [flatpak-remote](https://github.com/TheEvilSkeleton/flatpak-remote).
This process is expected to build the flatpak package and push it to the registry.

It's run whenever the `main` branch is updated, expected to be triggered by the previous process on
update. 

## Scripts

### update-creator.sh

Simple script that pulls the `inochi-creator` repo and records the latest commit on the `main` 
branch into the `latest-creator.yml` file.

### update-dependencies.sh

This script will generate the dependency lists for inochi-creator, using as reference the commit hash from the `./com.inochi2d.inochi-creator.yml` file.

### Verification stage
* Extract the commit hash from the `./com.inochi2d.inochi-creator.yml` file (`checkout target`)
  * It can also check the commit hash from an external file (like `latest-creator.yml`) file if the `--ext-creator` is set
* The next part of the process can be skipped if you use the `-f/--force` argument.
  * If it's not a nightly build and a `.dep_target` file exists.
    * Extract the commit hash from `.dep_target`.
    * If both hashes are the same, then the process exits with err code 1.

### Download Stage
* Clears the working folder (`./dep.build`).
* Clones inochi-creator repository.
* Checkouts the commit hash from the `checkout target`.
* Clones all the forked repositories into the deps folder.
* If its not a nightly build, then it sincronizes the deps with the inochi-creator repo through the following steps.
  * Checkout the latest tag for inochi-creator.
  * Check the date from inochi-creator's latest tag head.
  * For each repo find the latest commit before the date of the latest tag's head.
  * Checkout that commit.
* Fix the tag for inochi2d if it's broken.
* Checkout semver version required for gitver.

### Build Stage
* Add all the forked repositories as local dependencies for the inochi-creator project.
* Run `dub describe` to download the dependencies and list the required versions on `dub.selections.json`.

### Process Stage
* Get `flatpak-dub-generator.py` from [flatpak-builder-tools](https://github.com/flatpak/flatpak-builder-tools).
* Run through the processed `dub.selections.json` to generate `dub-add-local-sources.json`.
  * Adds the gitver and semver repositories.
  * Replace all the forked libraries with the propper git repositories and commit hashes.
* If it's a nightly build, it will remove the `.dep_target` file.
  * If its not, it will store the `checkout target` to the `.dep_target` file.
