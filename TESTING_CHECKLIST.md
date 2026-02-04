# Implementation Checklist & Testing Guide

## Pre-Implementation Checks

Before using the new system, verify:

- [ ] All files are updated:
  - [ ] `NPC_Quest_System.gd` - Replaced with new state system
  - [ ] `NPC_Scirpt.gd` - Updated with state-aware logic
  - [ ] `SaveAndLoadscript.gd` - Updated with detailed state saving
  - [ ] `QuestData.gd` - Unchanged (already has all needed fields)

- [ ] Dependencies exist:
  - [ ] `NPCManager.gd` in `/root/NPCManager`
  - [ ] `QuestManager.gd` in `/root/QuestManager`
  - [ ] `PointSystem` autoload
  - [ ] `pause.gd` has `setup_npc_question_buttons()` method

---

## Setup Steps

### Step 1: Verify NPC Scene Structure
Each NPC should have:
```
NPC (extends Obj_Main)
├── quest_system: NPCQuestSystem (assigned in inspector)
├── NPC_Dialog (Sprite3D)
├── NPC_UnknowTation (Sprite3D)
├── %ask_text (RichTextLabel)
└── Groups: ["Npc"]
```

### Step 2: Configure QuestData Resources
For each quest, set up QuestData with:

**For QUEST_GIVER:**
```gdscript
npc_type = QUEST_GIVER
give_quest_dialogue = ["Take this quest"]
inprocess_dialogue = ["Still working?"]
complete_quest_dialogue = ["Great job!"]
reward_dialogue = ["Here's your reward"]
```

**For QUESTION:**
```gdscript
npc_type = QUESTION
questions_dialogue = ["You ready?"]
question_text = "What is 2+2?"
accept_question_dialogue = ["Good luck!"]
```

### Step 3: Connect Signals in pause.gd
Already done if using updated pause.gd, but verify:
```gdscript
if accept_btn:
    accept_btn.pressed.connect(_on_accept_btn_pressed)
if refuse_btn:
    refuse_btn.pressed.connect(_on_refuse_btn_pressed)
```

### Step 4: Test Save/Load
Ensure SaveAndLoadscript is in the scene and properly loaded.

---

## Functional Testing

### Test 1: QUEST_GIVER - Give Quest
**Setup:** NPC with quest_system.npc_type = QUEST_GIVER, new quest available

**Steps:**
1. Approach NPC
2. Press interact
3. See give_quest_dialogue lines
4. After last line, should see "จะรับภารกิจหรือไม่?" with buttons
5. Click Accept button

**Expected Result:**
- ✅ Print output: "รับเควสแล้ว" in Output console
- ✅ Quest appears in QuestManager.active_quests
- ✅ Dialogue closes, NPC returns to normal
- ✅ Player can move normally

**If Failed:**
- ❌ Buttons not showing? Check `current_npc_state` = START_QUEST
- ❌ Quest not starting? Check `quest_system.perform_action()` called
- ❌ Player stuck? Check `end_dialogue()` called

### Test 2: QUEST_GIVER - Refuse Quest
**Setup:** Same as Test 1

**Steps:**
1. See "จะรับภารกิจหรือไม่?" with buttons
2. Click Refuse button

**Expected Result:**
- ✅ Dialogue closes immediately
- ✅ No quest started
- ✅ Player can move normally

### Test 3: QUESTION - Answer Question
**Setup:** NPC with quest_system.npc_type = QUESTION, not yet answered

**Steps:**
1. Approach NPC
2. Press interact
3. See questions_dialogue
4. After last line, should see question_text with buttons
5. Click Accept button
6. Wait 1 second
7. Should see question_ui for input
8. Type answer
9. Click Submit

**Expected Result:**
- ✅ accept_question_dialogue shows
- ✅ question_ui appears (text input box)
- ✅ Player can type answer
- ✅ After submit, dialogue closes

**If Failed:**
- ❌ Buttons not showing? Check `current_npc_state` = START_QUESTION
- ❌ question_ui not appearing? Check pause.gd has `show_question_ui_for_answer()`
- ❌ Answer lost? Check `quest_system.player_answer` is saved

### Test 4: Cannot Exit During Question Phase
**Setup:** NPC in START_QUESTION state

**Steps:**
1. See question text with buttons
2. Try pressing interact key
3. Try pressing ESC (pause)
4. Try moving away

**Expected Result:**
- ✅ Interact key does nothing
- ✅ ESC still pauses game (pause.gd handles this)
- ✅ Player cannot exit dialogue
- ✅ Must click Accept or Refuse button

### Test 5: Quest Progress Flow
**Setup:** Quest started, now working on tasks

**Steps:**
1. Complete quest objectives
2. Return to NPC
3. Press interact

**Expected Result:**
- ✅ See inprocess_dialogue (if not done)
- ✅ After quest done, see complete_quest_dialogue + reward_dialogue
- ✅ If quest done, buttons should not show (state = COMPLETE_QUEST only)
- ✅ After reward shown, NPC state = NONE

### Test 6: Save/Load Game
**Setup:** NPC in various states

**Steps:**
1. Talk to NPC (get to some state)
2. Save game (Slot 1)
3. Talk to different NPC or do other things
4. Load game (Slot 1)
5. Find original NPC

**Expected Result:**
- ✅ NPC in same state as when saved
- ✅ current_state restored correctly
- ✅ is_question_answered preserved
- ✅ current_processing_quest_id preserved
- ✅ Player answer text preserved (if any)

**If Failed:**
- ❌ State lost? Check `_export_npc_states_detailed()` called in save
- ❌ Not loading? Check `_restore_npc_states_detailed()` called in load
- ❌ Wrong values? Check SaveAndLoadscript exports all 5 variables

### Test 7: Multiple NPCs Independent
**Setup:** 2+ NPCs with different states

**Steps:**
1. Talk to NPC A (get to START_QUEST)
2. Refuse quest
3. Talk to NPC B (get to QUESTION state)
4. Return to NPC A
5. Talk again

**Expected Result:**
- ✅ NPC A still in NONE (quest not started)
- ✅ NPC B still in START_QUESTION state
- ✅ Each maintains separate state
- ✅ No state cross-contamination

### Test 8: Dialogue Only NPC
**Setup:** NPC with quest_system.npc_type = DIALOGUE_ONLY, no quest_list

**Steps:**
1. Talk to NPC
2. See NonQuest_Dialogue
3. Can skip with interact
4. No buttons appear

**Expected Result:**
- ✅ Shows NonQuest_Dialogue only
- ✅ No buttons ever show
- ✅ Can skip dialogue normally
- ✅ State stays NONE

---

## Debug Commands

Add these to your _process for testing:

```gdscript
if Input.is_action_just_pressed("debug"):  # Custom key binding
    var npc = get_tree().get_first_node_in_group("Npc")  # First NPC
    if npc and npc.quest_system:
        npc.quest_system.debug_npc_state()
```

This prints:
```
============================================================
🔍 DEBUG NPC STATE: NPC_Name
============================================================
Current State: START_QUEST
Current Processing Quest: Quest Name
Is Question Answered: false
Has Talked to NPC: true

Saved NPC Manager State:
  - visited: true
  - greeted: true
  - interaction_count: 1
  - current_state: 1
  - current_quest_id: quest_001
============================================================
```

---

## Common Issues & Solutions

### Issue: "Player stuck, can't interact"
**Diagnosis:**
1. Check print: "is_question_phase: true"
2. Check print: "current_npc_state: ASK or START_QUESTION"

**Solutions:**
- Verify `_on_question_accept_pressed()` or `_on_question_refuse_pressed()` called
- Check buttons are connected in pause.gd
- Verify `end_dialogue()` sets `is_question_phase = false`

### Issue: "Buttons not appearing"
**Diagnosis:**
1. Check print: "current_npc_state: NONE"
2. Quest not START_QUEST state

**Solutions:**
- Verify quest is new (not active/completed)
- Check `get_current_interaction()` returns correct state
- Verify NPC type is QUEST_GIVER or QUESTION

### Issue: "Quest doesn't start"
**Diagnosis:**
1. No "รับเควสแล้ว" print
2. Quest still not in QuestManager

**Solutions:**
- Check `perform_action(START_QUEST)` was called
- Verify `QuestManager.start_quest()` succeeded
- Check quest_id is unique

### Issue: "State not saved/loaded"
**Diagnosis:**
1. Check save file: `user://saves/slot_1.json`
2. Look for `npc_states_detailed` section
3. Check if NPC name matches

**Solutions:**
- Verify `_export_npc_states_detailed()` called before save
- Verify `_restore_npc_states_detailed()` called after load
- Make sure NPC is in scene tree during save
- Check NPC.quest_system.npc_name is set correctly

### Issue: "Question text not showing"
**Diagnosis:**
1. Check state is ASK (not START_QUESTION)
2. Check `Dialogue_text` RichTextLabel exists
3. Check quest_system.current_processing_quest exists

**Solutions:**
- Verify %ask_text node is in scene
- Check QuestData has question_text set
- Verify state transition happens correctly

---

## Performance Checklist

- [ ] No infinite loops in state transitions
- [ ] NPCManager.get_npc_action_state() efficient
- [ ] No memory leaks from signal connections
- [ ] Save file size reasonable (< 1MB for typical data)
- [ ] Load time < 1 second for reasonable quest count

---

## Final Validation

Before considering system complete:

- [ ] All 8 tests pass
- [ ] No console errors
- [ ] Multiple save/load cycles work
- [ ] 3+ NPCs with different types work correctly
- [ ] Player never stuck in dialogue
- [ ] Saved state matches played state after load
- [ ] Documentation is clear and followed
- [ ] Code is clean and commented

---

## Support

If issues persist:

1. **Check console output** - Look for error messages
2. **Use debug_npc_state()** - Print current state
3. **Enable print() statements** - Already in code for debugging
4. **Verify file paths** - Ensure all scripts found
5. **Check group membership** - NPC should be in "Npc" group

---

## Success Indicators

✅ You'll know it's working when:
- Player can talk to any NPC without getting stuck
- Buttons appear only when appropriate
- Questions can be answered
- Quests can be accepted/refused
- Game saves and loads properly
- All NPC states preserved across sessions
