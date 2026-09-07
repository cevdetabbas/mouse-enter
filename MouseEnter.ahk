#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
global testing := A_Args.Length && A_Args[1] = "--test"
global events := []
global middleState := "idle"
global state := Map("LButton", "idle", "RButton", "idle")
global started := Map("LButton", 0, "RButton", 0)
global callbacks := Map("LButton", Flush.Bind("LButton"), "RButton", Flush.Bind("RButton"))
A_IconTip := "Mouse Enter - Ctrl+Alt+F12: kapat"
OnExit(Cleanup)
if testing {
    SelfTest()
    ExitApp
}
Hotkey("$*LButton", Down.Bind("LButton"))
Hotkey("$*RButton", Down.Bind("RButton"))
Hotkey("$*LButton Up", Up.Bind("LButton"))
Hotkey("$*RButton Up", Up.Bind("RButton"))
Hotkey("$*MButton", MiddleDown)
Hotkey("$*MButton Up", MiddleUp)
Hotkey("^!F12", (*) => ExitApp())
A_TrayMenu.Add("Kapat (Ctrl+Alt+F12)", (*) => ExitApp())

MiddleDown(*) {
    global middleState
    Critical
    if middleState != "idle"
        return
    middleState := "pending"
    if !testing
        SetTimer(MiddleHold, -300)
}
MiddleHold() {
    global middleState
    Critical
    if middleState != "pending"
        return
    if !testing && !GetKeyState("MButton", "P")
        return
    middleState := "fired"
    Emit("#+s")
}
MiddleUp(*) {
    global middleState
    Critical
    if !testing
        SetTimer(MiddleHold, 0)
    if middleState = "pending"
        Emit("{Blind}{MButton down}{MButton up}")
    middleState := "idle"
}

Emit(keys) {
    if testing
        events.Push(keys)
    else
        SendEvent(keys)
}
Schedule(button, period) {
    if !testing
        SetTimer(callbacks[button], period)
}
Down(button, *) {
    Critical
    if state[button] != "idle"
        return
    other := button = "LButton" ? "RButton" : "LButton"
    if (state[other] = "pending" || state[other] = "sent") {
        Schedule(other, 0)
        if state[other] = "sent"
            Emit("{Blind}{" other " up}")
        state[other] := "chord"
        state[button] := "chord"
        SetTimer(SendChordEnter, -50)
        return
    }
    state[button] := "pending"
    started[button] := A_TickCount
    if button = "LButton"
        Flush(button)
    else
        Schedule(button, -120)
}
SendChordEnter() {
    SetTimer(SendChordEnter, 0)
    Emit("{Enter}")
}
Flush(button) {
    Critical
    if state[button] = "pending" {
        state[button] := "sent"
        Emit("{Blind}{" button " down}")
    }
}
Up(button, *) {
    Critical
    Schedule(button, 0)
    if state[button] = "pending"
        Emit("{Blind}{" button " down}{" button " up}")
    else if state[button] = "sent"
        Emit("{Blind}{" button " up}")
    state[button] := "idle"
}
Cleanup(*) {
    for button, value in state {
        if value = "sent"
            Emit("{Blind}{" button " up}")
    }
}
Check(expected, label) {
    global events
    actual := ""
    for event in events
        actual .= event
    if actual != expected
        throw Error(label ": " actual)
    events := []
}
SelfTest() {
    Down("LButton")
    Check("{Blind}{LButton down}", "Immediate left down")
    Up("LButton")
    Check("{Blind}{LButton up}", "Immediate left up")
    Down("LButton"), Down("RButton")
    Check("{Blind}{LButton down}{Blind}{LButton up}", "Left chord has no immediate Enter")
    Up("LButton"), Up("RButton"), SendChordEnter()
    Check("{Enter}", "Delayed Enter survives release")
    Down("RButton"), Down("LButton")
    Check("", "Right first chord waits")
    SendChordEnter(), Up("RButton"), Up("LButton")
    Check("{Enter}", "Right first delayed Enter")
    Down("LButton"), Down("RButton"), Down("LButton"), Flush("RButton")
    Check("{Blind}{LButton down}{Blind}{LButton up}", "No repeated chord")
    SendChordEnter(), Up("RButton"), Up("LButton")
    Check("{Enter}", "One Enter")
    Down("RButton"), Up("RButton")
    Check("{Blind}{RButton down}{RButton up}", "Single right")
    Down("LButton"), Cleanup(), state["LButton"] := "idle"
    Check("{Blind}{LButton down}{Blind}{LButton up}", "Release on exit")
    MiddleDown(), MiddleUp(), MiddleHold()
    Check("{Blind}{MButton down}{MButton up}", "Short middle")
    MiddleDown(), MiddleHold(), MiddleHold(), MiddleUp()
    Check("#+s", "Screenshot once")
    Down("LButton")
    started["LButton"] := A_TickCount - 1000
    Down("RButton")
    Check("{Blind}{LButton down}{Blind}{LButton up}", "Chord after long hold")
    Up("LButton"), Up("RButton")
    Critical "Off"
    Sleep(120)
    Check("{Enter}", "Real timer sends Enter after release")
    Sleep(80)
    Check("", "Timer fires only once")
    FileAppend("PASS: 15 checks including real timer" Chr(10), "*")
}

