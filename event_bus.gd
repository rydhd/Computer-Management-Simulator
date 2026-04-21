# res://event_bus.gd
extends Node

# --- Existing Signals ---
signal trigger_robot_dialogue(text: String)
signal continue_tutorial_dialogue
signal npc_arrived

# --- FIX: Strongly type this signal so it expects the String you are passing! ---
signal issue_clipped_to_board(issue_id: String)
signal show_bell_arrow
signal show_taskboard_arrow
signal hide_taskboard_arrow

signal fade_out_robot

# NEW: Signal to trigger the issue UI
signal show_issue_overlay(issue_text: String)

# --- FIX: Add the missing signal right here! ---
signal reset_robot_position
