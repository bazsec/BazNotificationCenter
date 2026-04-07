<h1 align="center">BazNotificationCenter</h1>

<p align="center">
  <strong>A modern notification center for World of Warcraft</strong><br/>
  Captures game events and displays them as toasts and in a notification panel.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/WoW-12.0%20Midnight-blue" alt="WoW Version"/>
  <img src="https://img.shields.io/badge/License-GPL%20v2-green" alt="License"/>
  <img src="https://img.shields.io/github/v/tag/bazsec/BazNotificationCenter?label=Version&color=orange" alt="Version"/>
</p>

---

## What is BazNotificationCenter?

BazNotificationCenter is a modular notification framework that captures game events — loot, achievements, mail, quests, reputation, and more — and presents them as clean toast popups and a browsable notification panel. Keep your UI decluttered while never missing important events.

Part of the **Baz Suite** of addons, powered by **BazCore**.

---

## Features

### Toast Notifications
- Brief popup toasts for new events with auto-dismiss
- Priority-based sounds (high, normal, low)
- Configurable duration and positioning (any screen corner)

### Notification Panel
- Bell icon toggle to open/close the panel
- Notifications grouped by module with timestamps
- Click notifications for item tooltips, TomTom waypoints, or custom actions
- History tab (requires BNC-History) for persistent notification storage

### 20 Built-In Modules
| Module | Notifications |
|--------|--------------|
| Achievements | Achievement earned, criteria progress, guild achievements |
| Auction | Sold, expired, outbid, won |
| Calendar | Event reminders, holidays, weekly reset |
| Collections | New mounts, pets, toys, transmog |
| Group | Party/raid roster changes, role checks |
| Instance | Dungeon/raid entry, encounter start/end, M+ completion |
| Inventory | Bag space warnings, durability alerts |
| Keystone | M+ key level, completion, weekly best |
| Loot | Item drops, gold gains, currency |
| Mail | New mail alerts, mailbox summary |
| Professions | Craft completions, skill level-ups |
| Quests | Quest accepted, completed, objective progress |
| Rares | Rare spawns, treasures, world events |
| Reputation | Rep gains/losses, standing milestones, renown |
| Social | Whispers, friend online/offline, guild status |
| System | UI errors, boss emotes, raid warnings |
| TalkingHead | NPC talking head dialogue capture |
| Vault | Great Vault progress tracking |
| XP | Experience gains, level-ups, rested XP |
| Zones | Zone and subzone change alerts |

### Do Not Disturb
- Manual toggle or auto-enable during combat/boss encounters
- Suppresses toasts and sounds while still logging notifications

### Open Plugin API
- Any addon can create notification modules
- Use `/bnc scaffold <name>` to generate a complete module template
- Simple API: `BNC:RegisterModule()`, `BNC:Push()`, `BNC:NewNotification()`

---

## Slash Commands

| Command | Description |
|---------|-------------|
| `/bnc` | Toggle notification panel |
| `/bnc options` | Open settings |
| `/bnc test` | Send a test notification |
| `/bnc testall` | Test all active modules |
| `/bnc dnd` | Toggle Do Not Disturb |
| `/bnc clear` | Clear all notifications |
| `/bnc history` | Open notification history |
| `/bnc scaffold <name>` | Generate module template |

---

## Installation

Requires **BazCore**. Install both to `World of Warcraft/_retail_/Interface/AddOns/`.

---

## Baz Suite

BazNotificationCenter is part of the Baz Suite of addons:

| Addon | Description |
|-------|-------------|
| [BazCore](https://github.com/bazsec/BazCore) | Shared framework library |
| [BazBars](https://github.com/bazsec/BazBars) | Custom extra action bars |
| [BazMap](https://github.com/bazsec/BazMap) | Resizable map and quest log |
| [BazDungeonFinder](https://github.com/bazsec/BazDungeonFinder) | Detached LFG queue bar |
| [BazLootNotifier](https://github.com/bazsec/BazLootNotifier) | Animated loot popups |
| [BazFlightZoom](https://github.com/bazsec/BazFlightZoom) | Auto-zoom on flight |
| **BazNotificationCenter** | Notification center |

---

## License

BazNotificationCenter is licensed under the [GNU General Public License v2](LICENSE) (GPL v2).

---

<p align="center">
  <sub>Built by <strong>Baz4k</strong></sub>
</p>
