![TNfP](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-logo.png)
## Train Network for Players (Factorio Mod)

### About
Provides support functionality for a personal train network, dispatching trains to your location and
taking you onward.

This mod can be safely added and removed to a new or existing playthrough.

### Important Notes
**This mod is currently beta.**  This mod should be mostly stable, though there is the possibility of it
causing a crash.  Bug reports via [github.com](https://github.com/leehuk/factorio-tnfp/) are preferred or
via the forum.  Please include the crash log and version information about both factorio and the mod.

Multiplayer mode should work without any major issues, though has not been tested.

### Features
* Build and designate a TNfP network via a single combinator signal.
* Dispatch personal trains to any train stop nearby.
* Dispatch either via an input hotkey or the shortcut bar.
* Station selection dialog when you board a train to take you onward.
* Controllable behaviour and timeouts for dispatching and arrivals.
* Controllable levels of notifications.

### Setup Guide
1. Ensure you've researched trains and train stops.
1. Ensure you have a train stop thats only intended for player use, with a train assigned to stop there.
1. Craft a Constant Combinator and place it near your personal train stop.
1. Set the combinator to output the new 'TNfP Station' virtual signal, found under 'Signals'.
1. Connect the combinator to the train stop, with either red or green wire.

![TNfP Combinator](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-combinator.jpg)

Once you connect the combinator the train stop becomes a TNfP Station.  If a train has a TNfP Station
anywhere in its schedule then it becomes a TNfP Train and available for dispatch.

### Dispatching Trains

Trains can be dispatched either via the default hotkey (ALT-P) or via the shortcut bar.
![TNfP Combinator](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-shortcutbar.jpg)

When dispatching trains, TNfP will prioritise as follows:
1. A TNfP train the player is currently in.
1. A TNfP train stop with an unallocated train already waiting.
1. A TNfP train stop.
1. A standard train stop, if it is not blocked by another train.

If TNfP needs to dispatch a train to a player, it will dispatch the closest valid and unallocated train
based on straight line distance.

Once the train arrives and you board, it can optionally display a station selection dialog.

![TNfP Station Select](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-stationselect.jpg)

## Roadmap
For now the focus is ensuring the mods stable and deciding how to handle a status query when a request is in
progress (i.e. pressing the hotkey again), before potentially looking at dynamically creating temporary stops.