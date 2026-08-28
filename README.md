<h1 align="center">:snowflake: McGilly17's Nix Config :snowflake:</h1>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

Please dont take any of this repo as my own work. I am merely standing on the shoulders of giants like Ryan Yin, Emergent Mind, Mysterio77 and about 100 others. My dotfiles are a frankenstein made from many of [these](#acknowledgements) amazing engineers work.

> [!IMPORTANT]
>
> **Disclaimer:** _This config is currently only setup to work with two macOS hosts_ some boilerplate
> is baked in for when I expand the configs to my WS2 rig, Linux machines and servers.

## Table of Contents

- [Feature Highlights](#feature-highlights)
- [Structure](#structure-quick-reference)
- [Components](#components)
- [Secrets Management](#secrets-management)
- [Usage](#usage)
- [Ongoing](#ongoing)
- [Questions](#questions)
- [Guidance and Resources](guidance-and-resources)
- [Acknowledgements](#acknowledgements)
- [Roadmap of TODOs](TODO.md)

---

## Feature Highlights

- Flake-based multi-host, multi-user NixOS + Darwin and Home-Manager configurations
- Core configs for hosts and users
- Somewhat modular, optional configs for user and host-specific needs
- **secrets** management using **sops-nix**
- Catppuccin **everywhere** with nix

## Structure Quick Reference

At a high level, the configs flow from the flake.nix, through the hosts folder and into the users folder. Each host will bring in `/modules` to bring in OS level configurations that are either for darwin, nixos or common but are not specific to the host. Host specific changes can be made in the host folder `/hosts/HOSTNAME`.

These configs use home-manager to manage user level configurations. Users to be brought into a host are set in the host file. All user specific configurations are done in the users foler `/users/USERNAME`. There is some complexity when working with darwin as it is often still better to install apps either through MAS (appstore) or brew and as such they arent managed in home-manager, rather through darwin. I will no doubt iron out some of these issues as I start to manage configs across nixos and darwin builds. For the moment it is what it is.

The strucutre allows for many hosts (nixos, darwin and probably WS2?) and many users. There are, however, some user limitations in darwin given that a user has to be set on setup. I have never tried to workaround it, instead i just always assume there will be at least my main users `michael` in any darwin computer. At somepoint if I actually need to, ill add a second uer to a mac but that need hasnt arised yet.

- `flake.nix` - Entrypoint for hosts and user home configurations. Also exposes a devshell for manual bootstrapping tasks (`nix develop` or `nix-shell`).
- `hosts` - Host configurations, rebuilt via `sudo darwin-rebuild switch --flake .#<host>`
  (Darwin) or `sudo nixos-rebuild switch --flake .#<host>` (NixOS). See
  [Adding a New Device](docs/Adding-a-New-Device.md).
  - `bowser` - MacBook Pro 16" M1 Max
  - `glados` - Mac Pro 2019 (Intel)
  - `shodan` - MacBook Air (Apple Silicon)
  - `ganon`, `sephiroth`, `zenith-1/2/3`, `ocelot`, `mantis` - NixOS hosts
- `users/<user>` - Home-manager configurations, built automatically during host rebuilds.
  - `common` - shared home-manager configurations consumed the user's machine specific ones present for user across all machines. This is a hard rule!
    - `core` - Core tools and configs for terminal
    - `tui` - Home-manager configurations for anything CLI or TUI
    - `desktop` - Home-manager configurations for anything desktop, these will only be imported by machines that run a GUI
    - `shells` - Different shell configurations. Currently only zsh is configured here.
  - `darwin` - Darwin (MacOS) specific home-manager configurations for that user
  - `hosts` - Host specific configurations
  - `linux` - Linux specific home-manager configurations for that user
- `resources` - Resources used throughout the config
  - `lib` - Custom libraries used throughout the nix-config
    - `default.nix` - libraries to make import paths more readable.
  - `vars` - Custom variables used throughout the nix-config. Most of the variables are focused on the primary user across all hosts.
- `modules` - Global Darwin and Linux configurations
  - `darwin` - Apps, system and core nix configurations for Darwin (MacOS) devices. Brew is a necessary evil still and it is defined here.
    - `wm` - Configuration for window management on MacOS with Yabai and skhd
  - `nixos` - will contain any global nixos configurations
  - `common` - Common configuration at the host level that is agnostic of OS
- `overlays` - Custom modifications to upstream packages.

## Components

---

|                             | Linux &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | MacOS &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; |
| --------------------------- | ----------------------------------------------- | ------------------------------------------------------ |
| **Shell:**                  | zsh + Starship                                  | zsh + Starship                                         |
| **WM:**                     | TODO                                            | Yabai                                                  |
| **Launcher:**               | TODO                                            | skhd                                                   |
| **Editor:**                 | NixVim                                          | NixVim                                                 |
| **Terminal Emulator:**      | Kitty + Zellij                                  | Kitty + Zellij                                         |
| **Browser:**                | Chrome                                          | Chrome                                                 |
| **Color Scheme**            | Catppuccin                                      | Catppuccin                                             |
| **System resource monitor** | Btop                                            | Btop                                                   |
| **File Manager**            | Yazi                                            | Yazi                                                   |

---

## Secrets Management

Secrets for this config are stored in a private repository called nix-secrets that is pulled in as a flake input and managed using the sops-nix tool.

If you have any questions about secrets using nix. Please see the following epic resources:

- [EmergentMind's Spectacular Youtube Series](https://www.youtube.com/watch?v=6EMNHDOY-wo)
- [LGUG2Z's Epic blog post that explains the different options you have when encrypting with nix](https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/)
- Ryan4Yin and Misterio77 also have implementations that are worth looking at.

## Usage

> [!IMPORTANT]
>
> **Disclaimer:** _This is not a "community framework" or "NixOS distribution"._
> Please do not use it like one. It is a relatively poor and somewhat frankenstein
> implementation from many, many people (see [Acknowledgements](#acknowledgements)) who are far smarter
> than I.
>
> That said, I would absolutely love to talk and [learn](#questions) more about nix and configs. If anyone would like to critique,
> comment, contribute. Please feel free in Issues or PRs.

## Ongoing

See [TODOs](/TODO.md)

In short, I will be constantly tinkering with these configs. I want to improve the use of secrets, investigate remote deployments,
use Just files and many other fun things.

## Questions

I have about 1million questions on Nix and will ask them in due course on discourse. However, if anyone stumbles upon this and has answers, please let me know!

- Is there anywhere documented in the nix world a place where I can see how maintainers of NixPkgs convert the configurations in nix into the format the underlying package needs. For Example: [gitui](https://github.com/extrawurst/gitui), you can pass the key `keyConfig` into the [nix config](/users/michael/common/tui/gitui.nix), it is a multi line string with all the keybindings. Now, in the [Gitui NixPkgs](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/gi/gitui/package.nix#L56) to me, it wasnt immediately obvious that this was how you do this. Is there a dictionary of these things somewhere that I havent found?
- When developing actively on this set of configs, every change I make, I have to run a darwin-rebuild and switch out to the new config. When making many small changes this can be pretty time intensive. Is there a better way when in active development (i.e setting up ones NeoVim configs) that allows for much quicker iteration before then migrating to the full nix config?

## Guidance and Resources

If you are remotely interested in Nix and configs, I found the below a pretty good starting point. I then did the vast majority of my learning
by looking through other peoples configs and watching @EmergentMind and @VimJoyer's amazing youtube content.

- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) - an excellent introductory book by Ryan Yin
- [Official Nix Documentation](https://nix.dev)
  - [Best practices](https://nix.dev/guides/best-practices)
- [Noogle](https://noogle.dev/) - Nix API reference documentation.
- [MyNixOS](https://mynixos.com/) - Very helpful documentation on packages, also helpful videos etc
- [Official NixOS Wiki](https://wiki.nixos.org/)
- [EmergentMind's Youtube](https://www.youtube.com/@Emergent_Mind)
- [VimJoyer's Youtube](https://www.youtube.com/@vimjoyer)

## Acknowledgements

Thank you to the amazing engineers work that I have built my dotfiles on top of, these are but a few!

- [Misterio77] (<https://github.com/Misterio77/nix-config?tab=readme-ov-file>)
- [EmergentMind] (<https://github.com/EmergentMind/nix-config>)
- [ryan4yin] (<https://github.com/ryan4yin/nix-config/tree/main>)
- [redyf] (<https://github.com/redyf/Neve>)
- [pietersp] (<https://github.com/pietersp/dotfiles>)
- [Zumorica] (<https://github.com/Zumorica/GradientOS/>)
- [ritiek] (<https://github.com/ritiek/dotfiles>)
- [the-argus] <https://github.com/the-argus/nixsys>)
- [andreykaipov] (<https://github.com/andreykaipov/nix>)
- [martaver] (<https://github.com/martaver/dotfiles>)
- [mtyurt] (<https://github.com/mtyurt/dotfiles>)
