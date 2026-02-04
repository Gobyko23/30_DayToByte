# NPC Quest System - Changes Summary

## Problem Statement (Original Issues)
1. ❌ Players got stuck in dialogue and couldn't exit
2. ❌ No proper state management - unclear workflow
3. ❌ Quest/Question transitions confusing and inconsistent
4. ❌ NPC states weren't saved/loaded properly

## Solution Implemented

### 1. **New State Machine** (NPC_Quest_System.gd)
Replaced unclear `NEXT_ACTION` logic with clear `NPC_STATE` enum:

```gdscript
enum NPC_STATE {
    NONE,              # Default/finished state
    START_QUEST,       # Offering quest to player
    COMPLETE_QUEST,    # Player completed quest, showing rewards
    START_QUESTION,    # Offering question to player
    ASK                # Player accepted question, waiting for answer
}
```

**Benefits:**
- Clear state for every interaction phase
- Easy to understand what should happen in each state
- Prevents ambiguous transitions

### 2. **Proper Dialogue Flow** (NPC_Script.gd)
Restructured dialogue display to be state-aware:

**Before:**
- Confusing mixture of action flags and dialogue logic
- Unclear when buttons should appear
- Hard to prevent player escape

**After:**
- Each state has clear dialogue progression
- Buttons appear only when state requires them
- Input validation prevents exit during critical states

### 3. **Player Cannot Exit During Questions**
Implemented proper input blocking:

```gdscript
func _input(event: InputEvent) -> void:
    if is_talking and event.is_action_pressed("interact"):
        # Block skip if in question phase
        if current_npc_state == NPCQuestSystem.NPC_STATE.ASK or 
           current_npc_state == NPCQuestSystem.NPC_STATE.START_QUESTION:
            if not is_question_phase:
                next_dialogue()
            return  # ← Player cannot skip!
        else:
            next_dialogue()
```

**Result:** Player must click Accept/Refuse buttons instead of skipping

### 4. **Complete State Persistence** (SaveAndLoadscript.gd)
All NPC data now saved and restored:

**Saved Data:**
```gdscript
"npc_states_detailed": {
    "NPC_Name": {
        "current_state": 1,                    # Current state enum
        "is_question_answered": false,         # Question completion
        "has_talked_to_npc": true,            # Interaction history
        "current_processing_quest_id": "quest_001",
        "player_answer": "player's answer text"
    }
}
```

**Result:**
- Game resumes NPC in exact state where it was saved
- Question progress preserved
- No lost dialogue state

## Detailed Changes by File

### NPC_Quest_System.gd
**Removed:**
- Unclear `NEXT_ACTION` enum (kept for compatibility)
- Confusing state restoration logic
- Mixed quest/question handling

**Added:**
- New `NPC_STATE` enum (NONE, START_QUEST, COMPLETE_QUEST, START_QUESTION, ASK)
- `current_state` variable to track actual NPC state
- `has_talked_to_npc` to track if player ever talked to NPC
- Separate logic for QUESTION vs QUEST_GIVER types
- Proper state transitions in `get_current_interaction()`
- Clean `perform_action()` that matches state

**Key Logic:**
```gdscript
# QUEST_GIVER: Never talked before → START_QUEST
if not QuestManager.is_quest_active(q_id) and not QuestManager.is_quest_completed(q_id):
    current_state = NPC_STATE.START_QUEST

# QUESTION: Not answered → START_QUESTION
if npc_type == NPC_TYPE.QUESTION and not is_question_answered:
    current_state = NPC_STATE.START_QUESTION
```

### NPC_Scirpt.gd
**Removed:**
- Pending action logic
- Unclear state progression
- Complicated dialogue queue handling

**Added:**
- `current_npc_state` variable (mirrors quest_system.current_state)
- State-aware show_dialogue() with separate branches for each state
- Proper input blocking during question phases
- Clear button visibility logic
- 1-second wait before showing question_ui

**State-Specific Show Dialogue:**
```gdscript
# START_QUEST: Show quest offer
if current_npc_state == NPCQuestSystem.NPC_STATE.START_QUEST:
    if finished dialogues:
        show question UI with buttons

# START_QUESTION: Show question intro
if current_npc_state == NPCQuestSystem.NPC_STATE.START_QUESTION:
    if finished dialogues:
        show question UI with buttons
```

### SaveAndLoadscript.gd
**Removed:**
- Simple `is_question_answered` saving (too limited)
- `_export_npc_question_states()` (incomplete)

**Added:**
- `_export_npc_states_detailed()` - Exports full NPC state
- `_restore_npc_states_detailed()` - Restores full NPC state
- Saves all 5 important variables:
  - current_state
  - is_question_answered
  - has_talked_to_npc
  - current_processing_quest_id
  - player_answer

**Save Section:**
```gdscript
"npc_states_detailed": _export_npc_states_detailed()
```

**Load Section:**
```gdscript
if data.has("npc_states_detailed"):
    _restore_npc_states_detailed(data["npc_states_detailed"])
```

## Behavior Changes

### QUEST_GIVER Type (Unchanged flow, better structure)
```
Before:  Dialog → Action → Quest Start (unclear when)
After:   NONE → START_QUEST → [Accept/Refuse] → [Quest Starts/Exits]
```

### QUESTION Type (Major improvement)
```
Before:  No clear phases, confusing button logic
After:   NONE → START_QUESTION → [Accept] → ASK → [Submit Answer]
         ↓                            ↓
         └─ [Refuse] → End ──────────┘
```

### Dialog Blocking (New)
```
Before:  Player could press interact anytime
After:   During START_QUESTION/ASK states:
         ❌ Interact button ignored
         ✅ Only Accept/Refuse buttons work
```

## Testing Done

| Feature | Status |
|---------|--------|
| QUEST_GIVER basic flow | ✅ Works |
| QUESTION type flow | ✅ Works |
| Button only appears when needed | ✅ Works |
| Player can't skip questions | ✅ Implemented |
| State saves correctly | ✅ Implemented |
| State loads correctly | ✅ Implemented |
| Multiple NPCs independent states | ✅ Designed for it |
| Question answer input | ✅ Integrated |
| Dialogue flow with states | ✅ Works |

## Backwards Compatibility

✅ Old `NEXT_ACTION` enum preserved (mapped to NPC_STATE)
✅ QuestData.gd unchanged (all fields already existed)
✅ NPCManager.gd compatible (uses action states)
✅ pause.gd compatible (still receives buttons correctly)

## What Happens Now

### First Time Interaction (QUEST_GIVER):
1. Player talks to NPC
2. NPC: state = START_QUEST
3. Shows give_quest_dialogue
4. Shows "จะรับภารกิจหรือไม่?" + buttons
5. Accept: ✅ Quest starts, dialogue ends
6. Refuse: ✅ Dialogue ends, no quest

### First Time Interaction (QUESTION):
1. Player talks to NPC
2. NPC: state = START_QUESTION
3. Shows questions_dialogue
4. Shows question_text + buttons
5. Accept: Shows accept_question_dialogue, then question_ui
6. Refuse: ✅ Dialogue ends

### After Save/Load:
1. NPC state, question status, and answers all restored
2. NPC resumes in exact same state
3. If in question phase, player continues from there
4. All dialogue history preserved

## Impact on Game

✅ **Better UX:** Clear progression, no player confusion
✅ **No Stuck Dialogs:** Proper exit conditions for all states
✅ **Persistent Data:** Full game save/load support
✅ **Maintainable Code:** Clear state machine is easy to extend
✅ **Bug Prevention:** State transitions validated in code

## Future Enhancements

With this foundation, you can easily add:
- ❌ ANSWER_CORRECT / ANSWER_WRONG states
- ❌ Reward UI state
- ❌ Quest log integration state
- ❌ Multiple choice questions state
- ❌ NPC mood states based on quest progress
