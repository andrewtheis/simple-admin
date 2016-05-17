# Simple Admin
An easy and fun admin GUI for Garry's Mod.

## Installation
Extract the zip to the following directory on your hard-drive:

`<Steam-directory>/steamapps/<Steam-username>/garrysmod/garrysmod/addons/`

## Adding Admins
Simply edit the users.txt file that is located in your Garry’s Mod settings directory. Garry has already included instructions and examples in the users.txt file.

## Adding VIP’s
Admins can already use reserved slots, but if you want other players to be able to use reserved slots you need to create a VIP group in your users.txt file:
```
"Users"
{
  "superadmin"
  {
    "AMT"   "STEAM_0:1:10187637"
  }

  "admin"
  {
  }

  "vip"
  {
    "garry"   "STEAM_0:1:7099"
  }
}
```

## Configuring Simple Admin
To configure Simple Admin browse to the below directory and edit sa_config.lua to your liking.

`<Garry’s Mod install dir>/addons/simple-admin/lua/`

## Binding the Admin Menu
Open up console ([~]), type in the following, and press [Enter].
bind x "+sa_menu"

Now, just press [X] at any time to bring up the admin menu.

## Using the Admin Menu
Using Simple Admin (SA) is pretty straightforward. In the Players tab you can select players and then apply actions to them using the buttons below the player list. You can select more than one player using your [Ctrl] and [Shift] keys.

In the Event tab you can select the weapons you want, choose whether or not to include admins, and then start the event. You can create an Event Spawn Point (Entities tab - Simple Admin) where you want players to spawn during the event.

In the Server tab you can start votes and run rcon commands without the need for an rcon password.
