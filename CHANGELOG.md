# BazNotificationCenter Changelog

## 016 - Fix Rares Module Nil Map Error
- Fixed "bad argument #2 to 'GetVignettePosition'" error in the Rares module when `C_Map.GetBestMapForUnit("player")` returns nil (during loading screens, phasing, or certain instances)
- MapID is now fetched once and nil-checked before passing to `C_VignetteInfo.GetVignettePosition`; if nil, the vignette position lookup is skipped gracefully

## 015 - Retention Default to 7 Days
- Lowered history retention default from 30 days to 7 days — notifications are inherently ephemeral and one week is plenty for "what happened recently"
- Setting is still adjustable (1–90 days) for anyone who wants more

## 014 - History Retention
- Added a retention policy for persistent notification history (default: 30 days)
- Day buckets older than the retention window are pruned at login and after each new notification, so memory usage stays bounded instead of growing forever
- New "History Retention (Days)" range slider in the options page (1–90 days)
- Fixes BNC memory climbing into the MBs after heavy use — prior versions never trimmed persistent history

## 013 - Unified Toast/Card Rendering
- Toasts and notification cards now share a single body factory and populate helper
- Toasts gained a module label in the bottom-right corner so you can see which addon emitted them
- Fixed Rares module firing on vendors, mission NPCs, and other non-rare vignettes
  - Atlas matching was case-sensitive so the existing whitelist never matched — everything fell through to "Rare Spawn"
  - Now lowercases the atlas first and uses an explicit whitelist (VignetteKill, VignetteLoot, VignetteEvent, VignetteBoss)
- Message rows now correctly re-flow when the module label or a long title would overlap

## 012 - Unified Profiles
- Profiles now managed centrally in BazCore settings
- Removed per-addon Profiles subcategory
- Notification history moved to global storage (shared across all profiles)

## 011 - Global Options
- Added Global Options page with overrides for toast duration, sound, and toasts across all modules
- When a global override is enabled, per-module settings are grayed out but retain their local values
- Toast Duration override applies to all module duration settings (any key ending in "Duration")
- Subcategory order: Settings, Profiles, Global Options, Modules

## 008 - Dead Code Cleanup
- Fixed history tab not switching (panel.hasHistory was never set)
- Removed dead IsHistoryAvailable(), LoadHistory(), historyLoaded
- Removed stale on-demand history loading block from Panel.lua
- Updated README to reflect built-in history

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
