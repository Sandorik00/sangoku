extends Resource
class_name Skill

@export var skill_name: String = ""

@export var icon: Texture2D = null

@export var targeting_type: CombatUtils.TARGETING_TYPE = CombatUtils.TARGETING_TYPE.SOLO
@export var targeting_range: int = 1
@export var targeting_targets: CombatUtils.TARGETING_TARGETS = CombatUtils.TARGETING_TARGETS.ENEMY

@export var effect: CombatUtils.EFFECTS = CombatUtils.EFFECTS.DAMAGE
@export var power: int = 10
