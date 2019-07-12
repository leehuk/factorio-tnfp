![TNfP](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-logo.png)
## Train Network for Players (Factorio Mod)

### About
Provides QoL functionality to improve using trains for player transport.

### Key Features
* (Optionally) Build and designate a TNfP network via a single combinator signal.
* Dispatch TNfP trains to any train stop nearby.
* Provides a TNfP Rail Tool (selection tool) which can create new temporary train stops from the map view and dispatch the current train the players is on there, or dispatch a TNfP train to the player to pick them up.
* Station selection dialog when you board a train to take you onward.
* This mod can be safely added and removed to a new or existing playthrough.

### Misc Features
* Configurable input hotkey (ALT-P default) or shortcut to dispatch trains.
* Configurable input hotkey (SHIFT-ALT-P default) or shortcut for TNfP Rail Tool.
* Controllable behaviour and timeouts for dispatching and arrivals.
* Controllable levels of notifications.

### Important Notes
**This mod is currently beta.**  This mod should be mostly stable, though there is the possibility of it causing a crash.  Bug reports via [github.com](https://github.com/leehuk/factorio-tnfp/) are preferred or via the forum.  Please include the crash log and version information about both factorio and the mod.

Multiplayer mode should work without any major issues, though has not been tested.

### QoL Mode vs TNfP Mode
This mod is designed to work both as a pure Quality of Life mod or in TNfP mode with more advanced dispatch functionality.

For players who prefer pocket trains or borrowing trains from the network this mod provides access to QoL enhancements such as a quick station selection dialog and the ability to dispatch the current train to a rail segment from the map view via a new temporary station.

In TNfP mode the player can mark one or more train stops as TNfP stations and then automatically dispatch trains from those stations to any train stop near them, or to a rail segment near them via the TNfP Rail Tool.  Once they board, this can automatically trigger the station selection dialog.

### Mod Compatibility
TNfP should be compatible with all mods relating to trains, providing they don't change train schedules or add custom types of train stops.

When used with mods which add custom types of train stops, TNfP will work as follows:
* LTN (Logistic Train Network): TNfP will dispatch to any stop except depots, which are ignored due to conflicts with scheduling trains.
* TSM (Train Supply Manager): TNfP will dispatch to 'Requester' stops, but will completely ignore 'Supplier' stops due to conflicts with scheduling trains.
* Default: TNfP uses a configuration option controlling whether stops are considered safe to dispatch to (and thus ignored) or not.

### Shortcut Bar and Input Hotkeys
TNfP provides two additional shortcuts, both of which have input hotkeys:

![TNfP Combinator](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-shortcutbar.jpg)

Request TNfP Train Shortcut (ALT-P).

* When onboard a train, in either QoL Mode or TNfP mode this shows the station selection screen.
* In TNfP Mode dispatches a TNfP train to the nearest valid train stop to the player, or cancels the current request if active.

Provide TNfP Rail Tool (SHIFT-ALT-P).

* Places a TNfP Rail Tool into the players hand.

### Station Selection Dialog
The station selection dialog provides a quick way of moving between stations:

![TNfP Station Select](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-stationselect.jpg)

When a station is chosen the train dispatches itself there and then waits for the player to exit the train.  Once the player exits the train it resumes its previous schedule, or the player can stay on the train and use 'Request TNfP Train' again to move to another location.

### TNfP Rail Tool
The TNfP Rail Tool provides an improved way of creating temporary train stops.  Once one or more valid rails are selected a new temporary train stop will be created at that location:

![TNfP Rail Tool Selection](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-railtool-selection.jpg)
&nbsp;
![TNfP Rail Tool Stop](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-railtool-station.jpg)

The rail tool works from both the standard player view and the map view.

* When onboard a train, in either QoL Mode or TNfP mode this sends the train to the new temporary stop and waits for the player to exit the train, before resuming its previous schedule.
* In TNfP Mode dispatches a TNfP train to that temporary stop to pickup the player.

When using the rail tool from on board a train the trains wait condition will be the player exiting the train, at which point it will resume its original schedule.

To remove a rail tool from your inventory, drop it on the ground near the player (default 'z') and it will be automatically destroyed.

### TNfP Network
Creating a TNfP network allows you to dispatch TNfP trains to any valid train stop nearby or via the rail tool to a new temporary station.

To enable TNfP Mode:
1. Ensure you've researched trains and train stops.
1. Ensure you have a train stop thats only intended for player use, with a train assigned to stop there.
1. Craft a Constant Combinator and place it near your personal train stop.
1. Set the combinator to output the new 'TNfP Station' virtual signal, found under 'Signals'.
1. Connect the combinator to the train stop, with either red or green wire.

![TNfP Combinator](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-combinator.jpg)

Once you connect the combinator the train stop becomes a TNfP Station.  Any train which has that train stop anywhere in its schedule then becomes a TNfP train and available for dispatching to the player.

This allows the player to use the existing train network for personal use, without the requirement to add personal stations at every location or outpost, or fill a trains schedule with all possible locations.  Equally when players have an extensive web of personal stations, the various station selection dialog views allow moving around this network easier.

### Technical Information

General technical information, for the curious.

#### Dispatching Logic

When dispatching trains, TNfP will prioritise as follows:
1. A TNfP train the player is currently in.
1. A TNfP train stop with an unallocated train already waiting.
1. A TNfP train stop.
1. A standard train stop, if it is not blocked by another train.

If TNfP needs to dispatch a train to a player, it will dispatch the closest valid and unallocated train based on straight line distance.

TNfP will apply a configurable arrival timeout for the train to arrive at the requested location.  If the train does not arrive before this timeout, the request will be cancelled and the train will have its original schedule restored.

#### Arrival Logic

The destination train stop for a TNfP dispatch request is added with a standard station wait condition, using a configurable time 'Boarding Timeout'.  If the player does not board in this time, TNfP will detect the train departing and restore its original schedule.  If the player does board the train, it will immediately reset the schedule and perform the configurable 'Boarding Behaviour'.

#### Boarding Behaviour

When a player boards a dispatched train, the original schedule is restored but the train is immediately switched to manual mode and so will not resume the schedule.  If TNfP is configured to display the optional station selection dialog this will appear, allowing the player to select an onward destination.

If the station selection dialog is closed or the player exits the train, it will remain in manual mode but with its original schedule.

#### Redispatch Behaviour

When a player has selected an onward destination, TNfP will add the new station with a standard station wait condition of 'Passenger Not Present'.  This station will then remain in the schedule until it becomes true (i.e. the passenger leaves the train), or the passenger selects another onward destination.

#### Temporary Station Cleanup

TNfP relies on a particular quirk in factorio, in that once a train is waiting at a station -- if the station is destroyed/deleted, factorio will continue to wait until the station condition is true before departing.  This allows TNfP to clean up the temporary stations as early as possible, but with the caveat the schedule looks a little odd.