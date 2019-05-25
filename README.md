![TNfP](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-logo.png)
## Train Network for Players (Factorio Mod)

### About
TNfP makes your factorio train network work for you, the player.

### Important Note
**This mod is currently experimental.**  It's in early development and there's a reasonable amount of
complexity and state tracking required for the base level of functionality.  With the limited personal
testing in solo mode its had it may be unstable and it may crash.  Bug reports via
[github.com](https://github.com/leehuk/factorio-tnfp/) are preferred, with the crash log.

**This mod is not recommended in multiplayer mode yet.**  There's work to be done handling players becoming
invalid etc so I expect crashes in multiplayer mode -- though the core codes mostly there.  Its a
challenge for me to test though so if you're interested let me know, particularly if theres a possibility
of doing some live debugging/fixing one evening in a Western EU timezone.

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

## Roadmap
There's a fair amount of functionality I'd like to add, particularly around temporary stations and further
boarding options but for now the focus is ensuring the mods stable.