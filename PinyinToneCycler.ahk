#Requires AutoHotkey v2.0
#SingleInstance Force

; Pinyin com tons no Windows
; --------------------------
; Digite a sílaba e aperte o atalho (padrão: Alt + a tecla à esquerda do 1).
; Cada toque troca o tom, na ordem definida nas opções.
; Para o ü, digite v ou u: (lv ou lu: -> lǖ, lǘ, lǚ, lǜ, lü).
; As opções e a pausa ficam no ícone da bandeja do Windows.

global CONFIG_DIR := A_AppData "\PinyinToneCycler"
global CONFIG_FILE := CONFIG_DIR "\settings.ini"
global STARTUP_LINK := A_Startup "\Pinyin Tone Cycler.lnk"

; sc029 é a posição física da tecla à esquerda do 1.
global DEFAULT_HOTKEY := "!sc029"
global DEFAULT_ORDER := [1, 2, 3, 4, 0]   ; 0 = sem tom; 1 a 4 = tons
global PAUSE_ITEM := "Pause"
global SETTINGS_ITEM := "Settings..."

global U_MODES := [
    {id: "both",  label: "v or u: (lv, lu:)",         pattern: "v|u:|ü"},
    {id: "v",     label: "v only (lv)",               pattern: "v|ü"},
    {id: "colon", label: "u: only (lu:)",             pattern: "u:|ü"},
    {id: "none",  label: "Neither (only a typed ü)",  pattern: "ü"}
]

global TONES := Map(
    "a", "āáǎà", "e", "ēéěè", "i", "īíǐì", "o", "ōóǒò", "u", "ūúǔù", "ü", "ǖǘǚǜ",
    "A", "ĀÁǍÀ", "E", "ĒÉĚÈ", "I", "ĪÍǏÌ", "O", "ŌÓǑÒ", "U", "ŪÚǓÙ", "Ü", "ǕǗǙǛ"
)

global TONE_LABELS := Map(
    1, "ā   First tone",
    2, "á   Second tone",
    3, "ǎ   Third tone",
    4, "à   Fourth tone",
    0, "a   No tone"
)

; Opções carregadas do arquivo de configuração
global MainKey := DEFAULT_HOTKEY
global PauseKey := ""
global UMode := "both"
global CycleOrder := DEFAULT_ORDER.Clone()
global CloseAction := "close"   ; o que o botão X da janela de opções faz
global SYLLABLE := ""

global Typed := ""        ; letras digitadas desde o último separador
global Cycling := false   ; true enquanto o tom da sílaba está sendo trocado
global Base := ""         ; sílaba sem tom, já com ü
global Step := 0          ; posição atual dentro de CycleOrder
global ShownLen := 0      ; quantos caracteres a sílaba ocupa na tela
global LastWin := 0       ; janela onde a digitação está acontecendo

; Janela de opções
global SettingsGui := 0
global HotkeyCtl := 0
global PauseCtl := 0
global UModeCtl := 0
global ToneList := 0
global StartupCtl := 0
global CloseCtl := 0
global ToneRows := []
global HotkeyShown := ""  ; como o campo exibiu o atalho salvo ao abrir a janela
global PauseShown := ""

LoadSettings()
SetupTray()
OnMessage(0x0006, OnWindowActivate)   ; WM_ACTIVATE

global Hook := InputHook("V L0 I")
Hook.NotifyNonText := true
Hook.OnChar := OnCharTyped
Hook.OnKeyDown := OnKeyPressed
Hook.Start()

EnableHotkeys()

~*LButton:: ResetState()
~*RButton:: ResetState()
~*MButton:: ResetState()

; ---------------------------------------------------------------------------
; Troca de tom
; ---------------------------------------------------------------------------

CycleTone(*) {
    global Cycling, Base, Step, ShownLen, Typed
    if WinExist("A") != LastWin {
        ResetState()
        return
    }
    firstPress := !Cycling
    if firstPress {
        if !RegExMatch(Typed, SYLLABLE, &found)
            return
        Base := Normalize(found[0])
        ShownLen := StrLen(found[0])
        Step := 0
        Cycling := true
    }
    Step := Mod(Step, CycleOrder.Length) + 1
    ; A sílaba já começa sem tom, então o primeiro toque não pode parar nesse item.
    if firstPress && CycleOrder[Step] = 0
        Step := Mod(Step, CycleOrder.Length) + 1
    output := ApplyTone(Base, CycleOrder[Step])
    ReplaceText(ShownLen, output)
    ShownLen := StrLen(output)
    Typed := ""
}

Normalize(text) {
    text := StrReplace(text, "u:", "ü", true)
    text := StrReplace(text, "U:", "Ü", true)
    text := StrReplace(text, "v", "ü", true)
    return StrReplace(text, "V", "Ü", true)
}

; Regra do tom: a ou e têm prioridade; em "ou" vai no o; nos demais, na última vogal.
TonePosition(syllable) {
    if pos := InStr(syllable, "a")
        return pos
    if pos := InStr(syllable, "e")
        return pos
    if pos := InStr(syllable, "ou")
        return pos
    Loop StrLen(syllable) {
        pos := StrLen(syllable) - A_Index + 1
        if InStr("iouüIOUÜ", SubStr(syllable, pos, 1), true)
            return pos
    }
    return 0
}

ApplyTone(syllable, tone) {
    if tone = 0
        return syllable
    pos := TonePosition(syllable)
    vowel := SubStr(syllable, pos, 1)
    return SubStr(syllable, 1, pos - 1) . SubStr(TONES[vowel], tone, 1) . SubStr(syllable, pos + 1)
}

ReplaceText(removeCount, text) {
    ; Campos com autocompletar (como a barra de endereços) deixam uma sugestão selecionada
    ; depois do cursor, e o primeiro Backspace apagaria só ela. Um caractere provisório
    ; substitui a sugestão e é apagado junto; sem sugestão, ele apenas entra e sai.
    keys := "{U+E000}{Backspace " (removeCount + 1) "}"
    Loop Parse text
        keys .= "{U+" Format("{:04X}", Ord(A_LoopField)) "}"
    SendInput keys
}

ResetState(*) {
    global Typed := ""
    global Cycling := false
}

OnCharTyped(hook, chars) {
    global Typed, Cycling, LastWin
    window := WinExist("A")
    if Cycling || window != LastWin {
        Typed := ""
        Cycling := false
        LastWin := window
    }
    if RegExMatch(chars, "^[a-zA-Z:üÜ]+$")
        Typed := SubStr(Typed . chars, -12)
    else
        Typed := ""
}

OnKeyPressed(hook, vk, sc) {
    global Typed
    ; Shift, Ctrl, Alt, Win, Caps Lock e a tecla de máscara do AutoHotkey não interrompem a sílaba.
    static ignored := [0x10, 0x11, 0x12, 0x14, 0x5B, 0x5C, 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xE8, 0xFF]
    for code in ignored
        if vk = code
            return
    if vk = 0x08 && !Cycling {
        Typed := SubStr(Typed, 1, -1)
        return
    }
    ResetState()
}

; ---------------------------------------------------------------------------
; Configuração
; ---------------------------------------------------------------------------

LoadSettings() {
    global MainKey, PauseKey, UMode, CycleOrder, CloseAction, SYLLABLE
    MainKey := IniRead(CONFIG_FILE, "General", "Hotkey", DEFAULT_HOTKEY)
    if MainKey = "" || !IsValidHotkey(MainKey)
        MainKey := DEFAULT_HOTKEY
    PauseKey := IniRead(CONFIG_FILE, "General", "PauseHotkey", "")
    if PauseKey != "" && !IsValidHotkey(PauseKey)
        PauseKey := ""
    UMode := U_MODES[UModeIndex(IniRead(CONFIG_FILE, "General", "UMode", "both"))].id
    CycleOrder := ParseOrder(IniRead(CONFIG_FILE, "General", "Order", ""))
    CloseAction := IniRead(CONFIG_FILE, "General", "CloseAction", "close") = "minimize" ? "minimize" : "close"
    SYLLABLE := BuildSyllable(UMode)
}

WriteSettings() {
    DirCreate CONFIG_DIR
    IniWrite MainKey, CONFIG_FILE, "General", "Hotkey"
    IniWrite PauseKey, CONFIG_FILE, "General", "PauseHotkey"
    IniWrite UMode, CONFIG_FILE, "General", "UMode"
    IniWrite JoinOrder(CycleOrder), CONFIG_FILE, "General", "Order"
    IniWrite CloseAction, CONFIG_FILE, "General", "CloseAction"
}

BuildSyllable(mode) {
    uForm := U_MODES[UModeIndex(mode)].pattern
    return "i)(?:zh|ch|sh|[bpmfdtnlgkhjqxrzcsyw])?"
        . "(?:iang|iong|uang|ueng|ang|eng|ing|ong|iao|ian|uai|uan"
        . "|er|ai|ei|ao|ou|an|en|ia|ie|in|iu|ua|ue|ui|un|uo|a|o|e|i|u"
        . "|(?:" uForm ")(?:an|e|n)?)r?$"
}

UModeIndex(id) {
    for index, mode in U_MODES
        if mode.id = id
            return index
    return 1
}

; Um valor inválido no arquivo volta para a ordem padrão.
ParseOrder(text) {
    order := []
    seen := Map()
    Loop Parse text, "," {
        if !(A_LoopField ~= "^[0-4]$") || seen.Has(A_LoopField)
            return DEFAULT_ORDER.Clone()
        seen[A_LoopField] := true
        order.Push(Integer(A_LoopField))
    }
    return HasTone(order) ? order : DEFAULT_ORDER.Clone()
}

JoinOrder(order) {
    text := ""
    for tone in order
        text .= (A_Index > 1 ? "," : "") tone
    return text
}

HasTone(order) {
    for tone in order
        if tone != 0
            return true
    return false
}

; ---------------------------------------------------------------------------
; Atalhos e bandeja
; ---------------------------------------------------------------------------

; O prefixo $ faz o atalho passar pelo gancho de teclado. Sem ele, o InputHook
; veria a tecla do atalho e interromperia o ciclo de tons.
EnableHotkeys() {
    Hotkey("$" MainKey, CycleTone, "On S0")
    if PauseKey != ""
        Hotkey("$" PauseKey, TogglePause, "On S")   ; S: continua ativo durante a pausa
}

DisableHotkeys() {
    Hotkey("$" MainKey, "Off")
    if PauseKey != ""
        Hotkey("$" PauseKey, "Off")
}

IsValidHotkey(key) {
    try
        Hotkey("$" key, ResetState, "Off")
    catch ValueError
        return false
    return true
}

SetupTray() {
    A_IconTip := "Pinyin Tone Cycler"
    A_TrayMenu.Delete()
    A_TrayMenu.Add(SETTINGS_ITEM, OpenSettings)
    A_TrayMenu.Add(PAUSE_ITEM, TogglePause)
    A_TrayMenu.Add()
    A_TrayMenu.Add("Exit", (*) => ExitApp())
    A_TrayMenu.Default := SETTINGS_ITEM
}

TogglePause(*) {
    Suspend -1
    ResetState()
    if A_IsSuspended
        A_TrayMenu.Check(PAUSE_ITEM)
    else
        A_TrayMenu.Uncheck(PAUSE_ITEM)
}

; ---------------------------------------------------------------------------
; Janela de opções
; ---------------------------------------------------------------------------

OpenSettings(*) {
    global SettingsGui, HotkeyCtl, PauseCtl, UModeCtl, ToneList, StartupCtl, CloseCtl, ToneRows
    global HotkeyShown, PauseShown
    if SettingsGui {
        SettingsGui.Show("Restore")
        return
    }

    SettingsGui := Gui(, "Pinyin Tone Cycler")
    SettingsGui.MarginX := 16
    SettingsGui.MarginY := 14
    SettingsGui.OnEvent("Close", OnCloseButton)
    SettingsGui.OnEvent("Escape", CloseSettings)

    SettingsGui.Add("Text", "w290", "Cycle hotkey:")
    HotkeyCtl := SettingsGui.Add("Hotkey", "w290 Limit3", MainKey)
    HotkeyShown := HotkeyCtl.Value

    SettingsGui.Add("Text", "w290 y+12", "Pause hotkey (optional):")
    PauseCtl := SettingsGui.Add("Hotkey", "w290 Limit3", PauseKey)
    PauseShown := PauseCtl.Value

    SettingsGui.Add("Text", "w290 y+12", "Type ü with:")
    labels := []
    for mode in U_MODES
        labels.Push(mode.label)
    UModeCtl := SettingsGui.Add("DropDownList", "w290 Choose" UModeIndex(UMode), labels)

    SettingsGui.Add("Text", "w290 y+12", "Tone order (untick a tone to skip it):")
    ToneList := SettingsGui.Add("ListView", "w200 r5 Checked -Multi -Hdr NoSortHdr", ["Tone"])
    moveUp := SettingsGui.Add("Button", "x+8 yp w82", "Move up")
    moveDown := SettingsGui.Add("Button", "xp y+6 w82", "Move down")
    moveUp.OnEvent("Click", (*) => MoveTone(-1))
    moveDown.OnEvent("Click", (*) => MoveTone(1))
    ToneRows := BuildToneRows()
    RenderToneRows(1)

    ToneList.GetPos(, &listY, , &listHeight)
    StartupCtl := SettingsGui.Add("CheckBox", "xm y" (listY + listHeight + 12) " w290", "Start with Windows")
    StartupCtl.Value := FileExist(STARTUP_LINK) ? 1 : 0

    SettingsGui.Add("Text", "w290 y+12", "Close button (X):")
    closeChoice := CloseAction = "minimize" ? 2 : 1
    CloseCtl := SettingsGui.Add("DropDownList", "w290 Choose" closeChoice, ["Close this window", "Minimize to the taskbar"])

    SettingsGui.Add("Button", "xm y+16 w100 Default", "Save").OnEvent("Click", SaveSettings)
    SettingsGui.Add("Button", "x+8 yp w100", "Cancel").OnEvent("Click", CloseSettings)

    SettingsGui.Show()
}

; Tons ativos na ordem salva, seguidos dos tons desligados.
BuildToneRows() {
    rows := []
    for tone in CycleOrder
        rows.Push({tone: tone, on: true})
    for tone in DEFAULT_ORDER {
        found := false
        for active in CycleOrder
            if active = tone
                found := true
        if !found
            rows.Push({tone: tone, on: false})
    }
    return rows
}

RenderToneRows(selected) {
    ToneList.Delete()
    for index, row in ToneRows
        ToneList.Add((row.on ? "Check" : "") (index = selected ? " Select Focus" : ""), TONE_LABELS[row.tone])
    ToneList.ModifyCol(1, "AutoHdr")
}

SyncToneChecks() {
    for row in ToneRows
        row.on := false
    index := 0
    while index := ToneList.GetNext(index, "Checked")
        ToneRows[index].on := true
}

MoveTone(delta) {
    selected := ToneList.GetNext()
    target := selected + delta
    if !selected || target < 1 || target > ToneRows.Length
        return
    SyncToneChecks()
    moved := ToneRows[selected]
    ToneRows[selected] := ToneRows[target]
    ToneRows[target] := moved
    RenderToneRows(target)
    ToneList.Focus()
}

SaveSettings(*) {
    global MainKey, PauseKey, UMode, CycleOrder, CloseAction, SYLLABLE
    SettingsGui.Opt("+OwnDialogs")
    DisableHotkeys()   ; desliga os atalhos antigos antes de trocá-los

    SyncToneChecks()
    order := []
    for row in ToneRows
        if row.on
            order.Push(row.tone)
    if !HasTone(order) {
        MsgBox "Keep at least one tone enabled.", "Pinyin Tone Cycler", "Icon!"
        return
    }

    mainValue := HotkeyCtl.Value
    pauseValue := PauseCtl.Value
    if mainValue = "" {
        MsgBox "Choose a cycle hotkey.", "Pinyin Tone Cycler", "Icon!"
        return
    }
    if mainValue = pauseValue {
        MsgBox "The cycle and pause hotkeys must be different.", "Pinyin Tone Cycler", "Icon!"
        return
    }

    ; O campo mostra !sc029 como !', o que perderia a posição física da tecla.
    ; Por isso, um atalho não alterado continua como estava salvo.
    newMain := (mainValue == HotkeyShown) ? MainKey : mainValue
    newPause := (pauseValue == PauseShown) ? PauseKey : pauseValue
    if !IsValidHotkey(newMain) || (newPause != "" && !IsValidHotkey(newPause)) {
        MsgBox "That hotkey is not supported on this keyboard layout.", "Pinyin Tone Cycler", "Icon!"
        return
    }

    MainKey := newMain
    PauseKey := newPause
    UMode := U_MODES[UModeCtl.Value].id
    CycleOrder := order
    CloseAction := CloseCtl.Value = 2 ? "minimize" : "close"
    SYLLABLE := BuildSyllable(UMode)

    try {
        WriteSettings()
        SetStartup(StartupCtl.Value)
    } catch OSError as err {
        MsgBox "Could not save the settings:`n" err.Message, "Pinyin Tone Cycler", "Icon!"
    }
    CloseSettings()
}

SetStartup(enabled) {
    if !enabled {
        if FileExist(STARTUP_LINK)
            FileDelete STARTUP_LINK
        return
    }
    if A_IsCompiled
        FileCreateShortcut A_ScriptFullPath, STARTUP_LINK, A_ScriptDir
    else
        FileCreateShortcut A_AhkPath, STARTUP_LINK, A_ScriptDir, '"' A_ScriptFullPath '"'
}

; Com a janela em foco, os atalhos ficam desligados para que os campos consigam
; capturar as próprias teclas deles. Minimizada ou em segundo plano, o programa
; continua funcionando normalmente.
OnWindowActivate(wParam, lParam, msg, hwnd) {
    if !SettingsGui || hwnd != SettingsGui.Hwnd
        return
    if wParam & 0xFFFF
        DisableHotkeys()
    else
        EnableHotkeys()
}

OnCloseButton(*) {
    if CloseAction != "minimize" {
        CloseSettings()
        return
    }
    SettingsGui.Minimize()
    return true   ; impede o fechamento da janela
}

CloseSettings(*) {
    global SettingsGui
    SettingsGui.Destroy()
    SettingsGui := 0
    ResetState()
    EnableHotkeys()
}
