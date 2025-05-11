# Homigrad

> [!NOTE]
> This is a fork of [Harrison's Homigrad Servers version](https://github.com/harrisoniam/homigrad).
> It's tailored for personal use by me and my friends. Please don’t expect features or updates that cater to everyone.

## What is Homigrad?

Homigrad is a gamemode that expands on an existing gamemode called 'Homicide,' which is inspired by Trouble in Terrorist Town (TTT) and Murder.\
It features a somewhat realistic health and movement system and offers several sub-modes, including Team Deathmatch (TDM), Deathmatch, and Hide and Seek.

## Installation | Workshop

> [!WARNING]
> Don't forget to delete the `homigrad-main` in the addons folder if you have one.

[Click Here](https://steamcommunity.com/sharedfiles/filedetails/?id=3401451044)

## Installation | Manual

1. [Download the repository](https://github.com/JonnyBro/homigrad/archive/refs/heads/main.zip).
2. Subscribe to this collection: [\*click\*](https://steamcommunity.com/sharedfiles/filedetails/?id=3393369855).
3. Extract the `homigrad-main` folder and place it in `your_gmod_install/garrysmod/addons` folder or server’s `addons` directory.
4. Move the `data` folder from `homigrad-main` to `your_gmod_install/garrysmod/`.
   - This folder contains some premaid spawnpoints data that are used in some modes.
5. Ensure the gamemode is set to `Homigrad` (use `+gamemode homigrad` for servers).

I recommend a tickrate from **99** to **128** for better physics, but people reported that **66** works too.\
On a dedicated server, please use `+tickrate number`. On the client (when you host a server from the game itself), tickrate is dependent on the fps_max concommand.

## TODO

- [ ] Move Homigrad's commands to ULX (i like ulx).
- [ ] Find and fix existing bugs (there are many to address).

## Known Bugs

- [ ] Listed as `FIXME` and `NOTE` in comments.

## Frequently Asked Questions

### What language is your fork in?

My fork supports English, Russian, and Ukrainian languages!

### Can I use movement/weapons code from your fork in other gamemodes (Sandbox, TTT, etc)?

The movement system and weapons from Homigrad are not directly compatible with other gamemodes. However, if you're proficient, you might explore [Harrison’s movement-addon branch](https://github.com/harrisoniam/homigrad/tree/movement-addon).

### Can I customize your fork for my server?

You’re free to modify the files, adjust values, and tweak the code to suit your server’s needs. Just don't forget where you got this and leave a star :3

### Can I create my own gamemode using your fork?

Yes! Just like the original repo, this project is under the MIT License, so you’re welcome to use it as a base. Contributions are also encouraged — feel free to submit a pull request.

## Credits

- **Sadsalat, Useless, Mr. Point**: For creating the original Homigrad and making it open source. The original repository is available [here](https://github.com/sadsalat/Orignal-Homigrad).
- **Harrison's Servers**: For open-sourcing their version (I wasted all of my NY holidays messing with workshop version (╯‵□′)╯︵┻━┻).
- **ChatGPT**: Rewriting my shitty README.
- **My friend DeXToR**: Playtesting big time and Ukrainian translation.
