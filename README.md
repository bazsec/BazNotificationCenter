> **Warning: Requires [BazCore](https://www.curseforge.com/wow/addons/bazcore).** If you use the CurseForge app, it will be installed automatically. Manual users must install BazCore separately.

# BazNotificationCenter

![WoW](https://img.shields.io/badge/WoW-12.0_Midnight-blue) ![License](https://img.shields.io/badge/License-GPL_v2-green) ![Version](https://img.shields.io/github/v/tag/bazsec/BazNotificationCenter?label=Version&color=orange)

A modern notification center for World of Warcraft that captures game events and displays them as toasts and in a persistent notification panel.

BazNotificationCenter monitors dozens of game events - loot drops, reputation gains, achievements, rare spawns, guild activity, queue pops, profession crafts, and more - and presents them as polished toast notifications that slide in and fade out. Every notification is also saved to a scrollable history panel that you can browse at any time.

***

## Features

### Toast Notifications

*   **Animated toasts** that slide in from the edge of your screen and fade out after a configurable duration
*   **Module label** on each toast so you know which system generated it
*   **Stacking** - multiple toasts queue up without overlapping
*   **Per-module toggles** - enable or disable notifications for each event type independently

### Notification Panel

*   **Persistent history** - every notification is saved and browsable
*   **Scrollable timeline** grouped by day
*   **Configurable retention** (1-90 days, default 7) - old notifications are automatically pruned
*   **Toggle button** in the addon compartment

### Notification Modules

BNC ships with modules for a wide range of game events:

*   **Loot** - item drops with rarity colors
*   **Reputation** - faction standing changes
*   **XP** - experience gains
*   **Currency** - currency gains and losses
*   **Achievements** - achievement completions
*   **Rare Spawns** - vignette detection with atlas-based filtering (kills, loot, events, bosses)
*   **Guild** - guild member activity
*   **Queue** - LFG queue events (from BazDungeonFinder integration)
*   **Professions** - crafting completions
*   **And more** - extensible via BazCore's notification bridge

### Smart Handoff

*   BazLootNotifier automatically defers matching categories to BNC when installed
*   BazDungeonFinder pushes queue toasts through BNC
*   Any Baz Suite addon can push notifications via `BazCore:PushNotification()`

### Global Options

*   Per-module enable/disable toggles
*   Toast duration and positioning
*   History retention period
*   Module-level configuration

***

## Compatibility

*   **WoW Version:** Retail 12.0 (Midnight)
*   **Midnight API Safe:** Taint-safe event handling
*   **Addon Compartment:** Toggle button registered automatically
*   **BazLootNotifier:** Smart per-category handoff
*   **BazDungeonFinder:** Queue event toast integration

***

## Dependencies

**Required:**

*   [BazCore](https://www.curseforge.com/wow/addons/bazcore) - shared framework for Baz Suite addons

***

## Part of the Baz Suite

BazNotificationCenter is part of the **Baz Suite** of addons, all built on the [BazCore](https://www.curseforge.com/wow/addons/bazcore) framework:

*   **[BazBars](https://www.curseforge.com/wow/addons/bazbars)** - Custom extra action bars
*   **[BazWidgetDrawers](https://www.curseforge.com/wow/addons/bazwidgetdrawers)** - Slide-out widget drawer
*   **[BazWidgets](https://www.curseforge.com/wow/addons/bazwidgets)** - Widget pack for BazWidgetDrawers
*   **[BazNotificationCenter](https://www.curseforge.com/wow/addons/baznotificationcenter)** - Toast notification system
*   **[BazLootNotifier](https://www.curseforge.com/wow/addons/bazlootnotifier)** - Animated loot popups
*   **[BazFlightZoom](https://www.curseforge.com/wow/addons/bazflightzoom)** - Auto zoom on flying mounts
*   **[BazMap](https://www.curseforge.com/wow/addons/bazmap)** - Resizable map and quest log window
*   **[BazMapPortals](https://www.curseforge.com/wow/addons/bazmapportals)** - Mage portal/teleport map pins

***

## License

BazNotificationCenter is licensed under the **GNU General Public License v2** (GPL v2).
