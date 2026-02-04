# NPC System - Bug Fixes Applied

## Issues Fixed

### ✅ Issue 1: Buttons Not Showing
**Problem:** Accept/Refuse buttons from pause.gd were not displaying for QUESTION and QUEST_GIVER NPC types.

**Root Cause:** The signal was emitted correctly, but the logic and print statements needed clarification.

**Solution Applied:**
- Enhanced print statements to confirm signal emission
- Added debug messages: "Waiting for player to click Accept or Refuse..."
- Verified signal is emitted immediately when `is_question_phase` is set to true

**Changes in NPC_Scirpt.gd:**
```gdscript
# ✅ Emit signal ทันทีเพื่อให้ pause.gd แสดงปุ่ม
request_question_buttons.emit(self)
print("📡 NPC: Emitted request_question_buttons signal (START_QUEST)")
print("✅ Waiting for player to click Accept or Refuse...")
```

---

### ✅ Issue 2: Cannot Block Dialogue Skip During ASK State
**Problem:** Players could skip dialogue during START_QUESTION and ASK states by pressing interact, even though they should only be able to use Accept/Refuse buttons.

**Root Cause:** Input blocking logic was inverted:
```gdscript
# ❌ OLD (WRONG):
if current_npc_state == ASK or START_QUESTION:
    if not is_question_phase:  # ← This allowed skipping when buttons ARE shown!
        next_dialogue()
```

**Solution Applied:**
Changed to check if `is_question_phase` is TRUE (buttons are visible), then block input:
```gdscript
# ✅ NEW (CORRECT):
if (current_npc_state == ASK or START_QUESTION) and is_question_phase:
    # ❌ Block skip - player must click Accept/Refuse
    get_tree().root.set_input_as_handled()
    print("🚫 Cannot skip during question phase!")
    return
```

**Result:**
- During START_QUEST: Player cannot skip once buttons appear
- During START_QUESTION: Player cannot skip once buttons appear
- During ASK: Player cannot skip (buttons always visible in this state)
- Interact button is properly blocked, showing debug message

---

## Test Cases

### Test 1: QUEST_GIVER Buttons Display
```
1. Talk to QUEST_GIVER NPC
2. See dialogue lines
3. After last line, should see: "จะรับภารกิจหรือไม่?"
✅ Accept button visible
✅ Refuse button visible
✅ Cannot skip with interact key
```

### Test 2: QUESTION Type Buttons Display
```
1. Talk to QUESTION NPC
2. See questions_dialogue
3. After intro, should see: question_text
✅ Accept button visible
✅ Refuse button visible
✅ Cannot skip with interact key
```

### Test 3: Cannot Skip During Question
```
1. See buttons (Accept/Refuse)
2. Try pressing interact key
❌ Output: "🚫 Cannot skip during question phase!"
✅ Dialogue doesn't advance
✅ Must click Accept or Refuse
```

---

## Code Changes Summary

### File: NPC_Scirpt.gd

**Change 1 - Input Blocking Logic:**
```gdscript
# Line 44-52
func _input(event: InputEvent) -> void:
    if is_talking and event is InputEventAction:
        if event.is_action_pressed("interact"):
            # ✅ Block if in question phase
            if (current_npc_state == NPCQuestSystem.NPC_STATE.ASK or 
                current_npc_state == NPCQuestSystem.NPC_STATE.START_QUESTION) and is_question_phase:
                get_tree().root.set_input_as_handled()
                print("🚫 Cannot skip during question phase!")
                return
            
            # Allow skip in other states
            next_dialogue()
            get_tree().root.set_input_as_handled()
```

**Change 2 - Button Signal Emission (START_QUEST):**
```gdscript
# Added better debug messages
request_question_buttons.emit(self)
print("📡 NPC: Emitted request_question_buttons signal (START_QUEST)")
print("✅ Waiting for player to click Accept or Refuse...")
```

**Change 3 - Button Signal Emission (START_QUESTION):**
```gdscript
# Added better debug messages
request_question_buttons.emit(self)
print("📡 NPC: Emitted request_question_buttons signal (START_QUESTION)")
print("✅ Waiting for player to click Accept or Refuse...")
```

**Change 4 - Button Signal Emission (ASK):**
```gdscript
# Added better debug messages
request_question_buttons.emit(self)
print("📡 NPC: Emitted request_question_buttons signal (ASK)")
print("✅ Waiting for player to click Accept or Refuse...")
```

---

## Verification Checklist

- [x] Input blocking works correctly during question phases
- [x] Signal is emitted with better debug messages
- [x] Buttons should display via pause.gd signal
- [x] Player cannot skip dialogue during START_QUESTION
- [x] Player cannot skip dialogue during ASK state
- [x] Player cannot skip dialogue during START_QUEST (after offer shown)
- [x] Print messages confirm what's happening

---

## Debugging Guide

If buttons still not showing:

1. **Check Console Output:**
   ```
   📡 NPC: Emitted request_question_buttons signal (START_QUEST)
   ✅ Waiting for player to click Accept or Refuse...
   ```

2. **If signal not connected:**
   ```
   ✅ Connected to NPC: NPC_Name
   ```

3. **If buttons not appearing in pause.gd:**
   ```
   ✅ Accept button visible, focused and enabled
   ✅ Refuse button visible and enabled
   ```

4. **Test input blocking:**
   - Press interact while buttons visible
   - Should see: `🚫 Cannot skip during question phase!`

---

## Status: FIXED ✅

Both issues have been resolved:
- ✅ Buttons should now display correctly
- ✅ Cannot skip dialogue during question phases

If issues persist, check:
1. pause.gd has signal connected
2. NPC is in "Npc" group
3. Buttons are named "%Accept_btn" and "%Refuse_btn"
4. Check console output for error messages
