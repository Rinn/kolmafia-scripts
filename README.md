# kolmafia-scripts
Various scripts for KoLMafia. 

## AcquireBuff
Automatically get a buff from a Kingdom of Loathing buffbot.

`svn checkout https://github.com/Rinn/kolmafia-scripts/trunk/AcquireBuff/`

### zlib Settings
* `acquireBuff_last_update`: Last time buffbot data was parsed. Internal use only do not modify.
* `acquireBuff_max_price`: Maximum meat to spend on a buff. Default 1000.
* `acquireBuff_wait_time`: Time to wait for a buffbot to respond in seconds. Default 30.
* `acquireBuff_ignore_philanthropic`: Whether to requires philanthropic (extremely low cost) buffs. Default false.

[Thread](https://kolmafia.us/showthread.php?4048-acquireBuff-Get-a-buff-from-a-buffbot])

## CreationCost
Estimate optimized creation cost for an item, similiar to internal KoLMafia acquire logic.

`svn checkout https://github.com/Rinn/kolmafia-scripts/trunk/CreationCost/`

## FamiliarDrops
Automatically get profitable drops from familiars.

`svn checkout https://github.com/Rinn/kolmafia-scripts/trunk/FamiliarDrops/`

### zlib Settings
* `FamiliarDrops_Enabled`: If this script is enabled. Ignored if you import the script and call familiar_swap().
* `FamiliarDrops_MinMpa`: The minimum mpa required to swap to a familiar.
* `FamiliarDrops_MinMpaItem`: Use the mall price of this item for minmpa, overrides FamiliarDrops_MinMpa if not none.
* `FamiliarDrops_AssumeWorst`: Assume the worst turn count instead of the median, not recommended.
* `FamiliarDrops_Banned`: Comma separated list of familiars to never switch to.
* `FamiliarDrops_DefaultFam`: If no familiars are found, switch to this familiar by default.

[Thread](https://kolmafia.us/showthread.php?18051-FamiliarDrops-Get-profitable-drops-from-familiars])

## PvPHistory
Log PvP records to a data file. KoL only stores the most recent 1000 records, so you will get partial data if run in the middle of a season.

`svn checkout https://github.com/Rinn/kolmafia-scripts/trunk/PvPHistory/`

## RelaySkills
A relay override that modifies the game character page and groups all of a characters skills.

`svn checkout https://github.com/Rinn/kolmafia-scripts/trunk/RelaySkills/`

[Thread](https://kolmafia.us/threads/charsheet-php-group-skills-by-character-class.1578/)

## RelaySnapshot
Shows your CheeseCookie snapshot in the relay browser. See [this thread](http://forums.kingdomofloathing.com/vb/showthread.php?t=218735) for more details.

`svn checkout https://github.com/Rinn/kolmafia-scripts/trunk/RelaySnapshot/`

[My Snapshot](https://cheesellc.com/kol/profile.php?u=epicgamer)
