![TNfP](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-logo.png)
## Train Network for Players (Factorio Mod)

### About
TNfP makes your factorio train network work for you, the player.

### Important Note
**This mod is currently experimental.**  There's a reasonable amount of complexity and state tracking required for the relatively simple behaviour and with only limited personal testing in solo mode, it may be unstable.

### Features
* Controllable behaviour and timeouts for dispatching and arrivals.
* Dispatch a personal train to any train stop nearby.
* Call trains via either an input hotkey or via the shortcut bar.
* Display a station selection dialog when you board the train.

### How It Works
1. Ensure you've researched trains and train stops, and you have a train stop thats only intended for player use.
1. Craft a Constant Combinator and place it near your personal train stop.
1. Set the combinator to output the new 'TNfP Station' virtual signal, found under 'Signals'.
1. Connect the combinator to the train stop, with either red or green wire.

![TNfP Combinator](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-combinator.jpg)

Once you connect the combinator the train stop becomes a TNfP Station.  Any train with a TNfP Station anywhere in its schedule
then becomes a TNfP Train and available for dispatch:

[Example GIF](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-example.gif)