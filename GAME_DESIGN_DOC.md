# Web Diablo-Like RPG - Game Design Document

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Core Game Systems](#core-game-systems)
3. [Combat Mechanics](#combat-mechanics)
4. [Character Progression](#character-progression)
5. [Loot & Equipment](#loot--equipment)
6. [World Design](#world-design)
7. [Meta-Progression](#meta-progression)
8. [Town & Services](#town--services)
9. [Technical Specifications](#technical-specifications)
10. [Development Roadmap](#development-roadmap)
11. [Risk Assessment](#risk-assessment)

---

## 1. Executive Summary

### Game Overview
**Title:** [To Be Determined]  
**Platform:** Web Browser (Mobile Responsive)  
**Genre:** Action RPG / Incremental  
**Target Audience:** Casual to Hardcore RPG Players  

### Core Vision
A web-based action RPG featuring turn-based combat with Action Point economy, procedural dungeons, deep character customization, and a prestige ascension system that encourages multiple playthroughs with progressive power increases.

### Key Features
- ⚔️ **Turn-based Combat** with Action Point management
- 🎯 **Focus & Enhancement Systems** for tactical depth
- 📈 **Progressive Skill System** with class specializations
- 🎰 **Loot & Gambling** mechanics for equipment progression
- 🔄 **Ascension System** for meta-progression
- 🌍 **Procedural Dungeons** with hand-crafted boss encounters

---

## 2. Core Game Systems

### 2.1 Primary Gameplay Loop

```
EXPLORE → COMBAT → LOOT → PROGRESS → RETURN TO TOWN
    ↓        ↓       ↓        ↓           ↓
  Dungeons  Turn-   Items   Character   Upgrade
  & Zones   based   & Gold  Building    & Trade
```

### 2.2 Secondary Loop (Meta-Progression)

```
CHARACTER BUILD → ZONE PROGRESSION → EQUIPMENT OPTIMIZATION → ASCENSION
        ↓               ↓                    ↓                ↓
   Skills &        Unlock New         Find/Craft         Reset for
   Attributes      Areas             Better Gear         Bonuses
```

---

## 3. Combat Mechanics

### 3.1 Action Point (AP) System

#### Core Mechanics
| Character Level | Base AP | Description |
|----------------|---------|-------------|
| 1 | 3 AP | Very limited actions |
| 25 | 6 AP | Growing tactical options |
| 50+ | 8 AP | **Universal Soft Cap** |
| 50+ with High Dex | 9+ AP | Post-soft-cap scaling |

#### Dexterity Scaling System

**Pre-Soft-Cap (Levels 1-50):**
- **Acceleration Formula:** Every 10 dexterity = +1 effective level
- **Benefit:** Reach comfortable AP earlier, not higher maximums
- **Example:** Level 20 + 100 dex = Level 30 for AP calculation

**Post-Soft-Cap (Level 50+):**
- **Fibonacci Scaling:** Exponentially increasing dex requirements

| AP Level | Required Effective Dex | Total Investment |
|----------|----------------------|------------------|
| 9th AP | 50 | Moderate |
| 10th AP | 100 | Significant |
| 11th AP | 150 | Heavy |
| 12th AP | 250 | Extreme |
| 13th AP | 400 | Elite |
| 14th AP | 650 | Legendary |

### 3.2 Combat Actions & Costs

| Action Type | AP Cost | Description |
|-------------|---------|-------------|
| Basic Attack | 1-3 AP | Standard weapon damage |
| Advanced Skills | 3-6 AP | Powerful class abilities |
| Movement | 1 AP | Per tile/position |
| Items | 1-2 AP | Potions, scrolls |
| Defend | Variable | 50% damage reduction + 10% counter |
| Focus | 1/2/3/4 AP | Build focus stacks (escalating cost) |

### 3.3 Focus System

#### Focus Stack Mechanics
- **Stack Building:** Each Focus action adds +1 stack (max 4)
- **Multiplicative Bonus:** +25% per stack (×2.0 at max stacks)
- **Applications:** Damage, healing, status chances, critical hits
- **Consumption:** ANY beneficial action consumes ALL stacks
- **Maintenance:** Lose 1 stack after 3 consecutive non-Focus actions

#### Focus Progression Table
| Focus Stacks | AP Cost This Turn | Total AP Investment | Damage Multiplier |
|--------------|-------------------|-------------------|-------------------|
| 1 | 1 AP | 1 AP | ×1.25 |
| 2 | 2 AP | 3 AP | ×1.5 |
| 3 | 3 AP | 6 AP | ×1.75 |
| 4 | 4 AP | 10 AP | ×2.0 |

### 3.4 Enhancement System

#### Enhancement Mechanics
- **Single-Use Modifications:** Enhance skills mid-combat
- **Turn Commitment:** ANY enhancement ends turn immediately
- **Dual Cost:** 1 AP + escalating mana per enhancement
- **Unlimited Stacking:** No caps on enhancement combinations

#### Enhancement Cost Formula
| Enhancements | Mana Multiplier | Example (100 base mana) |
|-------------|-----------------|------------------------|
| +1 | ×1.25 | 125 mana |
| +2 | ×1.56 | 156 mana |
| +3 | ×1.95 | 195 mana |
| +4 | ×2.44 | 244 mana |

#### Enhancement Types

**Universal (Always Available):**
- **Raw Power:** Direct damage/healing increase
- **Critical Chance:** Increase crit probability  
- **Multi-Target:** Hit multiple enemies (damage penalty)

**Skill-Gated Unlocks:**
| Required Skill (Rank) | Unlocked Enhancement | Type |
|----------------------|---------------------|------|
| Critical Strike (5) | Critical Damage | Stackable |
| Weapon Mastery (5) | Armor Penetration | Stackable |
| Elemental Magic (7) | Elemental Conversion | Binary |
| Life Magic (5) | Lifesteal | Stackable |
| Precision (3) | Guaranteed Hit | Binary |
| Advanced Techniques (7) | Echo (25% recast) | Binary |

### 3.5 Turn Structure & Recovery

#### Turn End Conditions
1. Manual end turn
2. AP depleted to 0  
3. Any skill enhancement used

#### AP Recovery System
| Previous Turn Action | Next Turn Recovery |
|---------------------|-------------------|
| Normal actions | 60% of max AP |
| Enhancement used | 20-40% of enhancement cost + remaining AP |

---

## 4. Character Progression

### 4.1 Class System

#### Starting Classes
| Class | Privileged Skills | Primary Stats | Build Focus |
|-------|------------------|---------------|-------------|
| **Warrior** | Melee weapons, Defense, Strength skills | STR/CON | Tank/Melee DPS |
| **Mage** | Elemental magic, Mana management, INT skills | INT/WIS | Spell damage/Utility |
| **[Future]** | TBD | TBD | TBD |

**Class Benefits:**
- 25% discount on privileged skill costs
- No AP disadvantages - all classes reach 8 AP naturally
- Flexible stat allocation within class themes

### 4.2 Core Attributes

| Attribute | Primary Effects | Secondary Effects |
|-----------|----------------|-------------------|
| **Strength** | Physical damage, Melee accuracy | Carrying capacity |
| **Dexterity** | Ranged damage, Dodge chance | **Initiative, AP scaling** |
| **Intelligence** | Magical damage, Mana pool | Spell accuracy |
| **Constitution** | Health points, Health regen | Status resistance |
| **Wisdom** | Mana regeneration, Spell crits | Experience gain |
| **Charisma** | Merchant prices, Quest rewards | Gambling luck |

### 4.3 Progressive Skill System

#### Skill Cost Structure

**Standard Skills:**
| Tier | Ranks | Points per Rank | Total Cost |
|------|-------|----------------|------------|
| 1 | 1-3 | 1 | 3 points |
| 2 | 4-6 | 4 | 12 points |
| 3 | 7-9 | 7 | 21 points |
| 4 | 10 | 10 | 10 points |
| **Total** | **1-10** | **Variable** | **46 points** |

**Privileged Skills (25% Discount):**
| Tier | Ranks | Points per Rank | Total Cost | Savings |
|------|-------|----------------|------------|---------|
| 1 | 1-3 | 1 | 3 points | 0% |
| 2 | 4-6 | 3 | 9 points | 25% |
| 3 | 7-9 | 5 | 15 points | 29% |
| 4 | 10 | 7 | 7 points | 30% |
| **Total** | **1-10** | **Variable** | **34 points** | **26%** |

#### Skill Investment Examples

| Skill Rank | Standard Cost | Privileged Cost | Savings |
|------------|---------------|----------------|---------|
| Rank 5 | 11 points | 8 points | 27% |
| Rank 7 | 22 points | 16 points | 27% |
| Rank 10 | 46 points | 34 points | 26% |

#### Power Scaling Philosophy
- **Quadratic Acceleration:** Later points provide exponentially more power
- **Continuous Progression:** No artificial rank boundaries
- **Early Accessibility:** Tier 1 provides immediate value
- **Elite Mastery:** Higher tiers require serious commitment

---

## 5. Loot & Equipment

### 5.1 Currency System

| Currency | Value | Primary Uses |
|----------|-------|--------------|
| **Copper** | Base unit | Basic consumables, repairs |
| **Silver** | 20 Copper | Mid-tier equipment, training |
| **Gold** | 1,200 Copper | High-end equipment, gambling |
| **Platinum** | 216,000 Copper | Ascension bonuses, cosmetics |

### 5.2 Equipment Slots

#### Standard RPG Equipment Layout
| Slot Category | Slots | Item Types |
|---------------|-------|------------|
| **Armor** | Head, Body, Arms, Shoulders, Legs, Feet | Helmets, Armor, Gloves, Boots |
| **Jewelry** | 2 Rings, 1 Necklace | Magical enhancement focus |
| **Weapons** | Main Hand, Off-Hand | Weapons, Shields, Special items |

#### Equipment Features
- **Set Bonuses:** Progressive bonuses (2/4/6 pieces)
- **Stat Requirements:** STR/DEX/INT thresholds, no class locks
- **Dexterity Scaling:** Equipment provides effective dex for post-soft-cap AP
- **Dual Wielding vs Shield:** Offense vs Defense/Utility trade-offs

### 5.3 Loot Rarity System

| Rarity | Drop Rate | Color Code | Features |
|---------|-----------|------------|----------|
| **Common** | 60% | White | Basic stats |
| **Uncommon** | 25% | Green | Minor bonuses |
| **Rare** | 10% | Blue | Specialized effects |
| **Epic** | 4% | Purple | Powerful abilities |
| **Legendary** | 1% | Orange | Game-changing items |

---

## 6. World Design

### 6.1 Zone Structure

| Zone Type | Purpose | Features |
|-----------|---------|----------|
| **Town Hub** | Safe area | NPCs, shops, services |
| **Dungeon Zones** | Combat areas | Progressive difficulty |
| **Special Areas** | Unique content | Boss lairs, challenges, treasure vaults |

### 6.2 Content Generation

#### Procedural Systems
- **Dungeon Layouts:** Room templates with randomized connections
- **Enemy Spawns:** Encounter tables scaling with progression
- **Loot Distribution:** Balanced reward pacing algorithms

#### Hand-Crafted Elements
- **Story Beats:** Main progression markers
- **Boss Encounters:** Unique mechanics and premium rewards
- **Special Events:** Rare spawns, mini-games, treasure hunts

---

## 7. Meta-Progression

### 7.1 Ascension System

#### Ascension Triggers
- **Level Cap Reached** OR **Final Zone Completed**
- **Player Choice:** Strategic timing for optimal advantage

#### Reset vs Persistence

| **Resets** | **Persists** |
|------------|--------------|
| Character level | Ascension bonuses |
| Equipment | Unlocked content |
| Zone progress | Cosmetic unlocks |
| Current currency (partial) | Achievement progress |
| | Skill point bonuses |

### 7.2 Meta-Progression Rewards

| Category | Rewards | Impact |
|----------|---------|--------|
| **Power** | Stat multipliers, AP support | Character effectiveness |
| **Content** | New zones, classes, mechanics | Gameplay variety |
| **Quality of Life** | Inventory space, convenience | Player experience |
| **Cosmetic** | Appearances, effects | Personalization |

---

## 8. Town & Services

### 8.1 Core NPCs

| NPC | Primary Service | Additional Functions |
|-----|----------------|---------------------|
| **Merchant** | Buy/sell equipment | Price negotiations |
| **Blacksmith** | Upgrades/crafting | Equipment repair |
| **Gambler** | Loot boxes | Tiered pricing system |
| **Quest Giver** | Missions/bounties | Exploration challenges |
| **Trainer** | Skill allocation | Respec services |
| **Guild Master** | [Future] Guild system | Social features |

### 8.2 Town Services

| Service | Function | Cost Type |
|---------|----------|-----------|
| **Healing** | Full HP/Mana restoration | Free/Copper |
| **Storage** | Extended inventory | Silver/Gold |
| **Training** | Skill learning/upgrading | Skill Points |
| **Repair** | Equipment maintenance | Copper/Silver |
| **Respec** | Redistribute points | Gold/Platinum |

---

## 9. Technical Specifications

### 9.1 Technology Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| **Frontend** | Svelte/SvelteKit (v5) | Modern, efficient, mobile-ready |
| **Backend** | SvelteKit SSR | Unified stack, SEO benefits |
| **Database** | PostgreSQL | Robust, scalable data storage |
| **Deployment** | Docker containers | Scalability and consistency |
| **Graphics** | 2D sprites + WebGL | Performance with visual appeal |

### 9.2 Platform Requirements

| Platform | Requirements | Performance Targets |
|----------|--------------|-------------------|
| **Web Browsers** | Chrome, Firefox, Safari, Edge | 60 FPS, <3s load times |
| **Mobile** | Responsive design, touch controls | AP-optimized interface |
| **Offline** | Local storage sync | Short-term progress retention |

### 9.3 Save System Architecture

| Storage Type | Purpose | Sync Method |
|-------------|---------|-------------|
| **Local Storage** | Immediate saves, offline play | Browser storage |
| **Cloud Storage** | Cross-device persistence | PostgreSQL sync |
| **Import/Export** | Save portability | JSON format |

---

## 10. Development Roadmap

### Phase 1: Core Systems (MVP)
**Timeline: Months 1-3**

- [ ] ⚔️ Combat system (AP, Focus, Enhancement)
- [ ] 👤 Character creation and basic progression
- [ ] 🏰 Single dungeon zone with procedural generation
- [ ] 🎒 Basic loot system (3 rarity tiers)
- [ ] 🏘️ Town hub with essential NPCs
- [ ] 📊 Progressive skill system

### Phase 2: Content Expansion  
**Timeline: Months 4-6**

- [ ] 🎭 Additional character classes
- [ ] 🗺️ Multiple dungeon zones
- [ ] 🌳 Expanded skill trees
- [ ] 🎰 Gambling mechanics
- [ ] 📋 Quest system

### Phase 3: Meta-Progression
**Timeline: Months 7-9**

- [ ] 🔄 Ascension system
- [ ] 📈 Meta-progression rewards
- [ ] ⚔️ Advanced loot mechanics
- [ ] 💎 Premium currency integration

### Phase 4: Polish & Launch
**Timeline: Months 10-12**

- [ ] 📱 Mobile optimization
- [ ] 📺 Ad integration
- [ ] 🎨 Cosmetic systems
- [ ] 🚀 Performance optimization
- [ ] 🧪 User testing and feedback integration

---

## 11. Risk Assessment

### 11.1 Balance Risks

| Risk | Impact | Mitigation Strategy |
|------|--------|-------------------|
| **Dex Over-Investment** | Players focus too heavily on dex | Clear UI showing diminishing returns |
| **Soft Cap Timing** | Level 50 may be poorly timed | Tunable parameters for adjustment |
| **Skill Complexity** | System overwhelms players | Gradual introduction, clear tutorials |
| **Enhancement Costs** | Exponential scaling too harsh/lenient | Multiple tuning parameters |

### 11.2 Technical Risks

| Risk | Impact | Mitigation Strategy |
|------|--------|-------------------|
| **Performance** | Complex calculations slow gameplay | Optimization, caching strategies |
| **Browser Compatibility** | Platform fragmentation | Progressive enhancement approach |
| **Save System** | Data loss or corruption | Multiple backup systems, validation |

### 11.3 Market Risks

| Risk | Impact | Mitigation Strategy |
|------|--------|-------------------|
| **Genre Saturation** | Difficulty standing out | Unique focus/enhancement mechanics |
| **Player Retention** | Short engagement periods | Strong meta-progression hooks |
| **Monetization Balance** | Pay-to-win concerns | Cosmetic/convenience focus |

---

## 12. Monetization Strategy

### 12.1 Revenue Streams

| Stream | Type | Player Value |
|--------|------|-------------|
| **Cosmetics** | Character/equipment skins | Personalization |
| **Convenience** | Inventory space, faster regen | Quality of life |
| **Premium** | Ad-free experience | Uninterrupted gameplay |
| **Gambling** | Premium loot opportunities | Progression acceleration |

### 12.2 Premium Currency Economy

| Earning Method | Amount | Spending Options |
|----------------|--------|------------------|
| **Daily Rewards** | Small | Basic conveniences |
| **Achievements** | Medium | Mid-tier purchases |
| **Ad Viewing** | Variable | Bonus rewards |
| **Direct Purchase** | Large | All options |

---

## Appendices

### A. Future Considerations
- Guild system integration
- PvP combat modes  
- Seasonal events and content
- Advanced crafting systems
- Multiplayer dungeon runs

### B. Reference Materials
- Competitive analysis framework
- Art style guide development
- Audio design specifications
- Localization planning documentation

---

*This document serves as the foundational design specification for the Web Diablo-Like RPG project. All systems are designed to work cohesively while maintaining individual complexity and player engagement.*