# Mouse Enter

AutoHotkey v2 mouse shortcuts for Windows.

## Behavior

- **Left click:** immediate, including the start of a drag.
- **Left + right buttons:** pressing the other button while one is held sends **Enter after approximately 50 ms**. There is no maximum interval between the two presses.
- **Right click:** buffered for up to 120 ms; a short press is sent on release.
- **Middle button:** a short press sends a normal middle click; holding for 300 ms opens Windows screen snipping (Win+Shift+S).
- **Exit:** Ctrl+Alt+F12 or the system tray menu.

If you press the left button first, that initial click reaches the application. When a two-button combination is detected, any previously forwarded button press is released and Enter is scheduled. Releasing the buttons early does not cancel the scheduled Enter. The 50 ms delay is approximate because it depends on Windows timer scheduling.

## Setup and usage

1. Download or clone this repository.
2. Download [AutoHotkey v2.0.27](https://github.com/AutoHotkey/AutoHotkey/releases/tag/v2.0.27) from the official release.
3. Create a runtime folder inside the project and place AutoHotkey64.exe in it.
4. Run the following from the project folder in PowerShell:

    powershell -ExecutionPolicy Bypass -File .\Start.ps1

To stop, press Ctrl+Alt+F12 or run:

    powershell -ExecutionPolicy Bypass -File .\Stop.ps1

The script does not register itself to run at startup. The AutoHotkey runtime, local logs, and previous-version backups are excluded from this repository.

## How it works

MouseEnter.ahk tracks the left and right button states separately. Left presses are forwarded immediately. If the second button is pressed while the other is held, any pending right click is canceled, a previously forwarded press is released, and a one-shot SetTimer schedules Enter. Button states prevent the same press from being processed repeatedly.

- Enter delay: SetTimer(SendChordEnter, -50).
- Right-click buffering: Schedule(button, -120).
- Middle-button screenshot threshold: SetTimer(MiddleHold, -300).

## Checks

The script includes 15 internal checks covering immediate left clicks, both button orders, repeat prevention, the middle button, and the actual Enter timer.

    .\runtime\AutoHotkey64.exe /ErrorStdOut .\MouseEnter.ahk --test

Expected result: PASS: 15 checks including real timer.

Test mode may close the running instance of this script. Run Start.ps1 again after testing.
