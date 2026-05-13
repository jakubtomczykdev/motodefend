---
name: Cyber-Kinetic Interface
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#c5c6cf'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#8f9099'
  outline-variant: '#44474e'
  surface-tint: '#b5c6f0'
  primary: '#b5c6f0'
  on-primary: '#1e3052'
  primary-container: '#001435'
  on-primary-container: '#6e7fa5'
  inverse-primary: '#4d5e83'
  secondary: '#d3fbff'
  on-secondary: '#00363a'
  secondary-container: '#00eefc'
  on-secondary-container: '#00686f'
  tertiary: '#4fdbc8'
  on-tertiary: '#003731'
  tertiary-container: '#001915'
  on-tertiary-container: '#008f81'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#b5c6f0'
  on-primary-fixed: '#061b3c'
  on-primary-fixed-variant: '#354769'
  secondary-fixed: '#7df4ff'
  secondary-fixed-dim: '#00dbe9'
  on-secondary-fixed: '#002022'
  on-secondary-fixed-variant: '#004f54'
  tertiary-fixed: '#71f8e4'
  tertiary-fixed-dim: '#4fdbc8'
  on-tertiary-fixed: '#00201c'
  on-tertiary-fixed-variant: '#005048'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  display-lg:
	fontFamily: metropolis
	fontSize: 48px
	fontWeight: '700'
	lineHeight: 56px
	letterSpacing: -0.02em
  headline-md:
	fontFamily: metropolis
	fontSize: 32px
	fontWeight: '600'
	lineHeight: 40px
	letterSpacing: -0.01em
  headline-sm:
	fontFamily: metropolis
	fontSize: 24px
	fontWeight: '600'
	lineHeight: 32px
  body-lg:
	fontFamily: hankenGrotesk
	fontSize: 18px
	fontWeight: '400'
	lineHeight: 28px
  body-md:
	fontFamily: hankenGrotesk
	fontSize: 16px
	fontWeight: '400'
	lineHeight: 24px
  label-caps:
	fontFamily: spaceMono
	fontSize: 12px
	fontWeight: '700'
	lineHeight: 16px
	letterSpacing: 0.1em
  label-status:
	fontFamily: hankenGrotesk
	fontSize: 14px
	fontWeight: '500'
	lineHeight: 20px
spacing:
  unit: 4px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 48px
  container-max-width: 1440px
---

## Brand & Style

This design system establishes a high-performance, premium aesthetic for a roguelike shop, merging the heritage of classic telecommunications with futuristic cybernetics. The brand personality is precise, cold, and elite, evoking the feeling of a high-tech terminal found within a secure orbital facility.

The visual style is a hybrid of **Minimalism** and **Glassmorphism**, focused on data density and clarity. It prioritizes "High-Tech/Low-Life" elegance—meaning every pixel serves a functional purpose, but is delivered with a premium, polished finish. The emotional response should be one of calculated risk and technological empowerment, making the player feel like they are interacting with cutting-edge military hardware.

## Colors

The palette is anchored in a deep, nocturnal foundation. The primary color is a command-level **Motorola Blue**, used for core brand identity and primary interactive states. A vibrant **Cyber Blue** (#00F0FF) acts as the high-energy "active" state, providing a sharp contrast against the charcoal background.

**Teal** is reserved for utility and success states (e.g., healing items, currency gains), while **Slate** provides the structural framework for non-interactive elements. The dark mode is not a pure black, but a layered series of deep navy and charcoal tones that create a sense of infinite digital depth.

## Typography

This design system utilizes a three-tier typographic hierarchy to balance high-tech precision with readability. 

- **Metropolis** is used for headlines and item titles, providing the geometric, Bauhaus-inspired clarity associated with premium tech branding.
- **Hanken Grotesk** serves as the primary body face, offering a sharp, contemporary feel that remains legible even in data-heavy shop descriptions.
- **Space Mono** is used sparingly for labels, prices, and technical specs, grounding the interface in a "hacker-terminal" aesthetic.

All headings should favor a tighter letter-spacing for a more aggressive, modern look, while labels use expanded tracking to ensure clarity at small sizes.

## Layout & Spacing

The layout follows a **Fixed Grid** philosophy, utilizing a 12-column system on desktop and a 4-column system on mobile. The spacing rhythm is strictly based on a 4px baseline, ensuring that all components align to a mathematical grid, reinforcing the "engineered" feel of the system.

- **Desktop:** Items are displayed in a multi-column grid (3 or 4 per row) with generous gutters to allow the glassmorphism effects to breathe.
- **Mobile:** Content reflows into a single-column vertical stack. The shop navigation becomes a bottom-anchored persistent bar for high thumb-reachability during intense gameplay sessions.

## Elevation & Depth

Hierarchy is achieved through **Glassmorphism** and **Tonal Layering** rather than traditional shadows. 

1. **Base Layer:** The deepest background, a solid dark navy-black.
2. **Surface Layer:** Semi-transparent "frosted" panels with a 10-15% opacity white or blue tint and a 20px background blur.
3. **Accent Layer:** Thin, 1px borders using the Slate or Cyber Blue colors to define edges without adding visual bulk.
4. **Interaction Layer:** High-tier items emit a soft, outer glow (bloom effect) using their rarity color (Teal for Uncommon, Cyber Blue for Rare, Gold for Legendary).

Shadows, where used, are crisp and offset slightly to the bottom-right, acting more like a "drop-frame" than an ambient light source.

## Shapes

This design system adopts a **Sharp (0)** roundedness strategy. Every container, button, and input field features 90-degree angles to emphasize a rigid, military-industrial aesthetic. 

To prevent the UI from feeling dated, the "sharpness" is offset by the use of **chamfered corners** (angled 45-degree cuts) on primary action buttons and header tabs. This creates a distinctive, futuristic silhouette that deviates from standard web patterns while maintaining the minimalist ethos.

## Components

### Buttons
Buttons are sharp-edged with a 1px solid border. The "Primary" state features a solid fill of Motorola Blue with a subtle inner glow. The "Hover" state triggers a color shift to Cyber Blue and a flickering scan-line animation.

### Shop Cards
Cards utilize a background blur (backdrop-filter) and a semi-transparent slate fill. Item icons are placed within a secondary recessed square on the left. High-tier items feature a "pulsing" border-glow that radiates slowly.

### Chips/Tags
Used for item categories (e.g., "Weapon", "Utility", "Passive"). These are small, sharp rectangles with Space Mono text in all-caps. They use a low-opacity background tint of the item's rarity color.

### Progress Bars
Used for "Stock Left" or "Power Level." These are thin, 4px tall bars. The unfilled portion is a dark charcoal, and the filled portion is a vibrant teal or blue, featuring a segmented "block" look rather than a smooth fill.

### Lists
Lists are used for transaction history or character stats. Each row is separated by a 1px slate divider with 20% opacity. Icons are monolinear and strictly geometric.

### Checkboxes & Radios
Replaced with "Toggle Switches" that resemble physical hardware flips. When active, they emit a small Cyber Blue glow.