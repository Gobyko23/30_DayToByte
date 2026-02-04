# NPC System - Quick Reference

## State Machine Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    NPC_STATE Enum                           │
├─────────────────────────────────────────────────────────────┤
│ NONE          → No action (default/completed)               │
│ START_QUEST   → Show quest offer (QUEST_GIVER only)          │
│ COMPLETE_QUEST→ Show reward (after quest done)              │
│ START_QUESTION→ Show question intro (QUESTION only)         │
│ ASK           → Show actual question (QUESTION only)        │
└─────────────────────────────────────────────────────────────┘
```

## What Gets Saved

When saving, these NPC values are preserved:
```gdscript
{
    "current_state": int,                      # ← State at save time
    "is_question_answered": bool,              # ← Question completion
    "has_talked_to_npc": bool,                 # ← Visit history
    "current_processing_quest_id": String,     # ← Which quest
    "player_answer": String                    # ← User's answer text
}
```

## Dialogue Display Logic

### QUEST_GIVER Type (3 phases):
```
Phase 1: Show give_quest_dialogue lines (1 per interact)
Phase 2: Show "จะรับภารกิจหรือไม่?" + Accept/Refuse buttons
Phase 3: Accept → Start quest, Refuse → Close dialogue
```

### QUESTION Type (4 phases):
```
Phase 1: Show questions_dialogue (intro)
Phase 2: Show question_text + Accept/Refuse buttons
Phase 3a (Accept): Show accept_question_dialogue + wait 1 sec
Phase 3b: Show question_ui for player input
Phase 4: Process answer, close dialogue
```

### DIALOGUE_ONLY Type:
```
Just show NonQuest_Dialogue lines, no state changes
```

## Critical Methods

### NPC_Quest_System:
```gdscript
get_current_interaction()     # ← Call this to get dialogue + state
perform_action(state)          # ← Call after player choice
on_question_answered(index)    # ← Player submits answer
```

### NPC_Script:
```gdscript
interacting()                  # ← Start dialogue
show_dialogue()                # ← Display current line/state
next_dialogue()                # ← Move to next line
end_dialogue()                 # ← Close dialogue and execute action
```

### pause.gd:
```gdscript
setup_npc_question_buttons()   # ← Show Accept/Refuse buttons
show_question_ui_for_answer()  # ← Show text input for question
```

## State Transitions (When Does State Change?)

| Current State | Condition | → New State |
|---|---|---|
| NONE | First interaction + new quest | START_QUEST |
| START_QUEST | Accept button | → perform_action() |
| START_QUESTION | Accept button | → show accept_question_dialogue |
| - | Then immediately | → ASK |
| ASK | Submit answer | → NONE |
| COMPLETE_QUEST | Reward dialogue finishes | NONE |

## Player Cannot Exit When

```
❌ During START_QUESTION state - must click accept/refuse
❌ During ASK state - must click accept/refuse or submit answer
✅ All other states - can skip with interact button
```

## Key Variables to Check

```gdscript
quest_system.current_state           # Current NPC state
quest_system.current_processing_quest # What quest it's on
quest_system.is_question_answered    # Has player answered?
quest_system.has_talked_to_npc       # Ever talked to this NPC?
is_question_phase                    # Buttons visible?
```

## Common Tasks

### Check if NPC should show button:
```gdscript
if npc.quest_system.current_state in [NPCQuestSystem.NPC_STATE.START_QUEST, NPCQuestSystem.NPC_STATE.START_QUESTION]:
    # Show buttons
```

### Mark question as answered:
```gdscript
npc.quest_system.is_question_answered = true
```

### Get NPC state after loading:
```gdscript
var state = NPCQuestSystem.NPC_STATE.keys()[npc.quest_system.current_state]
print("NPC state: ", state)  # "NONE", "START_QUEST", etc.
```

## Troubleshooting

### Player stuck in dialogue
→ Check `is_question_phase` - might be true when shouldn't be

### Buttons not showing
→ Check `current_state` - buttons only show for START_QUEST/START_QUESTION/ASK

### State not saving/loading
→ Make sure NPC is in scene tree when saving
→ Check SaveAndLoadscript._export_npc_states_detailed() is called

### Quest not starting
→ Check if perform_action(START_QUEST) was called
→ Check QuestManager.start_quest() was successful

### Question UI not appearing
→ Check if pause.gd has access to show_question_ui_for_answer()
→ Check ASK state is reached

## File Locations
- Core Logic: `Scripts/Entity/NPC_Quest_System.gd`
- UI Display: `Scripts/Entity/NPC_Scirpt.gd`
- Persistence: `Scripts/SaveSystem/SaveAndLoadscript.gd`
- Data: `Scripts/Data/QuestData.gd`
- NPC Manager: `Scripts/Data/NPCManager.gd`
