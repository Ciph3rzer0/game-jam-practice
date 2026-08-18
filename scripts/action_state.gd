class_name Action

const ACT_GROUP_MASK                   = 0x000001C0
const ACT_ID_MASK                      = 0x000001FF

enum Groups {
	STATIONARY                           = (0 << 6), # 0x00000000
	MOVING                               = (1 << 6), # 0x00000040
	AIRBORNE                             = (2 << 6), # 0x00000080
	SUBMERGED                            = (3 << 6), # 0x000000C0
	CUTSCENE                             = (4 << 6), # 0x00000100
	AUTOMATIC                            = (5 << 6), # 0x00000140
	OBJECT                               = (6 << 6), # 0x00000180
}

enum Flags {
	ACT_FLAG_STATIONARY                  = (1 <<  9), # 0x00000200  
	ACT_FLAG_MOVING                      = (1 << 10), # 0x00000400  
	ACT_FLAG_AIR                         = (1 << 11), # 0x00000800  
	ACT_FLAG_INTANGIBLE                  = (1 << 12), # 0x00001000  
	ACT_FLAG_SWIMMING                    = (1 << 13), # 0x00002000  
	ACT_FLAG_METAL_WATER                 = (1 << 14), # 0x00004000  
	ACT_FLAG_SHORT_HITBOX                = (1 << 15), # 0x00008000  
	ACT_FLAG_RIDING_SHELL                = (1 << 16), # 0x00010000  
	ACT_FLAG_INVULNERABLE                = (1 << 17), # 0x00020000  
	ACT_FLAG_BUTT_OR_STOMACH_SLIDE       = (1 << 18), # 0x00040000  
	ACT_FLAG_DIVING                      = (1 << 19), # 0x00080000  
	ACT_FLAG_ON_POLE                     = (1 << 20), # 0x00100000  
	ACT_FLAG_HANGING                     = (1 << 21), # 0x00200000  
	ACT_FLAG_IDLE                        = (1 << 22), # 0x00400000  
	ACT_FLAG_ATTACKING                   = (1 << 23), # 0x00800000  
	ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION  = (1 << 24), # 0x01000000  
	ACT_FLAG_CONTROL_JUMP_HEIGHT         = (1 << 25), # 0x02000000  
	ACT_FLAG_ALLOW_FIRST_PERSON          = (1 << 26), # 0x04000000  
	ACT_FLAG_PAUSE_EXIT                  = (1 << 27), # 0x08000000  
	ACT_FLAG_SWIMMING_OR_FLYING          = (1 << 28), # 0x10000000  
	ACT_FLAG_WATER_OR_TEXT               = (1 << 29), # 0x20000000  
	ACT_FLAG_THROWING                    = (1 << 31), # 0x80000000  
}

# IDLE
const STATIONARY_IDLE = Groups.STATIONARY
const STATIONARY_STANDING = Groups.STATIONARY + 1

# MOVING
const MOVING_WALKING = Groups.STATIONARY + 1
const MOVING_SLOWING_DOWN = Groups.STATIONARY + 2
const MOVING_BRAKING = Groups.STATIONARY + 3
const MOVING_STOPPING = Groups.STATIONARY + 4
const MOVING_SLIDING = Groups.STATIONARY + 5
const MOVING_CRAWLING = Groups.STATIONARY + 6
const MOVING_TURN_180 = Groups.STATIONARY + 7
const MOVING_STUMBLING = Groups.STATIONARY + 8
const MOVING_KNOCKED_BACK = Groups.STATIONARY + 9

# AIRBORN
const AIRBORNE = Groups.AIRBORNE
const AIRBORNE_FALLING = Groups.AIRBORNE

const AIRBORNE_JUMP_1 = Groups.AIRBORNE + 11
const AIRBORNE_JUMP_2 = Groups.AIRBORNE + 12
const AIRBORNE_JUMP_3 = Groups.AIRBORNE + 13
const AIRBORNE_JUMP_BACKFLIP = Groups.AIRBORNE + 14
const AIRBORNE_JUMP_SIDEFLIP = Groups.AIRBORNE + 15
const AIRBORNE_JUMP_LONGJUMP = Groups.AIRBORNE + 16


const AIRBORNE_DIVE = Groups.AIRBORNE + 20
const AIRBORNE_DIVE_ROLLOUT = Groups.AIRBORNE + 21
const AIRBORNE_JUMP_KICK = Groups.AIRBORNE + 22
const AIRBORNE_GROUNDPOUND = Groups.AIRBORNE + 23

###

var state: int

func _init() -> void:
	state = 0

func set_state(new_state: int):
	state = new_state
