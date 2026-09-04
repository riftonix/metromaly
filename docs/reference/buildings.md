# Buildings

Building names are presented in English. Costs and resource changes use the project resources `Rubles`, `Food`, and `People`. A positive resource change is production per strategic tick. Workers are occupied while the building is active.

Recruitment names match the unit identifiers in [Unit Leveling](unit-leveling.md). A building unlocks both the standard and elite versions of each listed unit.

## Player Buildings

| Building | System Name | Type | Requires or Replaces | Ruble Cost | Food Cost | People Added | Workers Occupied | Rubles per Tick | Food per Tick | Recruitable Units | Special Effect | Station Limit | Player Limit | Storage | Build Time |
| --- | --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | ---: | ---: | ---: | ---: |
| Mushroom Farm | `MushroomFarm` | Construction | `Forpost` | 200 | 0 | 0 | 3 | 0 | 10 | None | None | None | None | None | 1 |
| Pig Farm | `PigFarn` | Construction | `Depo_forpost` | 350 | 0 | 0 | 6 | 0 | 20 | None | None | None | None | None | 2 |
| Arms Workshop | `ArmsWorkshop` | Construction | `Barracks` | 850 | 0 | 0 | 9 | 10 | 0 | `engineer`, `engineer_elite` | None | 1 | None | None | 3 |
| Electrochemical Workshop | `Workshop` | Construction | `TechPark_2_forpost` | 750 | 0 | 0 | 9 | 10 | 0 | `electrician`, `electrician_elite` | None | 1 | None | None | 3 |
| Market | `BigMart` | Construction | `Forpost` | 500 | 0 | 0 | 6 | 10 | 0 | None | None | None | 1 | 20 | 3 |
| Smithy II | `blacksmith_2` | Upgrade | `blacksmith` | 450 | 0 | 0 | 6 | 10 | 0 | `shooter`, `shooter_elite` | `AddTurrel@2` | 1 | None | None | 2 |
| Canteen | `Tavern` | Construction | `Depo_forpost` | 250 | 0 | 0 | 6 | 10 | 0 | `scout`, `scout_elite` | None | 1 | None | None | 3 |
| Arms Workshop II | `ArmsWorkshop_2` | Upgrade | `ArmsWorkshop` | 1,250 | 0 | 0 | 9 | 15 | 0 | `engineer`, `engineer_elite`, `monk`, `monk_elite` | None | 1 | None | None | 2 |
| Electrochemical Workshop II | `Workshop_2` | Upgrade | `Workshop` | 1,000 | 0 | 0 | 9 | 15 | 0 | `electrician`, `electrician_elite`, `chemist`, `chemist_elite` | None | 1 | None | None | 2 |
| Tunnel Lighting | `TunnelLighting` | Construction | `Forpost` | 150 | 0 | 0 | 3 | 15 | 0 | `tramp`, `tramp_elite` | None | 1 | None | None | 1 |
| Smithy | `blacksmith` | Construction | `Depo_forpost` | 300 | 0 | 0 | 6 | 5 | 0 | `shooter`, `shooter_elite` | `AddTurrel@1` | 1 | None | None | 1 |
| Bio Laboratory | `BioLab` | Construction | `Workshop_2` | 3,500 | 0 | 0 | 9 | 50 | 0 | `scientist`, `scientist_elite` | None | 1 | None | None | 25 |
| Mercenary Base | `MercBase` | Construction | `TechPark_2_forpost` | 1,500 | 0 | 0 | 6 | 0 | 0 | `spy`, `spy_elite`, `flamethrower`, `flamethrower_elite` | None | 1 | None | None | 2 |
| Infirmary | `Storage` | Construction | `Depo_forpost` | 450 | 0 | 0 | 3 | 0 | 0 | `medic`, `medic_elite` | None | None | None | 20 | 3 |
| Tent | `Tent` | Construction | `Depo_forpost` | 100 | 0 | 6 | 0 | 0 | 0 | None | None | None | None | None | 1 |
| Barracks | `Barracks` | Construction | `TechPark_forpost` | 700 | 0 | 9 | 0 | 0 | 0 | `sniper`, `sniper_elite`, `machine_gunner`, `machine_gunner_elite` | None | None | None | None | 3 |
| Outpost | `Forpost` | Construction | None | 150 | 0 | 6 | 0 | 10 | 0 | None | None | 1 | None | 20 | 0 |
| Depot | `Depo_forpost` | Upgrade | `Forpost` | 350 | 0 | 9 | 0 | 15 | 0 | None | None | 1 | None | 25 | 2 |
| Tech Park | `TechPark_forpost` | Upgrade | `Depo_forpost` | 750 | 0 | 12 | 0 | 20 | 0 | None | `AddCover@1` | 1 | None | 30 | 3 |
| Tech Park II | `TechPark_2_forpost` | Upgrade | `TechPark_forpost` | 1,250 | 0 | 15 | 0 | 25 | 0 | None | `AddCover@2` | 1 | None | 35 | 5 |

## Non-Player Buildings

These records exist in the source data but are unavailable to the player.

| Building | System Name | Type | Requires or Replaces | Ruble Cost | People Added | Workers Occupied | Recruitable Units | Special Effect | Build Time |
| --- | --- | --- | --- | ---: | ---: | ---: | --- | --- | ---: |
| Mutant Barracks | `barracks_mutants` | Construction | `TechPark_forpost` | 250 | 6 | 0 | `mutant`, `mutant_elite` | None | 3 |
| Archive | `Archive` | Construction | `TechPark_2_forpost` | 1,800 | 0 | 6 | `librarian`, `librarian_elite` | None | 5 |
| Wolf Den | `WolfDen` | Construction | `Depo_forpost` | 500 | 0 | 3 | `wolf`, `wolf_elite` | None | 2 |
| Greenhouse | `Greenhouse` | Construction | `TechPark_forpost` | 650 | 0 | 6 | `plant`, `plant_elite` | None | 3 |
| Insectarium | `Insectarium` | Construction | `TechPark_forpost` | 600 | 0 | 6 | `woodlouse`, `woodlouse_elite` | None | 3 |
| Rat Nest | `RatNest` | Construction | `Depo_forpost` | 300 | 0 | 3 | `rat`, `rat_elite` | None | 2 |
| Vermin Court | `VerminCourt` | Construction | `RatNest` | 900 | 0 | 6 | `rat_king`, `rat_king_elite` | None | 4 |
