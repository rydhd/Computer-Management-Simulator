# res://event_bus.gd
extends Node

# --- Existing Signals ---
signal trigger_robot_dialogue(text: String)
signal continue_tutorial_dialogue
signal npc_arrived

# --- FIX: Add the new signal here! ---
signal issue_clipped_to_board

signal show_bell_arrow

signal fade_out_robot
