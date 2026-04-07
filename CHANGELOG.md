# BazNotificationCenter Changelog

## 007 - Full BazCore Migration
- Lifecycle now managed by BazCore:RegisterAddon() (SV init, profiles, slash, minimap)
- Removed standalone WoW event frame — WoW events use BazCore addon:On()
- Internal CallbackRegistry kept for BNC-specific events (NOTIFICATION_ADDED, etc.)
- Database.lua slimmed to just SetDBValue/GetDBValue helpers
- DoNotDisturb now uses BazCore events instead of standalone frames
- Slash commands registered declaratively via BazCore commands config
- Profile system enabled — per-character notification preferences
- Profiles subcategory added to settings panel
- Data migration from flat SV to profile structure for existing users

## 006 - Audit Fixes
- Removed dead IsHistoryAvailable() check for defunct BNC-History addon
- History tab always visible (built-in)
- Fixed panel text overlapping (tab offset calculation)
- Category changed to "Baz Suite"

## 005
- Fixed per-module settings subcategories not appearing (timing fix)
- Module options pages now properly register after parent category exists

## 004 - BazCore Options Integration
- Options panel now fully powered by BazCore:RegisterOptionsTable()
- Removed custom slider, checkbox, and corner picker controls
- All styling (panels, headers, scroll bars) inherited from BazCore
- Per-module settings pages auto-generated as BazCore subcategories

## 003 - Options Panel Polish
- Two-column bordered panel layout for settings pages
- Yellow headers and titles matching Baz Suite style
- Minimap button now opens settings panel
- Fixed modules page double-rendering on revisit
- Slider value text properly anchored within column bounds

## 002 - Built-In History
- History system now built into the main addon (no separate BNC-History required)
- History stored directly in BazNotificationCenterDB
- Notifications automatically saved to persistent history
- Removed history buffer flush system (no longer needed)

## 001 - Initial Release
- Rebranded from WNC (WoW Notification Center) to BazNotificationCenter
- Integrated with BazCore framework (replaces LibStub, LibDataBroker, LibDBIcon)
- All 20 notification modules bundled into a single addon
- Modules: Achievements, Auction, Calendar, Collections, Group, Instance, Inventory, Keystone, Loot, Mail, Professions, Quests, Rares, Reputation, Social, System, TalkingHead, Vault, XP, Zones
- New options panel layout: user manual main page, Settings subcategory, Modules subcategory, per-module settings subcategories
- Object pooling now uses BazCore:CreateObjectPool()
- Uses BazCore minimap button instead of LibDBIcon
- Slash commands: /bnc, /baznotify
- Open plugin API: any addon can call BNC:RegisterModule() and BNC:Push()
