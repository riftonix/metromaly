# Game Resources

| Resource | Game Field | Scope | Calculation | Prototype Role |
| --- | --- | --- | --- | --- |
| Rubles | `money` | Faction | Sum of `money@N` from all active buildings. Construction deducts `resourceResources money@N`. | Primary currency for construction, the economy, and upkeep for people assigned to squads |
| Food | `food` | Faction | Sum of `food@N` from all active buildings. | Food resource |
| People | `workers` | Station | A positive `workers` value adds population; a negative value occupies workers. Free people equal total people minus occupied jobs. | Determines how many production buildings can be staffed |
