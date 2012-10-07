Precedence is a raider's dashboard. It shows shot priority countdowns, warnings and timers
that are useful to a hunter or shadow priest who wants to maximize their DPS.

Supported classes:
* Hunters
* Shadow Priests

Shot/spell priorities:
* Configurable priorities
* Key bindings
* Use macros to trigger shots
* Time shots to buffs and debuffs
* Long cooldowns displayed in a useful way
* Delay all abilities during long casts & channeling

Warnings:
* Missing pet
* Incorrect aspects
* Missing hunter's mark
* Wrong weapon equipped
* Growl unexpectedly on/off
* Teleport ring/cloaks equipped

Timers:
* Misdirect applied, active & on cooldown (with target)
* Hunter's mark active
* Serpent sting active
* Mend pet active
* Freeze traps set & triggered (with target)



TODO
-----------------------------------------------------------------------------
* config for priorities

* Extra wait times for high priority shots
* Rules for serpent sting (don't use near end)
* Pet attacking?
* Deactivate/Fade out when dead
* Warn when wearing pvp gear
* Other trap timers
* Other stings

To bind a key, currently:

    /run PREC.options.priorities.p7.bind='ALT-7';

When switching between presets, update the options dialog (else opening and closing it seems to overwrite stuff?)
