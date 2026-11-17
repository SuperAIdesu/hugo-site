# Project Overview

This is a personal website to display the user's project portfolio and posts. It is heavily inspired by the original neofeed theme (under `themes/neofeed`), and the goal is to simulate a KDE desktop environment.

The theme under `themes/neofeed` is a forked submodule. All design work should target the newly added **breeze** and **catppuccin** skins.

## Git Operations

- **Never commit or push without the user's explicit approval.**

## Section Architecture

- The `themes/neofeed` theme is generic and must not hardcode individual content sections. Generic building blocks are the `site.Menus.main` task-manager header, the `icon` partial, and the `.window` class.
- Section-specific layouts, front matter, archetypes, styles, and sample content belong in this repository (for example `layouts/experience/`, `content/projects/`, and `static/css/sections.css`).
- Site styles loaded through `params.customCSS` load after the active skin, so site code can style or override theme components without editing the theme.

## Resources & Design Guidelines

When designing or modifying the skins, follow the official references below.

### Breeze Theme

- CSS style files: <https://invent.kde.org/plasma/union/-/tree/master/src/input/css/styles/breeze?ref_type=heads>
- Full breeze repo: <https://github.com/kde/breeze>
- Icons (a web version is provided): <https://invent.kde.org/frameworks/breeze-icons>

### Catppuccin Theme

- Style guide: <https://github.com/catppuccin/catppuccin>
- KDE version implementation: <https://github.com/catppuccin/kde>
