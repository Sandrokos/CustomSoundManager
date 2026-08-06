# Custom Sound Manager

World of Warcraft addon that registers your own sound files with [LibSharedMedia-3.0](https://www.wowace.com/projects/libsharedmedia-3-0) so other addons (WeakAuras, DBM, etc.) can pick them from their sound dropdowns.

## Features

- Add custom sounds by display name and file path
- Registers each sound with LibSharedMedia as `Custom: <name>`
- Play / remove entries from the options panel
- Works with any addon that lists LibSharedMedia sounds


## Installation

1. Install via CurseForge, Wago, or copy this folder into:
   ```
   World of Warcraft\_retail_\Interface\AddOns\CustomSoundManager
   ```
2. Place your sound files somewhere under `Interface`, for example:
   ```
   World of Warcraft\_retail_\Interface\CustomSounds\alert.ogg
   ```
3. Restart the client (or ensure files exist before login/reload) so WoW picks up new loose files.

## Usage

Open options with:

- `/csm`
- `/customsounds`
- Esc → Options → AddOns → **Custom Sound Manager**

Then:

1. Enter a **Name** (what you want to see in lists)
2. Enter the full **Path**, e.g. `Interface\CustomSounds\alert.ogg`
3. Click **Add**
4. Use **Play** to test or **Remove** to unregister from this addon’s list

Other addons will show the sound as **Custom: YourName**.

### Path rules

| Rule | Example |
|------|---------|
| Must start with `Interface\` | `Interface\CustomSounds\ping.ogg` |
| Must end with `.ogg` or `.mp3` | `alert.mp3` |
| Forward slashes are normalized to backslashes | `Interface/CustomSounds/a.ogg` → OK |

If a newly added file is not seen as a loose asset yet, the addon may warn that a client restart is needed.

Removing a sound updates this addon’s saved list; other addons may need `/reload` to refresh their dropdowns.

## Slash commands

| Command | Action |
|---------|--------|
| `/csm` | Open options |
| `/csm config` | Open options |
| `/customsounds` | Open options |

## License

MIT — see [LICENSE](LICENSE).
