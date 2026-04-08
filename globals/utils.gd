extends Node

func nextEnumMember(enumz: Dictionary, current: int):
	return wrapi(current + 1, 0, enumz.size() - 1)

func prevEnumMember(enumz: Dictionary, current: int):
	if current - 1 < 0:
		return 0
	return wrapi(current - 1, 0, enumz.size() - 1)
