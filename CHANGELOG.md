# BazNotificationCenter Changelog

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
