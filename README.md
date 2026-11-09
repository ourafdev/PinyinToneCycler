# PinyinToneCycler
A simple windows AHK script that allows cycling between pinyin tones while typing with one tap.

# Why this exists

The standard Windows Chinese input doesn't have a good solution to mark pinyin tones. MacOS allows the user to tap the Tab key to cycle between the tone marks on the syllable.

While windows has some workarounds, like [PinyinTones](https://github.com/PinyinTones/PinyinTones), the use is still cumbersome, since you have to change the input method just for the pinyin and then change back to what you were using before.

So this script brings a tone assigning method similar to the MacOS to Windows: type the syllable, then tap a hotkey until the tone is right.

# Installation

1. Install [AutoHotkey v2](https://www.autohotkey.com/). The script needs it to run, and AutoHotkey v1 won't work.
2. Download `PinyinToneCycler.ahk` and double-click it. An "H" icon appears in the system tray.
3. Optional: to start it with Windows, tick **Start with Windows** in the settings.

Double-click the tray icon to open the settings. Right-click it to pause or exit.

# Usage

Type a syllable, then press the hotkey, which is **Alt + the key to the left of 1** by default (`'` on ABNT2, `` ` `` on a US keyboard). Each press moves to the next tone:

```
ni → nī → ní → nǐ → nì → ni
```

By default, the fifth press removes the tone mark, for the neutral tone.

- For ü, type `v` or `u:`. Both `lv` and `lu:` become lǖ.
- The mark goes on the correct vowel automatically: `hao` becomes hāo, `liu` becomes liū.
- Only the last syllable changes. In `nihao`, the tone goes on `hao`, so press the hotkey after each syllable.
- It only works right after typing. Clicking, using the arrow keys or switching windows cancels it.

# Settings

| Option | What it does |
| --- | --- |
| Cycle hotkey | The hotkey that changes the tone. It must include Ctrl or Alt, so it doesn't get in the way of typing. |
| Pause hotkey | Optional. Turns the script off and on. |
| Type ü with | `v`, `u:`, either one, or neither. Typing an actual ü always works. |
| Tone order | Move the tones up or down, or untick one to skip it. The first press never stops on "No tone", since the syllable already has no mark. |
| Start with Windows | Starts the script when you log in. |
| Close button (X) | Either closes only the settings window, leaving the script running in the tray, or exits the script. |

Settings are saved in `%AppData%\PinyinToneCycler\settings.ini`.

# Privacy

The script has to watch your keystrokes to know what you just typed. It keeps at most the last 12 letters in memory and never saves or sends them anywhere.

# License

[AGPL-3.0](LICENSE).

# AI Warning 

Yeah, the script was made with AI. I'm learning Mandarin, not the AHK Scripting Language and i just wanted a quick tool to solve what i see as a grave flaw on Windows input options.
No one lost a comission or got fired by this and i'm not charging for it either. It's a small utility i wanted for myself and, since it worked well enough, i decided to share.
If you hate AI, you're free to not use it, i don't want to get into fights over it.

# Contribuitions warning

I prompted something simple and i read the script later. If i'm afraid of something, i can bully the robot myself by asking about each detail. I don't take responsibility for what happens on your machine (GPL standard clause), but i take responsibility for any code change made on my account and i don't want to review endless AI PRs, so i decided to use the old honor system: you're 100% responsible for any issue or PR you make and you're also responsible for any feature you add. If you don't want to maintain it, keep it in your fork

- No endless slop PRs
- No fire-and-forget PRs: Take responsibility for it
- No robot-only PR where the AI also responds any discussion and never quits
- Any issue and PR can be shot down without warning or justification
- accounts demonstrating "AI Slop Factory" behavior, dumping garbage on the repo just to make their profile look better on their portfolio will be named and shamed mercilessly.

so if you want to add anything:

- Create an issue with the bug/feature you want to ask or address
- Wait for an answer if it's in scope or out of scope (this is a solution to a simple problem, not a mega do-it-all portfolio app)
- Fork it, do all the tests.
- Write the PR BY HAND and, please, BE CONCISE.
- Wait for an answer.
