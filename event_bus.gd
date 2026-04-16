# event_bus.gd (Autoload)
extends Node

# --- Core Game Events ---
signal npc_arrived(npc_name: String, issue_data: Dictionary)
signal issue_clipped_to_board(issue_id: String)
signal bell_rung

# --- Tutorial Specific Events ---
# We use this to tell the Tutorial Robot what to say
signal trigger_robot_dialogue(dialogue_text: String)
