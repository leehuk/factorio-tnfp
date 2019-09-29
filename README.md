![TNfP](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-logo.png)
## Train Network for Players (Factorio Mod)

### About
QoL and advanced functionality for players using trains for transport, including improved destination selection dialog and automated train calling.

There are two core concepts for this mod:

* When onboard a train, provide the ability to go to any train stop (or even just a rail segment) easily and without manually modifying schedules.
* Allow one (or more) trains to be designated for player use, which can then be automatically dispatched to wherever the player is.  In effect, player trains become more like taxis.

### Station Select Dialog
The station select dialog provides a quick way of moving between stations and can be opened when onboard any train via either the input hotkey (ALT-P default) or toolbar shortcut:

![TNfP Station Select](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-stationselect.jpg)
&nbsp;
![TNfP Station Select Search](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-stationselect-search.jpg)

* Quickly filter between stations in the trains schedules, TNfP designated stations or all stations.
* Filter the list of stations further via the search bar.
* Selecting a station will temporarily add it to the trains schedule and dispatch the train there, where it will wait for the player to exit before resuming its previous schedule.
* The railtool button will provide a railtool and open the map, allowing the train to be dispatched to any valid rail segment.

### TNfP Network
If one or more trains are assigned into a TNfP network they can be automatically dispatched to the players location using the two shortcuts:

![TNfP Shortcut Bar](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-shortcutbar.jpg)

* Request TNfP Train (default ALT-P) will dispatch a train to the nearest valid train stop.  If a request is active, selecting it again will cancel the request.
* Provide TNfP Rail Tool (default SHIFT-ALT-P) will provide a railtool under the cursor, which can be used to select a rail segment to create a temporary stop.

### TNfP Network Creation
Trains are available for players if they have a train stop marked for TNfP use anywhere in their schedule, which is done via a single combinator signal.

To assign trains into a TNfP network:
1. Research trains, train stops and the circuit network.
1. Have a train stop thats only intended for player use.
1. Have a train thats only intended for player use, with the player train stop anywhere in its schedule.
1. Place a Constant Combinator near your personal train stop.
1. Set the combinator to output the new 'TNfP Station' virtual signal (with any value) -- found under 'Signals'.
1. Connect the combinator to the train stop, with either red or green wire.

![TNfP Combinator](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-combinator.jpg)

When dispatching trains TNfP will find the nearest train which has anywhere in its schedule a train stop receiving the 'TNfP Station' signal.

### TNfP Rail Tool
The railtool provides a way of creating temporary train stops and is used by selecting/dragging over an area containing rail segments, from either the standard player view or map view:

![TNfP Rail Tool Selection](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-railtool-selection.jpg)
&nbsp;
![TNfP Rail Tool Stop](https://leehuk.github.io/factorio-tnfp/docs/images/tnfp-screenshot-railtool-station.jpg)

* When onboard a train a new temporary stop will be created at that location, temporarily added to the trains schedule and dispatched there.
* When not onboard a train, a new temporary stop will be created and a player train will be dispatched there from the TNfP network.
* To remove a rail tool from your inventory, drop it on the ground near the player (default 'z') and it will be automatically destroyed.

### Important Notes
This mod should be mostly stable for both single player and multiplayer.  Bug reports, feature requests or any comments are preferred via [github.com](https://github.com/leehuk/factorio-tnfp/) or via the forum.  Please include the crash log and version information about both factorio and the mod in bug reports.

TNfP should be compatible with all mods relating to trains, providing they don't change train schedules or add custom types of train stops.  When used with mods which add custom types of train stops, TNfP will work as follows:

* LTN (Logistic Train Network): TNfP will dispatch to any stop except depots, which are ignored due to conflicts with scheduling trains.  (Thanks to Optera for assistance).
* TSM (Train Supply Manager): TNfP will dispatch to 'Requester' stops, but will completely ignore 'Supplier' stops due to conflicts with scheduling trains.
* Default: TNfP uses a configuration option controlling whether stops are considered safe to dispatch to (and thus ignored) or not.

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