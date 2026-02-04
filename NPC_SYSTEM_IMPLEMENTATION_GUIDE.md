# NPC Quest System - Complete Implementation Guide

## Overview
This document outlines the completely refactored NPC Quest System that now uses a proper state machine with distinct states for handling different NPC interactions.

## Architecture

### 1. **NPC_Quest_System.gd** - Core Logic Engine
Main responsibility: Manage NPC state transitions and determine what dialogue/actions should occur.

#### Key States (NPC_STATE enum):
```
NONE              - ไม่ทำอะไร (เริ่มต้นหรือจบแล้ว)
START_QUEST       - ผู้เล่นเพิ่งเริ่มรับเควส (แสดง give_quest_dialogue)
COMPLETE_QUEST    - ผู้เล่นทำเควสเสร็จแล้ว (แสดง complete_quest_dialogue + reward_dialogue)
START_QUESTION    - ผู้เล่นจะเริ่มตอบคำถาม (แสดง questions_dialogue + ปุ่ม accept/refuse)
ASK               - ผู้เล่นตอบรับและกำลังตอบคำถาม (แสดง question_text + ปุ่ม accept/refuse)
```

#### Important Variables:
- `current_state: NPC_STATE` - Current state of the NPC
- `current_processing_quest: QuestData` - Quest being processed
- `is_question_answered: bool` - Whether player answered the question
- `has_talked_to_npc: bool` - Whether player has talked to this NPC before
- `player_answer: String` - Player's answer to the question

#### Main Function:
```gdscript
func get_current_interaction() -> Dictionary:
    # Returns { "dialogues": Array[String], "state": NPC_STATE }
    # Determines what state NPC should be in and what dialogues to show
```

---

### 2. **NPC_Script.gd** - UI Interface Layer
Main responsibility: Display dialogues and manage UI buttons based on state from NPC_Quest_System.

#### Key Methods:
- `interacting()` - Start dialogue with NPC
- `show_dialogue()` - Display current line based on state
- `next_dialogue()` - Move to next dialogue line
- `end_dialogue()` - Finish conversation and perform action
- `_on_question_accept_pressed()` - Handle accept button
- `_on_question_refuse_pressed()` - Handle refuse button

#### State-Specific Behavior:

**START_QUEST (QUEST_GIVER)**:
- Shows give_quest_dialogue lines
- After all dialogues finish, shows "จะรับภารกิจหรือไม่?" with Accept/Refuse buttons
- If Accept: calls quest_system.perform_action(START_QUEST) → Quest starts
- If Refuse: simply end_dialogue()

**START_QUESTION (QUESTION type)**:
- Shows questions_dialogue lines
- After all dialogues finish, shows question_text with Accept/Refuse buttons
- If Accept: shows accept_question_dialogue, then after 1 second shows question_ui for input
- If Refuse: end_dialogue()

**ASK (QUESTION type)**:
- Directly shows question_text with Accept/Refuse buttons
- If Accept: shows question_ui for player to input answer
- If Refuse: end_dialogue()

**COMPLETE_QUEST**:
- Shows complete_quest_dialogue + reward_dialogue
- When finished, calls quest_system.perform_action(COMPLETE_QUEST) → Quest completed

**NONE**:
- Just shows regular dialogue
- No state transition

---

### 3. **QuestData.gd** - Data Container
Contains all necessary dialogue and configuration data:

```gdscript
# For QUEST_GIVER type:
@export var give_quest_dialogue: Array[String] = ["คุณต้องการเควสหรือไม่?"]
@export var inprocess_dialogue: Array[String] = ["คุณกำลังทำเควสนี้อยู่แล้ว"]
@export var complete_quest_dialogue: Array[String] = ["ขอบคุณที่ทำให้เสร็จ!"]
@export var reward_dialogue: Array[String] = ["นี่คือรางวัล!"]

# For QUESTION type:
@export var questions_dialogue: Array[String] = ["คุณพร้อมตอบคำถามหรือไม่?"]
@export var question_text: String = "คำถามคืออะไร?"
@export var accept_question_dialogue: Array[String] = ["ดีเลย! นี่คือคำถามของฉัน"]
```

---

### 4. **SaveAndLoadscript.gd** - State Persistence
Saves and restores complete NPC state:

```gdscript
# Saved data structure:
{
    "current_state": int,                      # NPC_STATE enum value
    "is_question_answered": bool,              # Answer status
    "has_talked_to_npc": bool,                 # Interaction history
    "current_processing_quest_id": String,     # Quest ID
    "player_answer": String                    # Player's answer text
}
```

Functions:
- `_export_npc_states_detailed()` - Collect all NPC states before save
- `_restore_npc_states_detailed()` - Restore all NPC states after load

---

## Workflow Examples

### Example 1: QUEST_GIVER First Time Interaction
```
1. Player interacts with NPC → interacting()
2. quest_system.get_current_interaction()
   - Returns: state = START_QUEST, dialogues = give_quest_dialogue
3. NPC_Script shows dialogue lines one by one
4. After all dialogues finish:
   - Dialogue_text.text = "จะรับภารกิจหรือไม่?"
   - emit request_question_buttons signal
   - is_question_phase = true
5. Player clicks Accept button:
   - _on_question_accept_pressed() called
   - quest_system.perform_action(START_QUEST)
     - QuestManager.start_quest() called
     - Quest status changes to ACTIVE
   - end_dialogue() called
   - Game resumes
```

### Example 2: QUESTION Type Interaction
```
1. Player interacts with NPC → interacting()
2. quest_system.get_current_interaction()
   - Returns: state = START_QUESTION, dialogues = questions_dialogue
3. NPC_Script shows questions_dialogue lines
4. After all dialogues finish:
   - Dialogue_text.text = question_text
   - emit request_question_buttons signal
5. Player clicks Accept button:
   - Shows accept_question_dialogue
   - Wait 1 second
   - pause.gd shows question_ui
   - Player inputs answer and clicks Submit
6. pause.gd submits answer:
   - quest_system.player_answer = user_input
   - NPC_Script.end_dialogue() called
7. quest_system can now evaluate answer (correct/incorrect)
```

### Example 3: Resume After Save/Load
```
1. Save game:
   - SaveAndLoadscript._export_npc_states_detailed()
   - Saves current_state, is_question_answered, has_talked_to_npc, etc.
2. Load game:
   - SaveAndLoadscript._restore_npc_states_detailed()
   - Finds each NPC and restores its state
   - NPC.quest_system.current_state restored
   - Next interaction uses restored state
```

---

## Important State Transitions

### For QUEST_GIVER (QUEST_GIVER type):
```
NONE → START_QUEST (when new quest available)
START_QUEST → COMPLETE_QUEST (when quest tasks done)
COMPLETE_QUEST → NONE (after showing reward)
```

### For QUESTION (QUESTION type):
```
NONE → START_QUESTION (when not answered yet)
START_QUESTION → (Player accepts or refuses)
  If accepts: shows accept_question_dialogue → ASK
  If refuses: → NONE
ASK → NONE (when player submits or refuses)
```

---

## Player Cannot Exit During Question Phases

### Blocked Actions:
- During START_QUESTION state: Player cannot skip dialogue (only via buttons)
- During ASK state: Player cannot interact normally
- When is_question_phase = true: interact button is ignored

### What Unblocks:
- Player clicks Accept/Refuse button
- NPC.end_dialogue() is called
- Game resumes normally

---

## Key Features

✅ **Complete State Management**: 5 distinct states handle all scenarios
✅ **Proper Dialogue Flow**: Dialogues show based on quest/question status
✅ **Button Management**: Accept/Refuse buttons only show when needed
✅ **No Player Escape**: During questions, player must respond
✅ **Full Save/Load**: All NPC states persist across sessions
✅ **Question System**: Dedicated NPC type for Q&A
✅ **Multiple NPCs**: Each NPC tracks its own state independently

---

## Debugging

### Print NPC State:
```gdscript
quest_system.debug_npc_state()
```

### Check Current State:
```gdscript
print("State: ", NPCQuestSystem.NPC_STATE.keys()[npc.quest_system.current_state])
```

### Check Saved Data:
Look in `user://saves/slot_X.json` for `npc_states_detailed` section.

---

## Files Modified

1. **NPC_Quest_System.gd** - Complete rewrite with NPC_STATE enum
2. **NPC_Scirpt.gd** - Updated to use states instead of pending_action
3. **SaveAndLoadscript.gd** - New _export_npc_states_detailed() / _restore_npc_states_detailed()
4. **QuestData.gd** - No changes (already has all fields)
5. **pause.gd** - No changes needed (works with new system)

---

## Testing Checklist

- [ ] QUEST_GIVER: Can see give_quest_dialogue and accept/refuse buttons
- [ ] QUEST_GIVER: Accepting quest starts it and shows "รับเควสแล้ว"
- [ ] QUEST_GIVER: Cannot skip past question phase with interact button
- [ ] QUESTION: Can see questions_dialogue and accept/refuse buttons
- [ ] QUESTION: After accepting, shows accept_question_dialogue and question_ui
- [ ] QUESTION: Can input answer in question_ui
- [ ] Can save game with NPC in any state
- [ ] Can load game and NPC maintains previous state
- [ ] Multiple NPCs maintain separate states
- [ ] DIALOGUE_ONLY NPC works normally (NONE state only)
