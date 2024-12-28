AddCSLuaFile()

SWEP.Base 						= "weapon_base"

SWEP.Spawnable					= false
SWEP.AdminSpawnable				= false

SWEP.Category					= "Gredwitch's SWEPs"
SWEP.Author						= "Gredwitch"
SWEP.Contact					= ""
SWEP.Purpose					= ""
SWEP.Instructions				= "Mark targets with the fire button."
SWEP.PrintName					= "[AS]Base"


SWEP.WorldModel					= "models/weapons/gredwitch/w_binoculars.mdl"
SWEP.ViewModel 					= "models/weapons/gredwitch/v_binoculars.mdl"

SWEP.Primary					= {
								Ammo 		= "None",
								ClipSize 	= -1,
								DefaultClip = -1,
								Automatic 	= false,
								
								---------------------
								
								NextShot	= 0,
								FireRate	= 0.3
}
SWEP.Secondary					= SWEP.Primary
SWEP.NextReload					= 0
SWEP.DrawAmmo					= false

SWEP.Zoom						= {}
SWEP.Zoom["FOV"]				= 70
SWEP.Zoom["Val"]				= 0

SWEP.UseHands					= true
SWEP.Sounds = {
	["VO_WW2_ALLIED_ARTILLERY_HE"] = {
		CallInSuppressed = {
			"american_01/suppressed/requestartillery1.wav",
			"american_01/suppressed/requestartillery2.wav",
		},
		CallIn = {
			"american_01/unsuppressed/requestartillery1.wav",
			"american_01/unsuppressed/requestartillery2.wav",
		},
		RadioAffirmative = {
			"radio/allied/american/artillerybegin1.ogg",
			"radio/allied/american/artillerybegin2.ogg",
			"radio/allied/american/artillerybegin3.ogg",
			"radio/allied/american/artillerybegin4.ogg",
			"radio/allied/american/artillerybegin5.ogg",
			"radio/allied/american/artillerybegin6.ogg",
		},
		RadioNegative = {
			"radio/allied/american/artillerynotvalidtarget1.ogg",
			"radio/allied/american/artillerynotvalidtarget2.ogg",
			"radio/allied/american/artillerynotvalidtarget3.ogg",
			"radio/allied/american/artillerynotvalidtarget4.ogg",
			"radio/allied/american/artillerynotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/allied/american/artillerydoesnotcopy1.ogg",
			"radio/allied/american/artillerydoesnotcopy2.ogg",
			"radio/allied/american/artillerydoesnotcopy3.ogg",
			"radio/allied/american/artillerydoesnotcopy4.ogg",
			"radio/allied/american/artillerydoesnotcopy5.ogg",
		},
	},
	["VO_WW2_ALLIED_ARTILLERY_SMOKE"] = {
		CallInSuppressed = {
			"american_01/suppressed/requestsmokeartillery1.wav",
			"american_01/suppressed/requestsmokeartillery2.wav",
		},
		CallIn = {
			"american_01/unsuppressed/requestsmokeartillery1.wav",
			"american_01/unsuppressed/requestsmokeartillery2.wav",
		},
		RadioAffirmative = {
			"radio/allied/american/artillerybeginsmoke1.ogg",
			"radio/allied/american/artillerybeginsmoke2.ogg",
			"radio/allied/american/artillerybeginsmoke3.ogg",
			"radio/allied/american/artillerybeginsmoke4.ogg",
			"radio/allied/american/artillerybeginsmoke5.ogg",
		},
		RadioNegative = {
			"radio/allied/american/artillerynotvalidtarget1.ogg",
			"radio/allied/american/artillerynotvalidtarget2.ogg",
			"radio/allied/american/artillerynotvalidtarget3.ogg",
			"radio/allied/american/artillerynotvalidtarget4.ogg",
			"radio/allied/american/artillerynotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/allied/american/artillerydoesnotcopy1.ogg",
			"radio/allied/american/artillerydoesnotcopy2.ogg",
			"radio/allied/american/artillerydoesnotcopy3.ogg",
			"radio/allied/american/artillerydoesnotcopy4.ogg",
			"radio/allied/american/artillerydoesnotcopy5.ogg",
		},
	},
	["VO_WW2_ALLIED_ARTILLERY_WP"] = {
		CallInSuppressed = {
			"english/suppressed/requestincendiaryartillery1.wav",
			"english/suppressed/requestincendiaryartillery2.wav",
		},
		CallIn = {
			"english/unsuppressed/requestincendiaryartillery1.wav",
			"english/unsuppressed/requestincendiaryartillery2.wav",
		},
		RadioAffirmative = {
			"radio/allied/british/incendiaryartillerybegin1.ogg",
			"radio/allied/british/incendiaryartillerybegin2.ogg",
			"radio/allied/british/incendiaryartillerybegin3.ogg",
			"radio/allied/british/incendiaryartillerybegin4.ogg",
			"radio/allied/british/incendiaryartillerybegin5.ogg",
		},
		RadioNegative = {
			"radio/allied/british/artillerynotvalidtarget1.ogg",
			"radio/allied/british/artillerynotvalidtarget2.ogg",
			"radio/allied/british/artillerynotvalidtarget3.ogg",
			"radio/allied/british/artillerynotvalidtarget4.ogg",
			"radio/allied/british/artillerynotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/allied/british/artillerydoesnotcopy1.ogg",
			"radio/allied/british/artillerydoesnotcopy2.ogg",
			"radio/allied/british/artillerydoesnotcopy3.ogg",
			"radio/allied/british/artillerydoesnotcopy4.ogg",
			"radio/allied/british/artillerydoesnotcopy5.ogg",
		},
	},
	["VO_WW2_ALLIED_ARTILLERY_GAS"] = {
		CallInSuppressed = {
			"english/suppressed/requestgasartillery1.wav",
			"english/suppressed/requestgasartillery2.wav",
		},
		CallIn = {
			"english/unsuppressed/requestgasartillery1.wav",
			"english/unsuppressed/requestgasartillery2.wav",
		},
		RadioAffirmative = {
			"radio/allied/british/gasartillerybegin1.ogg",
			"radio/allied/british/gasartillerybegin2.ogg",
			"radio/allied/british/gasartillerybegin3.ogg",
			"radio/allied/british/gasartillerybegin4.ogg",
			"radio/allied/british/gasartillerybegin5.ogg",
		},
		RadioNegative = {
			"radio/allied/british/gasartillerynotvalidtarget1.ogg",
			"radio/allied/british/gasartillerynotvalidtarget2.ogg",
			"radio/allied/british/gasartillerynotvalidtarget3.ogg",
			"radio/allied/british/gasartillerynotvalidtarget4.ogg",
			"radio/allied/british/gasartillerynotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/allied/british/gasartillerydoesnotcopy1.ogg",
			"radio/allied/british/gasartillerydoesnotcopy2.ogg",
			"radio/allied/british/gasartillerydoesnotcopy3.ogg",
			"radio/allied/british/gasartillerydoesnotcopy4.ogg",
			"radio/allied/british/gasartillerydoesnotcopy5.ogg",
		},
	},
	["VO_WW2_ALLIED_BOMBER"] = {
		CallInSuppressed = {
			"american_01/suppressed/requestcarpetbomb1.wav",
			"american_01/suppressed/requestcarpetbomb2.wav",
		},
		CallIn = {
			"american_01/unsuppressed/requestcarpetbomb1.wav",
			"american_01/unsuppressed/requestcarpetbomb2.wav",
		},
		RadioAffirmative = {
			"radio/allied/american/carpetbombbegin1.ogg",
			"radio/allied/american/carpetbombbegin2.ogg",
			"radio/allied/american/carpetbombbegin3.ogg",
			"radio/allied/american/carpetbombbegin4.ogg",
			"radio/allied/american/carpetbombbegin5.ogg",
		},
		RadioNegative = {
			"radio/allied/american/airsupportnotvalidtarget1.ogg",
			"radio/allied/american/airsupportnotvalidtarget2.ogg",
			"radio/allied/american/airsupportnotvalidtarget3.ogg",
			"radio/allied/american/airsupportnotvalidtarget4.ogg",
			"radio/allied/american/airsupportnotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/allied/american/artillerydoesnotcopy1.ogg",
			"radio/allied/american/artillerydoesnotcopy2.ogg",
			"radio/allied/american/artillerydoesnotcopy3.ogg",
			"radio/allied/american/artillerydoesnotcopy4.ogg",
			"radio/allied/american/artillerydoesnotcopy5.ogg",
		},
	},
	["VO_WW2_ALLIED_GUNRUN"] = {
		CallInSuppressed = {
			"american_01/suppressed/requeststraferun1.wav",
			"american_01/suppressed/requeststraferun2.wav",
		},
		CallIn = {
			"american_01/unsuppressed/requeststraferun1.wav",
			"american_01/unsuppressed/requeststraferun2.wav",
		},
		RadioAffirmative = {
			"radio/allied/american/straferunbegin1.ogg",
			"radio/allied/american/straferunbegin2.ogg",
			"radio/allied/american/straferunbegin3.ogg",
			"radio/allied/american/straferunbegin4.ogg",
			"radio/allied/american/straferunbegin5.ogg",
		},
		RadioNegative = {
			"radio/allied/american/airsupportnotvalidtarget1.ogg",
			"radio/allied/american/airsupportnotvalidtarget2.ogg",
			"radio/allied/american/airsupportnotvalidtarget3.ogg",
			"radio/allied/american/airsupportnotvalidtarget4.ogg",
			"radio/allied/american/airsupportnotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/allied/american/artillerydoesnotcopy1.ogg",
			"radio/allied/american/artillerydoesnotcopy2.ogg",
			"radio/allied/american/artillerydoesnotcopy3.ogg",
			"radio/allied/american/artillerydoesnotcopy4.ogg",
			"radio/allied/american/artillerydoesnotcopy5.ogg",
		},
	},
	["VO_WW2_ALLIED_TYPHOON"] = {
		CallInSuppressed = {
			"english/suppressed/requesttyphoonstrike1.wav",
			"english/suppressed/requesttyphoonstrike2.wav",
		},
		CallIn = {
			"english/unsuppressed/requesttyphoonstrike1.wav",
			"english/unsuppressed/requesttyphoonstrike2.wav",
		},
		RadioAffirmative = {
			"radio/allied/british/typhoonbegin1.ogg",
			"radio/allied/british/typhoonbegin2.ogg",
			"radio/allied/british/typhoonbegin3.ogg",
			"radio/allied/british/typhoonbegin4.ogg",
			"radio/allied/british/typhoonbegin5.ogg",
		},
		RadioNegative = {
			"radio/allied/british/airsupportnotvalidtarget1.ogg",
			"radio/allied/british/airsupportnotvalidtarget2.ogg",
			"radio/allied/british/airsupportnotvalidtarget3.ogg",
			"radio/allied/british/airsupportnotvalidtarget4.ogg",
			"radio/allied/british/airsupportnotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/allied/british/artillerydoesnotcopy1.ogg",
			"radio/allied/british/artillerydoesnotcopy2.ogg",
			"radio/allied/british/artillerydoesnotcopy3.ogg",
			"radio/allied/british/artillerydoesnotcopy4.ogg",
			"radio/allied/british/artillerydoesnotcopy5.ogg",
		},
	},
	
	-------------------------------------------------------------------------------------------------------------
	
	["VO_WW2_AXIS_ARTILLERY_HE"] = {
		CallInSuppressed = {
			"german_01/suppressed/requestartillery1.wav",
			"german_01/suppressed/requestartillery2.wav",
		},
		CallIn = {
			"german_01/unsuppressed/requestartillery1.wav",
			"german_01/unsuppressed/requestartillery2.wav",
		},
		RadioAffirmative = {
			"radio/axis/artillerybegin1.ogg",
			"radio/axis/artillerybegin2.ogg",
			"radio/axis/artillerybegin3.ogg",
			"radio/axis/artillerybegin4.ogg",
			"radio/axis/artillerybegin5.ogg",
		},
		RadioNegative = {
			"radio/axis/artillerynotvalidtarget1.ogg",
			"radio/axis/artillerynotvalidtarget2.ogg",
			"radio/axis/artillerynotvalidtarget3.ogg",
			"radio/axis/artillerynotvalidtarget4.ogg",
			"radio/axis/artillerynotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/axis/artillerydoesnotcopy1.ogg",
			"radio/axis/artillerydoesnotcopy2.ogg",
			"radio/axis/artillerydoesnotcopy3.ogg",
			"radio/axis/artillerydoesnotcopy4.ogg",
			"radio/axis/artillerydoesnotcopy5.ogg",
		},
	},
	["VO_WW2_AXIS_ARTILLERY_SMOKE"] = {
		CallInSuppressed = {
			"german_01/suppressed/requestsmokeartillery1.wav",
			"german_01/suppressed/requestsmokeartillery2.wav",
		},
		CallIn = {
			"german_01/unsuppressed/requestsmokeartillery1.wav",
			"german_01/unsuppressed/requestsmokeartillery2.wav",
		},
		RadioAffirmative = {
			"radio/axis/artillerybeginsmoke1.ogg",
			"radio/axis/artillerybeginsmoke2.ogg",
			"radio/axis/artillerybeginsmoke3.ogg",
			"radio/axis/artillerybeginsmoke4.ogg",
			"radio/axis/artillerybeginsmoke5.ogg",
		},
		RadioNegative = {
			"radio/axis/artillerynotvalidtarget1.ogg",
			"radio/axis/artillerynotvalidtarget2.ogg",
			"radio/axis/artillerynotvalidtarget3.ogg",
			"radio/axis/artillerynotvalidtarget4.ogg",
			"radio/axis/artillerynotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/axis/artillerydoesnotcopy1.ogg",
			"radio/axis/artillerydoesnotcopy2.ogg",
			"radio/axis/artillerydoesnotcopy3.ogg",
			"radio/axis/artillerydoesnotcopy4.ogg",
			"radio/axis/artillerydoesnotcopy5.ogg",
		},
	},
	["VO_WW2_AXIS_BOMBER"] = {
		CallInSuppressed = {
			"german_01/suppressed/requestcarpetbomb1.wav",
			"german_01/suppressed/requestcarpetbomb2.wav",
		},
		CallIn = {
			"german_01/unsuppressed/requestcarpetbomb1.wav",
			"german_01/unsuppressed/requestcarpetbomb2.wav",
		},
		RadioAffirmative = {
			"radio/axis/carpetbombbegin1.ogg",
			"radio/axis/carpetbombbegin2.ogg",
			"radio/axis/carpetbombbegin3.ogg",
			"radio/axis/carpetbombbegin4.ogg",
			"radio/axis/carpetbombbegin5.ogg",
		},
		RadioNegative = {
			"radio/axis/airsupportnotvalidtarget1.ogg",
			"radio/axis/airsupportnotvalidtarget2.ogg",
			"radio/axis/airsupportnotvalidtarget3.ogg",
			"radio/axis/airsupportnotvalidtarget4.ogg",
			"radio/axis/airsupportnotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/axis/artillerydoesnotcopy1.ogg",
			"radio/axis/artillerydoesnotcopy2.ogg",
			"radio/axis/artillerydoesnotcopy3.ogg",
			"radio/axis/artillerydoesnotcopy4.ogg",
			"radio/axis/artillerydoesnotcopy5.ogg",
		},
	},
	["VO_WW2_AXIS_STUKA"] = {
		CallInSuppressed = {
			"german_01/suppressed/requeststukadive1.wav",
			"german_01/suppressed/requeststukadive2.wav",
		},
		CallIn = {
			"german_01/unsuppressed/requeststukadive1.wav",
			"german_01/unsuppressed/requeststukadive2.wav",
		},
		RadioAffirmative = {
			"radio/axis/stukadivebegin1.ogg",
			"radio/axis/stukadivebegin2.ogg",
			"radio/axis/stukadivebegin3.ogg",
			"radio/axis/stukadivebegin4.ogg",
			"radio/axis/stukadivebegin5.ogg",
		},
		RadioNegative = {
			"radio/axis/airsupportnotvalidtarget1.ogg",
			"radio/axis/airsupportnotvalidtarget2.ogg",
			"radio/axis/airsupportnotvalidtarget3.ogg",
			"radio/axis/airsupportnotvalidtarget4.ogg",
			"radio/axis/airsupportnotvalidtarget5.ogg",
		},
		RadioDidNotCopy = {
			"radio/axis/artillerydoesnotcopy1.ogg",
			"radio/axis/artillerydoesnotcopy2.ogg",
			"radio/axis/artillerydoesnotcopy3.ogg",
			"radio/axis/artillerydoesnotcopy4.ogg",
			"radio/axis/artillerydoesnotcopy5.ogg",
		},
	},
}

local SubTitles = {
	["american_01/unsuppressed/requeststraferun1.wav"] = "Station this is Squad Lead, can you get air to do a gun run on this position?",
	["american_01/unsuppressed/requeststraferun2.wav"] = "Station, we're gonna need air to strafe this area, can you let 'em know?",
	["american_01/suppressed/requeststraferun1.wav"] = "Light it up! Shoot those sons of bitches!",
	["american_01/suppressed/requeststraferun2.wav"] = "We need air support! Shoot the bastards, gun 'em down!",
	
	["american_01/unsuppressed/requestartillery1.wav"] = "Station this is Squad Lead, we need artillery on this location, over.",
	["american_01/unsuppressed/requestartillery2.wav"] = "Station this is Squad Leader, can you hit this position with artillery?",
	["american_01/suppressed/requestartillery1.wav"] = "We need that artillery right now, send it!",
	["american_01/suppressed/requestartillery2.wav"] = "We need fire support, just freakin' fire your guns already!",
	
	["american_01/suppressed/requestcarpetbomb1.wav"] = "Get Air over here quick, we need to drop some bombs on 'em!",
	["american_01/suppressed/requestcarpetbomb2.wav"] = "Bomb em'! Send Air, blow 'em all to hell!",
	["american_01/unsuppressed/requestcarpetbomb1.wav"] = "Station, this is Squad Lead. We need a bombing run on this location, you got it?",
	["american_01/unsuppressed/requestcarpetbomb2.wav"] = "Station, we're gonna need Air to bomb this position. Get them over here quick!",
	
	["american_01/suppressed/requestsmokeartillery1.wav"] = "We can't do shit unless you give us some smoke cover!",
	["american_01/suppressed/requestsmokeartillery2.wav"] = "Look, if you're not real busy, smoke cover would be fucking fantastic!",
	["american_01/unsuppressed/requestsmokeartillery1.wav"] = "Station this is Squad Lead, can you get us some smoke cover right here, over.",
	["american_01/unsuppressed/requestsmokeartillery2.wav"] = "Station this is Squad Leader, can you put smoke right here, we need cover.",
	
	["german_01/suppressed/requestartillery1.wav"] = "Put it right here! Send these bastards to Hell!",
	["german_01/suppressed/requestartillery2.wav"] = "We need artillery right now, God damn it, over!",
	["german_01/unsuppressed/requestartillery1.wav"] = "Station, this is Gruppenführer, I need artillery on this position, do you copy?",
	["german_01/unsuppressed/requestartillery2.wav"] = "Station, this is Gruppenführer, we need a barrage on this position, over.",
	
	["german_01/unsuppressed/requestcarpetbomb1.wav"] = "Station, we need air support to bomb this area, over.",
	["german_01/unsuppressed/requestcarpetbomb2.wav"] = "Station, this is Gruppenführer, send bombers here, over.",
	["german_01/suppressed/requestcarpetbomb1.wav"] = "We need air support! Drop the bombs! Hurry!",
	["german_01/suppressed/requestcarpetbomb2.wav"] = "Just bomb them, come on! It can't be that hard!",
	
	["german_01/unsuppressed/requestsmokeartillery1.wav"] = "Station, this is Gruppenführer, we need a smokescreen on this position, do you copy?",
	["german_01/unsuppressed/requestsmokeartillery2.wav"] = "Station, this is Gruppenführer, can you fire a smoke barrage at this location, over.",
	["german_01/suppressed/requestsmokeartillery1.wav"] = "We need cover, damn it! Send a smokescreen on this position, over!",
	["german_01/suppressed/requestsmokeartillery2.wav"] = "We're totally exposed! Put a smokescreen on this location!",
	
	["german_01/unsuppressed/requeststukadive1.wav"] = "Station, this is Gruppenführer, we need a Stuka strike on this position, over.",
	["german_01/unsuppressed/requeststukadive2.wav"] = "Station, this is Gruppenführer, send the Stuka, give it to 'em!",
	["german_01/suppressed/requeststukadive1.wav"] = "Stuka! Send a Stuka over God damn it!",
	["german_01/suppressed/requeststukadive2.wav"] = "I've had enough of this! Send the Stuka!",
	
	["english/suppressed/requesttyphoonstrike1.wav"] = "I need a bloody Typhoon on my target! Obliterate these bastards!",
	["english/suppressed/requesttyphoonstrike2.wav"] = "Station! I want a shit ton of rockets on this position! Now damn it!",
	["english/unsuppressed/requesttyphoonstrike1.wav"] = "Station this is Section Commander, requesting immediate rocket run on my target, over.",
	["english/unsuppressed/requesttyphoonstrike2.wav"] = "Station come in, can you sick a Typhoon on this position, over.",
	
	["english/suppressed/requestincendiaryartillery1.wav"] = "Requesting immediate incendiary barrage on my target, burn 'em to a bloody crisp!",
	["english/suppressed/requestincendiaryartillery2.wav"] = "Bollocks to protocol get me a rain of burny shit down here now! Torch these fuckers!",
	["english/unsuppressed/requestincendiaryartillery1.wav"] = "Station this is Section Commander, incendiary strike my target, over.",
	["english/unsuppressed/requestincendiaryartillery2.wav"] = "Commander to Station, got a bunch of Krauts that need roasting. Can you assist, over?",
	
	["english/suppressed/requestgasartillery1.wav"] = "Command! Drop some mustard gas on these handbastards!",
	["english/suppressed/requestgasartillery2.wav"] = "Damn it, I do not care anymore! Use gas! Suffocate the wankers!",
	["english/unsuppressed/requestgasartillery1.wav"] = "Command, do you read? We need mustard gas right on this target, over!",
	["english/unsuppressed/requestgasartillery2.wav"] = "Command, send the gas. Target is here, over.",
	
	["radio/axis/airsupportnotvalidtarget1.ogg"] = "Fire mission denied, Gruppenführer. We can't fire there.",
	["radio/axis/airsupportnotvalidtarget2.ogg"] = "Sorry, we can't fire there.",
	["radio/axis/airsupportnotvalidtarget3.ogg"] = "Negative, Gruppenführer. Unable to fire there.",
	["radio/axis/airsupportnotvalidtarget4.ogg"] = "Negative, Gruppenführer. Our guns can't fire there.",
	["radio/axis/airsupportnotvalidtarget5.ogg"] = "Uh, not sure where you mean. That's not a valid target.",
	
	["radio/axis/artillerybegin1.ogg"] = "Understood. Artillery is on its way.",
	["radio/axis/artillerybegin2.ogg"] = "Roger that, Gruppenführer. Here comes the barrage.",
	["radio/axis/artillerybegin3.ogg"] = "No problem. All you had to do was ask.",
	["radio/axis/artillerybegin4.ogg"] = "Understood. Keep your heads down, men.",
	["radio/axis/artillerybegin5.ogg"] = "Artillery fire is coming in a sec. Hold on to your butts!",
	
	["radio/axis/artillerybeginsmoke1.ogg"] = "Understood, Gruppenführer. Smoke on its way.",
	["radio/axis/artillerybeginsmoke2.ogg"] = "Roger that. Smoke barrage going out. Hang on.",
	["radio/axis/artillerybeginsmoke3.ogg"] = "Roger that, Gruppenführer. Smoke is on the way.",
	["radio/axis/artillerybeginsmoke4.ogg"] = "Smoke barrage on its way. Get yourselves ready.",
	["radio/axis/artillerybeginsmoke5.ogg"] = "Understood. Here comes the smoke.",
	
	["radio/axis/artillerydoesnotcopy1.ogg"] = "Say again, Gruppenführer. We did not understand your last transmission.",
	["radio/axis/artillerydoesnotcopy2.ogg"] = "Say again, Gruppenführer? The transmission was cut off.",
	["radio/axis/artillerydoesnotcopy3.ogg"] = "Gruppenführer, come in. Gruppenführer, we did not understand you.",
	["radio/axis/artillerydoesnotcopy4.ogg"] = "Please say again. We did not understand your request.",
	["radio/axis/artillerydoesnotcopy5.ogg"] = "Gruppenführer, are you still there? We didn't get that.",
	
	["radio/axis/artillerynotvalidtarget1.ogg"] = "Fire mission denied, Gruppenführer. We can't fire there.",
	["radio/axis/artillerynotvalidtarget2.ogg"] = "Sorry, we can't fire there.",
	["radio/axis/artillerynotvalidtarget3.ogg"] = "Negative, Gruppenführer. Our guns can't fire there.",
	["radio/axis/artillerynotvalidtarget4.ogg"] = "Uh, not sure where you mean. That's not a valid target.",
	["radio/axis/artillerynotvalidtarget5.ogg"] = "Negative, Gruppenführer. Unable to fire there.",
	
	["radio/axis/carpetbombbegin1.ogg"] = "Alright, roger that. Bombs are on the way.",
	["radio/axis/carpetbombbegin2.ogg"] = "Plane is coming. Get ready.",
	["radio/axis/carpetbombbegin3.ogg"] = "Roger that, Gruppenführer. Bombardment will begin shortly.",
	["radio/axis/carpetbombbegin4.ogg"] = "Get ready for an incoming airstrike.",
	["radio/axis/carpetbombbegin5.ogg"] = "Copy that, sending a plane now.",
	
	["radio/axis/stukadivebegin1.ogg"] = "Gruppenführer, confirmed. Stuka on the way.",
	["radio/axis/stukadivebegin2.ogg"] = "Yeah, we hear you. Stuka on its way.",
	["radio/axis/stukadivebegin3.ogg"] = "Stand by, Stuka on the way.",
	["radio/axis/stukadivebegin4.ogg"] = "You said Stuka, yeah? Alright, on the way.",
	["radio/axis/stukadivebegin5.ogg"] = "Copy that. This ought to make them shit their pants.",
	
	["radio/allied/american/airsupportnotvalidtarget1.ogg"] = "That's a bad target for air. You need to find another spot.",
	["radio/allied/american/airsupportnotvalidtarget2.ogg"] = "Negative, Squad Leader, bad target. Find another spot.",
	["radio/allied/american/airsupportnotvalidtarget3.ogg"] = "We can't send them there, that target is no good.",
	["radio/allied/american/airsupportnotvalidtarget4.ogg"] = "Negative, no, that's not a good target.",
	["radio/allied/american/airsupportnotvalidtarget5.ogg"] = "Not trying to be a pain in the rear here but that's a bad target. Find another spot.",
	
	["radio/allied/american/artillerybegin1.ogg"] = "Understood. Artillery on the way.",
	["radio/allied/american/artillerybegin2.ogg"] = "Yup I heard you it's gonna get loud down there.",
	["radio/allied/american/artillerybegin3.ogg"] = "Okay roger that, firing artillery.",
	["radio/allied/american/artillerybegin4.ogg"] = "It's coming.",
	["radio/allied/american/artillerybegin5.ogg"] = "Roger, yeah, on the way.",
	[ "radio/allied/american/artillerybegin6.ogg"] = "Roger that. Artillery outgoing.",
	
	["radio/allied/american/artillerydoesnotcopy1.ogg"] = "We did not get that Squad Lead, please say again.",
	["radio/allied/american/artillerydoesnotcopy2.ogg"] = "Station did not understand your last. Say again.",
	["radio/allied/american/artillerydoesnotcopy3.ogg"] = "Squad Lead we did not hear your last, over.",
	["radio/allied/american/artillerydoesnotcopy4.ogg"] = "Squad Lead, Station did not copy. Say again, over.",
	["radio/allied/american/artillerydoesnotcopy5.ogg"] = "Squad Lead are you alright? We did not hear your last.",
	
	["radio/allied/american/artillerynotvalidtarget1.ogg"] = "We're not able to target that location, over.",
	["radio/allied/american/artillerynotvalidtarget2.ogg"] = "Negative, we can't fire on that location.",
	["radio/allied/american/artillerynotvalidtarget3.ogg"] = "Uh, I'm not seeing that on my map.",
	["radio/allied/american/artillerynotvalidtarget4.ogg"] = "That's a negative. Can't target that area.",
	["radio/allied/american/artillerynotvalidtarget5.ogg"] = "I'm uh, where is that? I can't fire there.",
	
	["radio/allied/american/carpetbombbegin1.ogg"] = "Alright, sending a bomber.",
	["radio/allied/american/carpetbombbegin2.ogg"] = "Yeah, we copy. They're gonna do a run now.",
	["radio/allied/american/carpetbombbegin3.ogg"] = "Okay we got it, bombing run coming.",
	["radio/allied/american/carpetbombbegin4.ogg"] = "Understood, they're on the way.",
	["radio/allied/american/carpetbombbegin5.ogg"] = "Yup, we got it.",
	
	["radio/allied/american/straferunbegin1.ogg"] = "Alright yup gun run coming, sit tight.",
	["radio/allied/american/straferunbegin2.ogg"] = "Understood, it'll be there in a second.",
	["radio/allied/american/straferunbegin3.ogg"] = "You got it, I'll let them know.",
	["radio/allied/american/straferunbegin4.ogg"] = "Copy that.",
	["radio/allied/american/straferunbegin5.ogg"] = "Roger, yeah, I'll have 'em strafe it real good.",
	
	["radio/allied/british/airsupportnotvalidtarget1.ogg"] = "That's a negative. Deployment is not possible in that area.",
	["radio/allied/british/airsupportnotvalidtarget2.ogg"] = "Cannot comply. That is an invalid target.",
	["radio/allied/british/airsupportnotvalidtarget3.ogg"] = "Cannot commence sortie. Target details are invalid.",
	["radio/allied/british/airsupportnotvalidtarget4.ogg"] = "Unable to deploy aircraft to your current target. Please readjust coordinates.",
	["radio/allied/british/airsupportnotvalidtarget5.ogg"] = "Negative. Air support cannot deploy to those coordinates.",
	
	["radio/allied/british/typhoonbegin1.ogg"] = "Roger, Typhoon is inbound.",
	["radio/allied/british/typhoonbegin2.ogg"] = "Rocket strike is imminent, get clear.",
	["radio/allied/british/typhoonbegin3.ogg"] = "Confirmed. Rockets on your target.",
	["radio/allied/british/typhoonbegin4.ogg"] = "Typhoon has your target, commencing attack run.",
	["radio/allied/british/typhoonbegin5.ogg"] = "That's a copy, Typhoon is on approach.",
	
	["radio/allied/british/artillerydoesnotcopy1.ogg"] = "We need full target details. Please say again, over.",
	["radio/allied/british/artillerydoesnotcopy2.ogg"] = "We did not understand your last. Where are we targeting?",
	["radio/allied/british/artillerydoesnotcopy3.ogg"] = "Say again? You got cut off.",
	["radio/allied/british/artillerydoesnotcopy4.ogg"] = "Resend target details. Transmission cut short, over.",
	["radio/allied/british/artillerydoesnotcopy5.ogg"] = "Station did not receive. Say again?",
	
	["radio/allied/british/artillerynotvalidtarget1.ogg"] = "We can't target there. Our shots are blocked.",
	["radio/allied/british/artillerynotvalidtarget2.ogg"] = "Target coordinates not viable for fire.",
	["radio/allied/british/artillerynotvalidtarget3.ogg"] = "That's a negative. Station is unable to fire there.",
	["radio/allied/british/artillerynotvalidtarget4.ogg"] = "Unable to fire. It's out of our current range.",
	["radio/allied/british/artillerynotvalidtarget5.ogg"] = "Negative, we can't adjust fire to those coordinates.",
	
	["radio/allied/british/gasartillerybegin1.ogg"] = "Confirming request for gas. Here it comes!",
	["radio/allied/british/gasartillerybegin2.ogg"] = "[]",
	["radio/allied/british/gasartillerybegin3.ogg"] = "Message is received. Mustard gas incoming.",
	["radio/allied/british/gasartillerybegin4.ogg"] = "Understood, firing gas rounds.",
	["radio/allied/british/gasartillerybegin5.ogg"] = "We read you, commencing gas bombardment.",
	
	["radio/allied/british/gasartillerydoesnotcopy1.ogg"] = "We need full target details. Please say again, over.",
	["radio/allied/british/gasartillerydoesnotcopy2.ogg"] = "We did not understand your last. Where are we targeting?",
	["radio/allied/british/gasartillerydoesnotcopy3.ogg"] = "Say again? You got cut off.",
	["radio/allied/british/gasartillerydoesnotcopy4.ogg"] = "Resend target details. Transmission cut short, over.",
	["radio/allied/british/gasartillerydoesnotcopy5.ogg"] = "Station did not receive. Say again?",
	
	["radio/allied/british/incendiaryartillerybegin1.ogg"] = "Roger, incendiary shells are on their way.",
	["radio/allied/british/incendiaryartillerybegin2.ogg"] = "That's a copy. Commencing incendiary strike now.",
	["radio/allied/british/incendiaryartillerybegin3.ogg"] = "Confirmed, firing incendiary rounds.",
	["radio/allied/british/incendiaryartillerybegin4.ogg"] = "Message received, firing incendiaries. Clear the area.",
	["radio/allied/british/incendiaryartillerybegin5.ogg"] = "Affirmative, incendiary barrage outgoing.",
	
	["radio/allied/british/gasartillerynotvalidtarget1.ogg"] = "We can't target there. Our shots are blocked.",
	["radio/allied/british/gasartillerynotvalidtarget2.ogg"] = "Target coordinates not viable for fire.",
	["radio/allied/british/gasartillerynotvalidtarget3.ogg"] = "That's a negative. Station is unable to fire there.",
	["radio/allied/british/gasartillerynotvalidtarget4.ogg"] = "Unable to fire. It's out of our current range.",
	["radio/allied/british/gasartillerynotvalidtarget5.ogg"] = "Negative, we can't adjust fire to those coordinates.",
	
	["radio/allied/american/artillerybeginsmoke1.ogg"] = "Smoke sounds good, yeah, here it comes.",
	["radio/allied/american/artillerybeginsmoke2.ogg"] = "Okay we got you firing smoke.",
	["radio/allied/american/artillerybeginsmoke3.ogg"] = "Smoke artillery on the way, stand by.",
	["radio/allied/american/artillerybeginsmoke4.ogg"] = "Smoke barrage incoming.",
	["radio/allied/american/artillerybeginsmoke5.ogg"] = "Roger that smoke is on the way.",
}

-- Micro optimizations
local pairs						= pairs
local IsValid					= IsValid
local CLIENT					= CLIENT
local SERVER					= SERVER
local SINGLEPLAYER				= game.SinglePlayer()

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	
	return true
end

function SWEP:Initialize()
	self:SetHoldType("camera")
	self:InitChoices()
end

function SWEP:InitChoices()
	self.Choices = {
		{
			name = "Artillery Strike",
			sound = "VO_WW2_ALLIED_ARTILLERY"
		},
		{
			name = "Air Strike #2"
		},
		{
			name = "Air Strike #3"
		},
		{
			name = "Air Strike #4"
		},
		{
			name = "Air Strike #5"
		},
		{
			name = "Air Strike #6"
		},
		{
			name = "Air Strike #7"
		},
		{
			name = "Air Strike #8"
		},
		{
			name = "More...",
			choices = {
				{
					name = "Plane count",
					Decor = true
				},
				{
					name = "More choice #1"
				},
				{
					name = "More choice #2"
				},
				{
					name = "Even more...",
					choices = {
						{
							name = "Less...", 
							less = true
						}
					}
				},
				{
					name = "Less...",
					less = true
				},
			}
		},
	}
end

function SWEP:Holster(wep)
	return true
end

function SWEP:OnRemove()
end

function SWEP:DrawHUD()
	surface.SetDrawColor(0,0,0,self.Zoom.Val*255)
	surface.SetTexture(surface.GetTextureID("gredwitch/overlay_binoculars"))
	local X = ScrW()
	local Y = ScrH()
	surface.DrawTexturedRect(0,-(X-Y)/2,X,X)
end

function SWEP:CalcViewModelView(ViewModel,OldEyePos)
	if self.Zoom.Val > 0.8 then
		return Vector(0,0,0)
	else
		return OldEyePos - Vector(0,0,1.3)
	end
end

function SWEP:Think()
	local keydown = self.Owner:KeyDown(IN_ATTACK2)
	self.Zoom.Val = math.Clamp(self.Zoom.Val + (keydown and 0.1 or -0.1),0,1)
	
	if keydown and not self.IsZooming then
		self.IsZooming = true
		self.IsUnZooming = false
		self.Weapon:SendWeaponAnim(ACT_VM_DEPLOY)
	elseif !keydown and not self.IsUnZooming and self.IsZooming then
		self.IsZooming = false
		self.IsUnZooming = true
		self.Weapon:SendWeaponAnim(ACT_VM_UNDEPLOY)
	end
end

function SWEP:CalcView(ply,pos,ang,fov)
	fov = fov - (self.Zoom.Val*self.Zoom.FOV)
	return pos,ang,fov
end

function SWEP:AdjustMouseSensitivity()
	return self.Owner:KeyDown(IN_ATTACK2) and 0.1 or 1
end

function SWEP:HandleStrike(tab)
	if self.IsCallingIn and gred.CVars.gred_sv_artisweps_spam:GetInt() <= 0 then return end
	self.IsCallingIn = true
	local tr = self.Owner:GetEyeTrace()
	local ply = self.Owner
	local SND_TAB = self.Sounds[tab.sound]
	ply.LastHit = ply.LastHit or 0
	local t = ply.LastHit + 7 <= CurTime() and "CallIn" or "CallInSuppressed"
	local SND = SND_TAB[t][math.random(1,#SND_TAB[t])]
	ply:EmitSound(SND)
	local HandleSubtitles = self.HandleSubtitles
	-- self:HandleSubtitles(ply,SND)
	local plypos = self.Owner:GetPos()
	timer.Simple(SoundDuration(SND) + 0.5, function()
		if !IsValid(self) or !IsValid(self.Weapon) or !IsValid(ply) or !ply:Alive() then
			SND = SND_TAB.RadioDidNotCopy[math.random(1,#SND_TAB.RadioDidNotCopy)]
			sound.Play(SND,plypos)
			HandleSubtitles(nil,ply,SND)
			return
		end
		self.IsCallingIn = false
		local trace = util.TraceLine({
			start = tr.HitPos,
			endpos = tr.HitPos + Vector(0,0,1000),
			filter = {ply},
		})
		if trace.Hit and !trace.HitSky then
			trace = util.TraceLine({
				start = trace.HitPos + Vector(0,0,50),
				endpos = trace.HitPos + Vector(0,0,1000),
				filter = {ply},
			})
		end
		if trace.Hit and !trace.HitSky then
			SND = SND_TAB.RadioNegative[math.random(1,#SND_TAB.RadioNegative)]
			self.Weapon:EmitSound(SND)
			self:HandleSubtitles(ply,SND)
			return
		else
			SND = SND_TAB.RadioAffirmative[math.random(1,#SND_TAB.RadioAffirmative)]
			self.Weapon:EmitSound(SND)
			self:HandleSubtitles(ply,SND)
			
			if tab.func then
				tab.func(ply,trace,tr)
			end
		end
	end)
end

function SWEP:HandleSubtitles(ply,snd)
	if ply:GetInfoNum("gred_cl_artisweps_enable_subtitles",1) == 1 then
		ply:PrintMessage(HUD_PRINTCENTER,SubTitles[snd])
	end
end

function SWEP:CanPrimaryAttack(ct)
	return self.Primary.NextShot <= ct
end

local COLOR_WHITE_HOVERED = Color(200,200,200,150)
local COLOR_WHITE = color_white
local COLOR_BLACK = color_black
local posX = {
	0.29,
	0.5,
	0.71,
	0.71,
	0.71,
	0.5,
	0.29,
	0.29,
}
local posY = {
	0.29,
	0.29,
	0.29,
	0.5,
	0.71,
	0.71,
	0.71,
	0.5,
}

function SWEP:PrimaryAttack()
	local ct = CurTime()
	
	if not self:CanPrimaryAttack(ct) then return end
	self.Primary.NextShot = ct + self.Primary.FireRate
	
	if CLIENT then
		self:CreateMenu()
	elseif SINGLEPLAYER then
		net.Start("gred_net_artisweps_singleplayer")
			net.WriteEntity(self)
		net.Send(self.Owner)
	end
end

function SWEP:CreateMenu()
	if IsValid(self.Menu) then self.Menu:Close() end
	local X = ScrW()*0.45
	local Y = ScrH()*0.75
	local DFrame = vgui.Create("DFrame")
	DFrame:SetSize(X,Y)
	DFrame:Center()
	DFrame:MakePopup()
	DFrame:SetAlpha(0)
	DFrame:AlphaTo(255,0.3)
	DFrame:ShowCloseButton(false)
	DFrame:SetTitle("")
	DFrame.Close = function(DFrame)
		if DFrame.IsClosing then return end
		DFrame.IsClosing = true
		DFrame:AlphaTo(0,0.1,0,function(tab,DFrame)
			DFrame:Remove()
		end)
	end
	DFrame.Paint = function(DFrame,x,y)
		surface.SetDrawColor(COLOR_BLACK)
		surface.DrawRect(0,Y*0.391,x,y*0.01)
		surface.DrawRect(0,Y*0.6,x,y*0.01)
		surface.DrawRect(x*0.391,0,x*0.01,y)
		surface.DrawRect(x*0.6,0,x*0.01,y)
		
		surface.SetDrawColor(COLOR_WHITE)
		surface.DrawRect(0,Y*0.393,x,y*0.006)
		surface.DrawRect(0,Y*0.603,x,y*0.006)
		surface.DrawRect(x*0.393,0,x*0.006,y)
		surface.DrawRect(x*0.602,0,x*0.006,y)
	end
	self.Menu = DFrame
	
	local DButton = vgui.Create("DButton",DFrame)
	local X_m,Y_m = X*0.5,Y*0.5
	local x,y = X*0.2,Y*0.2
	DButton:SetPos(X_m-x*0.5,Y_m-y*0.5)
	DButton:SetSize(x,y)
	DButton:SetText("Close")
	DButton:SetTextColor(COLOR_BLACK)
	DButton.Paint = function(DButton,x,y)
		if DButton:IsHovered() then
			surface.SetDrawColor(COLOR_WHITE_HOVERED)
			surface.DrawRect(0,0,x,y)
		end
	end
	DButton.DoClick = function(DButton)
		DFrame:Close()
	end
	
	local buttons = {}
	local function AddButtons(tab,DFrame,X,Y,X_m,Y_m,x,y,INDEX)
		for k,v in pairs(tab) do
			local DButton = vgui.Create("DButton",DFrame)
			X_m,Y_m = X*posX[k],Y*posY[k]
			x,y = X*0.2,Y*0.2
			DButton:SetPos(X_m-x*0.5,Y_m-y*0.5)
			DButton:SetSize(x,y)
			DButton:SetText(v.name)
			DButton:SetTextColor(COLOR_BLACK)
			DButton:SetAlpha(0)
			DButton:AlphaTo(255,0.2)
			DButton:SetToolTip(v.name)
			DButton.Paint = function(DButton,x,y)
				if DButton:IsHovered() then
					surface.SetDrawColor(COLOR_WHITE_HOVERED)
					surface.DrawRect(0,0,x,y)
				end
			end
			if v.choices or v.less then
				DButton.DoClick = function(DButton)
					for _,b in pairs(buttons) do
						if IsValid(b) then 
							b:AlphaTo(0,0.2,0,function()
								b:Remove()
							end)
						end
					end
					buttons = {}
					if v.less then
						table.remove(INDEX,#INDEX)
						table.remove(INDEX,#INDEX)
						tab = self.Choices
						for k,v in pairs(INDEX) do
							tab = tab[v]
						end
						AddButtons(tab,DFrame,X,Y,X_m,Y_m,x,y,INDEX)
					else
						table.insert(INDEX,k)
						table.insert(INDEX,"choices")
						AddButtons(v.choices,DFrame,X,Y,X_m,Y_m,x,y,INDEX)
					end
				end
			else
				DButton.DoClick = function(DButton)
					if !v.Decor then
						DFrame:Close()
						table.insert(INDEX,k)
						net.Start("gred_net_artisweps_callin")
							net.WriteEntity(self)
							net.WriteTable(INDEX)
						net.SendToServer()
					end
				end
			end
			buttons[k] = DButton
		end
	end
	AddButtons(self.Choices,DFrame,X,Y,X_m,Y_m,x,y,{})
end

function SWEP:CanSecondaryAttack(ct)
	return self.Secondary.NextShot <= ct
end

function SWEP:SecondaryAttack()
	local ct = CurTime()
	
	if not self:CanSecondaryAttack(ct) then return end
	self.Secondary.NextShot = ct + self.Secondary.FireRate
end


function SWEP:CanReload(ct)
	return self.NextReload <= ct
end

function SWEP:Reload()
	local ct = CurTime()
	
	if not self:CanReload(ct) then return end
	self.NextReload = ct + 0.3

end

