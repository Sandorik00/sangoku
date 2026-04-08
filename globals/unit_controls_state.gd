extends Node

signal nextState(state: UnitState)

enum UnitState { TURN, END }

var current_state: UnitState = UnitState.TURN

func forward():
	current_state = Utils.nextEnumMember(UnitState, current_state)
	nextState.emit(current_state)

func backwards():
	current_state = Utils.prevEnumMember(UnitState, current_state)
	nextState.emit(current_state)
