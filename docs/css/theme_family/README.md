# Theme Family

This folder is the starting point for a Reveal.js theme family in this repo.

The goal is simple:

- keep each theme's personality in its own file
- move repeated Reveal/deck structure into shared SCSS partials
- make the next theme mostly tokens + a few custom components

## Files

- `_core.scss`
  Shared mixins for CSS variables, Reveal surface styles, Reveal typography shell, clean lists, and icon utilities.
- `_deck.scss`
  Shared mixins for numbered deck slides, slide-inner layout, eyebrow chips, section dividers, grid helpers, and card/property mixins.

## Intended Workflow

1. Create a new theme SCSS file in `docs/css/`.
2. Define theme tokens: colors, fonts, background, spacing.
3. Configure the official Reveal theme settings/template.
4. Emit your CSS variables with `@include css-vars(...)`.
5. Pull in the shared family primitives with mixins from `_core.scss` and `_deck.scss`.
6. Add only the theme-specific components that make that member unique.

## Build Themes

Use the repo build script from the project root:

```bash
./scripts/build-reveal-themes.sh
```

Build one theme only:

```bash
./scripts/build-reveal-themes.sh signal_ledger
./scripts/build-reveal-themes.sh amber_magnet
./scripts/build-reveal-themes.sh theme_quantum_cosmos.scss
```

List the buildable theme sources:

```bash
./scripts/build-reveal-themes.sh --list
```

What the script does:

- prefers the local Sass binary at `./.codex-tools/node_modules/.bin/sass`
- falls back to a global `sass` binary if one is installed
- if Sass is missing and `npm` is available, tries to install Sass locally in `./.codex-tools`
- if the required tools are still missing, prints a clear error with the command you need

Default behavior:

- builds every canonical `theme_*.scss` file in `docs/css`
- skips copy files such as `theme_* - Copy.scss`
- writes output CSS next to each SCSS source

## Minimal Skeleton

```scss
@use "sass:color";
@use "./theme_family/core" as family-core;
@use "./theme_family/deck" as family-deck;

$background: #101114;
$text: #eef2f7;
$accent: #00e5ff;

:root {
  @include family-core.css-vars((
    "text": $text,
    "accent": $accent,
    "body-size": 14pt,
    "h1-size": 36pt,
    "h2-size": 26pt,
    "h3-size": 14pt,
    "meta-size": 10pt
  ));
}

@include family-core.reveal-surface($background, var(--text), "Inter", sans-serif);
@include family-core.reveal-shell(
  var(--text),
  "Inter", sans-serif,
  "Outfit", sans-serif,
  var(--text),
  $progress-color: var(--accent),
  $controls-color: color.scale($accent, $lightness: -20%),
  $controls-hover-color: var(--accent)
);

@include family-deck.numbered-deck(
  40px 48px,
  linear-gradient(rgba(255, 255, 255, 0.02), rgba(255, 255, 255, 0)),
  0 24px 48px rgba(0, 0, 0, 0.4),
  rgba(255, 255, 255, 0.12)
);
@include family-deck.slide-inner-grid(240px minmax(0, 1fr), 280px minmax(0, 1fr), 32px, 20px);
@include family-deck.eyebrow-chip(6px 14px, 4px, #111, var(--accent), var(--heading-font), var(--meta-size), 700, 0.2em);
@include family-core.icon-utilities(("accent": var(--accent)));
```

## Current Members

- `docs/css/theme_amber_magnet.scss`
- `docs/css/theme_quantum_cosmos.scss`
- `docs/css/theme_signal_ledger.scss`

## Naming Notes

- Prefer names that describe the theme's visual identity or palette, not generic labels like `theme_base`.
- `theme_amber_magnet.scss` is the canonical family-theme successor to the old `theme_base.css`.
- Keep the legacy CSS file only as a historical reference or fallback while decks migrate.
