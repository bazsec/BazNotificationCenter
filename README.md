> **Warning: Requires [BazCore](https://www.curseforge.com/wow/addons/bazcore).** If you use the CurseForge app, it will be installed automatically. Manual users must install BazCore separately.

# BazNotificationCenter

![WoW](https://img.shields.io/badge/WoW-12.0_Midnight-blue) ![License](https://img.shields.io/badge/License-GPL_v2-green) ![Version](https://img.shields.io/github/v/tag/bazsec/BazNotificationCenter?label=Version&color=orange&sort=date)

A modern notification center for World of Warcraft that captures game events and displays them as toasts and in a persistent notification panel.

BazNotificationCenter monitors dozens of game events - loot drops, reputation gains, achievements, rare spawns, guild activity, profession crafts, and more - and presents them as polished toast notifications that slide in and fade out. Every notification is also saved to a scrollable history panel that you can browse at any time.

***

## Features

### The Bell

*   **On-screen bell icon** with an unread-count badge — left-click to open the notification panel, right-click to clear all notifications
*   **Movable via Edit Mode** — drag the bell to any spot on your screen; it locks in place when you exit Edit Mode
*   **Auto-orienting layout** — the panel and toast growth direction follow the bell automatically based on which screen quadrant it sits in

### Toast Notifications

*   **Animated toasts** that slide in next to the bell and fade out after a configurable duration
*   **Module label** on each toast so you know which system generated it
*   **Stacking** — multiple toasts queue up without overlapping
*   **Per-module toggles** — enable or disable notifications for each event type independently

### Notification Panel

*   **Persistent history** — every notification is saved and browsable
*   **Scrollable timeline** grouped by day
*   **Configurable retention** (1–90 days, default 7) — old notifications are automatically pruned
*   **Addon Compartment entry** as a secondary access point alongside the bell

### Notification Modules

BNC ships with 20 built-in modules. Each can be toggled independently in the Modules sub-page:

*   **Loot** — item drops with rarity colors and counts
*   **Reputation** — faction standing changes
*   **XP** — experience gains (auto-suppressed at max level)
*   **Achievements** — achievement completions for you and (optionally) party/raid members
*   **Quests** — quest accept, complete, and turn-in events
*   **Professions** — crafting completions with item icon and rarity
*   **Keystone** — Mythic+ events: completions, key upgrades, depletion
*   **Vault** — Great Vault weekly chest unlock + rewards
*   **Group** — LFG / LFR / Premade-group queue and role-check events
*   **Rares** — rare-spawn vignettes with atlas-based filtering (kills, loot, events, bosses)
*   **Instance** — dungeon/raid entries, exits, and saved-instance lockouts
*   **Zones** — zone enters, sub-zone changes, contested/sanctuary status
*   **Mail** — incoming mail, returned mail, attachments
*   **Auction** — auction house sales, expirations, outbids
*   **Inventory** — bag-space warnings and notable inventory events
*   **Calendar** — calendar invites and event reminders
*   **Collections** — toy / mount / pet additions
*   **Social** — guildmates and friends online/offline, level-ups, BNet status
*   **TalkingHead** — NPC talking-head dialogue captured to history
*   **System** — important system messages (disconnects, errors)

Plus extensibility via BazCore's notification bridge — any addon can call `BazCore:PushNotification()` to surface its own events.

### Smart Handoff

*   BazLootNotifier automatically defers matching categories to BNC when installed
*   Any Baz Suite addon can push notifications via `BazCore:PushNotification()`

### Global Options

*   Per-module enable/disable toggles
*   Toast duration
*   History retention period
*   Module-level configuration
*   Reset bell position to top-left or top-right corner

***

## Slash Commands

| Command | Description |
| --- | --- |
| `/bnc` | Open settings panel |
| `/bnc panel` | Open the notification history panel |
| `/bnc clear` | Clear all notification history (asks for confirmation) |

***

## Compatibility

*   **WoW Version:** Retail 12.0 (Midnight)
*   **Midnight API Safe:** Taint-safe event handling
*   **Edit Mode:** Bell registers with BazCore Edit Mode
*   **Addon Compartment:** Toggle entry registered automatically
*   **BazLootNotifier:** Smart per-category handoff

***

## Dependencies

**Required:**

*   [BazCore](https://www.curseforge.com/wow/addons/bazcore) — shared framework for Baz Suite addons

***

## Part of the Baz Suite

BazNotificationCenter is part of the **Baz Suite** of addons, all built on the [BazCore](https://www.curseforge.com/wow/addons/bazcore) framework:

*   **[BazBars](https://www.curseforge.com/wow/addons/bazbars)** — Custom extra action bars
*   **[BazWidgetDrawers](https://www.curseforge.com/wow/addons/bazwidgetdrawers)** — Slide-out widget drawer
*   **[BazWidgets](https://www.curseforge.com/wow/addons/bazwidgets)** — Widget pack for BazWidgetDrawers
*   **[BazNotificationCenter](https://www.curseforge.com/wow/addons/baznotificationcenter)** — Toast notification system
*   **[BazLootNotifier](https://www.curseforge.com/wow/addons/bazlootnotifier)** — Animated loot popups
*   **[BazFlightZoom](https://www.curseforge.com/wow/addons/bazflightzoom)** — Auto zoom on flying mounts
*   **[BazMap](https://www.curseforge.com/wow/addons/bazmap)** — Resizable map and quest log window
*   **[BazMapPortals](https://www.curseforge.com/wow/addons/bazmapportals)** — Mage portal/teleport map pins

***

## License

BazNotificationCenter is licensed under the **GNU General Public License v2** (GPL v2).
