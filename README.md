![TNfP](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-logo.png)
## Train Network for Players (Factorio Mod)

### About
Provides support functionality for a personal train network, dispatching trains to your location and
taking you onward.

### Important Note
**This mod is currently experimental.**  This is the early testing phase, so it may crash.  Bug reports via
[github.com](https://github.com/leehuk/factorio-tnfp/) are preferred, with the crash log and version
information about both factorio and the mod.

**Thie mod in multiplayer mode is highly experimental.**  There's work to be done adding the hooks to handle
players becoming invalid before its multiplayer safe so here be dragons.

### Features
* Build and designate a TNfP network via a simple combinator signal.
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

Once you connect the combinator the train stop becomes a TNfP Station.  Any train with a TNfP Station anywhere in its schedule
then becomes a TNfP Train and available for dispatch.

### Dispatching Trains

Trains can be dispatched either via the default hotkey (ALT-P) or via the shortcut bar.
![TNfP Combinator](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-shortcutbar.jpg)

Once the train arrives and you board, it can optionally display a station selection dialog.

![TNfP Station Select](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-stationselect.jpg)

## Roadmap
For now the focus is ensuring the mods stable and working on multiplayer support.  Feature wise, the focus
is on ensuring flexibility around TNfP and how its used.