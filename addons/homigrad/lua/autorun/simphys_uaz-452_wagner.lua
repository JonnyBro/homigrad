AddCSLuaFile()

local NameLang = "UAZ-452"

local light_table = {
	ModernLights = false,
	L_HeadLampPos = Vector(-26.05, 103.3, 47.14),
	L_HeadLampAng = Angle(180, -90, 0),
	R_HeadLampPos = Vector(26.05, 103.3, 47.14),
	R_HeadLampAng = Angle(180, -90, 0),
	L_RearLampPos = Vector(-37.57, -88.16, 45.54),
	L_RearLampAng = Angle(0, -90, 0),
	R_RearLampPos = Vector(37.57, -88.16, 45.54),
	R_RearLampAng = Angle(0, -90, 0),
	Headlight_sprites = {
		{
			pos = Vector(26.05, 103.3, 47.14),
			material = "sprites/light_ignorez_new",
			size = 150
		},
		{
			pos = Vector(26.05, 103.3, 47.14),
			material = "sprites/light_ignorez_new",
			size = 75,
			color = Color(255, 255, 255)
		},
		{
			pos = Vector(31.55, 102.85, 37.23),
			material = "sprites/light_ignorez_new",
			size = 40
		},
		{
			pos = Vector(-26.05, 103.3, 47.14),
			material = "sprites/light_ignorez_new",
			size = 150
		},
		{
			pos = Vector(-26.05, 103.3, 47.14),
			material = "sprites/light_ignorez_new",
			size = 75,
			color = Color(255, 255, 255)
		},
		{
			pos = Vector(-31.55, 102.85, 37.23),
			material = "sprites/light_ignorez_new",
			size = 40
		},
	},
	Headlamp_sprites = {
		{
			pos = Vector(26.05, 103.3, 47.14),
			material = "sprites/light_ignorez_new",
			size = 150
		},
		{
			pos = Vector(-26.05, 103.3, 47.14),
			material = "sprites/light_ignorez_new",
			size = 150
		},
	},
	FogLight_sprites = {
		{
			pos = Vector(0.8, 80.15, 97.67),
			size = 75,
			material = "sprites/light_ignorez_new",
			color = Color(255, 255, 255),
			OnBodyGroups = {
				[5] = {1}
			}
		},
		{
			pos = Vector(0.8, 80.15, 97.67),
			size = 100,
			material = "sprites/light_ignorez_new",
			OnBodyGroups = {
				[5] = {1}
			}
		},
	},
	Rearlight_sprites = {
		{
			pos = Vector(37.57, -88.16, 45.54),
			size = 20,
			material = "sprites/light_ignorez_new2",
			color = Color(255, 150, 0, 150),
			OnBodyGroups = {
				[4] = {0}
			}
		},
		{
			pos = Vector(37.57, -88.16, 45.54),
			size = 40,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0),
			OnBodyGroups = {
				[4] = {0}
			}
		},
		{
			pos = Vector(-37.57, -88.16, 45.54),
			size = 20,
			material = "sprites/light_ignorez_new2",
			color = Color(255, 150, 0, 150),
			OnBodyGroups = {
				[4] = {0}
			}
		},
		{
			pos = Vector(-37.57, -88.16, 45.54),
			size = 40,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0),
			OnBodyGroups = {
				[4] = {0}
			}
		},
		{
			pos = Vector(36.46, -88.27, 46.6),
			size = 10,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0, 150),
			OnBodyGroups = {
				[4] = {1}
			}
		},
		{
			pos = Vector(36.46, -88.27, 46.1),
			size = 10,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0, 150),
			OnBodyGroups = {
				[4] = {1}
			}
		},
		{
			pos = Vector(36.46, -88.27, 44.88),
			size = 10,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0, 150),
			OnBodyGroups = {
				[4] = {1}
			}
		},
		{
			pos = Vector(36.46, -88.27, 44.39),
			size = 10,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0, 150),
			OnBodyGroups = {
				[4] = {1}
			}
		},
		{
			pos = Vector(-36.46, -88.27, 46.6),
			size = 10,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0, 150),
			OnBodyGroups = {
				[4] = {1}
			}
		},
		{
			pos = Vector(-36.46, -88.27, 46.1),
			size = 10,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0, 150),
			OnBodyGroups = {
				[4] = {1}
			}
		},
		{
			pos = Vector(-36.46, -88.27, 44.88),
			size = 10,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0, 150),
			OnBodyGroups = {
				[4] = {1}
			}
		},
		{
			pos = Vector(-36.46, -88.27, 44.39),
			size = 10,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0, 150),
			OnBodyGroups = {
				[4] = {1}
			}
		},
	},
	Brakelight_sprites = {
		{
			pos = Vector(37.57, -88.16, 42.43),
			size = 15,
			material = "sprites/light_ignorez_new2",
			color = Color(255, 150, 0, 100),
			OnBodyGroups = {
				[4] = {0}
			}
		},
		{
			pos = Vector(37.57, -88.16, 42.43),
			size = 60,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0),
			OnBodyGroups = {
				[4] = {0}
			}
		},
		{
			pos = Vector(-37.57, -88.16, 42.43),
			size = 15,
			material = "sprites/light_ignorez_new2",
			color = Color(255, 150, 0, 100),
			OnBodyGroups = {
				[4] = {0}
			}
		},
		{
			pos = Vector(-37.57, -88.16, 42.43),
			size = 60,
			material = "sprites/light_ignorez_new",
			color = Color(255, 60, 0),
			OnBodyGroups = {
				[4] = {0}
			}
		},
		{
			pos = Vector(37.56, -88.14, 42.5),
			size = 20,
			material = "sprites/light_ignorez_new2",
			color = Color(255, 65, 0),
			OnBodyGroups = {
				[4] = {1}
			}
		},
		{
			pos = Vector(-37.56, -88.14, 42.5),
			size = 20,
			material = "sprites/light_ignorez_new2",
			color = Color(255, 65, 0),
			OnBodyGroups = {
				[4] = {1}
			}
		},
	},
	Reverselight_sprites = {
		{
			pos = Vector(-18.34, -88.6, 48.7),
			size = 20,
			material = "sprites/light_ignorez_new",
			color = Color(255, 255, 255),
			OnBodyGroups = {
				[9] = {0}
			}
		},
		{
			pos = Vector(-18.34, -88.6, 48.7),
			size = 50,
			material = "sprites/light_ignorez_new",
			color = Color(220, 205, 160),
			OnBodyGroups = {
				[9] = {0}
			}
		},
	},
	Turnsignal_sprites = {
		Right = {
			{
				pos = Vector(31.55, 102.7, 39),
				material = "sprites/light_ignorez_new2",
				size = 15,
				color = Color(255, 255, 0, 100)
			},
			{
				pos = Vector(31.55, 102.85, 39),
				material = "sprites/light_ignorez_new",
				size = 60,
				color = Color(255, 120, 0)
			},
			{
				pos = Vector(40.8, 43.9, 84),
				material = "sprites/light_ignorez_new2",
				size = 15,
				color = Color(255, 255, 0, 100)
			},
			{
				pos = Vector(40.9, 43.9, 84),
				material = "sprites/light_ignorez_new",
				size = 60,
				color = Color(255, 120, 0)
			},
			{
				pos = Vector(37.57, -88.16, 48.55),
				size = 15,
				material = "sprites/light_ignorez_new2",
				color = Color(255, 255, 0, 100),
				OnBodyGroups = {
					[4] = {0}
				}
			},
			{
				pos = Vector(37.57, -88.16, 48.55),
				size = 60,
				material = "sprites/light_ignorez_new",
				color = Color(255, 120, 0),
				OnBodyGroups = {
					[4] = {0}
				}
			},
			---
			{
				pos = Vector(37.6, -88.12, 48.44),
				size = 20,
				material = "sprites/light_ignorez_new2",
				color = Color(255, 120, 0),
				OnBodyGroups = {
					[4] = {1}
				}
			},
		},
		Left = {
			{
				pos = Vector(-31.55, 102.7, 39),
				material = "sprites/light_ignorez_new2",
				size = 15,
				color = Color(255, 255, 0, 100)
			},
			{
				pos = Vector(-31.55, 102.85, 39),
				material = "sprites/light_ignorez_new",
				size = 60,
				color = Color(255, 120, 0)
			},
			{
				pos = Vector(-40.8, 43.9, 84),
				material = "sprites/light_ignorez_new2",
				size = 15,
				color = Color(255, 255, 0, 100)
			},
			{
				pos = Vector(-40.9, 43.9, 84),
				material = "sprites/light_ignorez_new",
				size = 60,
				color = Color(255, 120, 0)
			},
			{
				pos = Vector(-37.57, -88.16, 48.55),
				size = 15,
				material = "sprites/light_ignorez_new2",
				color = Color(255, 255, 0, 100),
				OnBodyGroups = {
					[4] = {0}
				}
			},
			{
				pos = Vector(-37.57, -88.16, 48.55),
				size = 60,
				material = "sprites/light_ignorez_new",
				color = Color(255, 120, 0),
				OnBodyGroups = {
					[4] = {0}
				}
			},
			{
				pos = Vector(-37.6, -88.12, 48.44),
				size = 20,
				material = "sprites/light_ignorez_new2",
				color = Color(255, 120, 0),
				OnBodyGroups = {
					[4] = {1}
				}
			},
		},
	},
}

list.Set("simfphys_lights", "uaz_452", light_table)

local V = {
	Name = NameLang,
	Model = "models/negleb/uaz_452_wagner.mdl",
	Category = "Willi302's Cars",
	Members = {
		Mass = 2000, -- масса авто
		OnTick = function(ent)
			if ent:GetLightsEnabled() then
				ent:SetSubMaterial(2, "sim_fphys_uaz_452/guages")
			else
				ent:SetSubMaterial(2, "sim_fphys_uaz_452/off")
			end
		end,
		LightsTable = "uaz_452",
		AirFriction = -300000,
		FrontWheelRadius = 16,
		RearWheelRadius = 16,
		CustomMassCenter = Vector(0, 0, -1),
		SeatOffset = Vector(-2, 0, -4),
		SeatPitch = 0,
		SpeedoMax = -1,
		ModelInfo = {
			Color = Color(154, 205, 230),
			Bodygroups = {2, 2},
		},
		PassengerSeats = {
			{
				pos = Vector(25, 63, 38),
				ang = Angle(0, 0, 14)
			},
			{
				pos = Vector(30, -30, 40),
				ang = Angle(0, 0, 14)
			},
			{
				pos = Vector(-30, -30, 40),
				ang = Angle(0, 0, 14)
			},
			{
				pos = Vector(-13, -30, 40),
				ang = Angle(0, 0, 14)
			},
			{
				pos = Vector(-30, 28, 40),
				ang = Angle(0, 180, 14)
			},
			{
				pos = Vector(-9, 28, 40),
				ang = Angle(0, 180, 14)
			},
			{
				pos = Vector(12, 28, 40),
				ang = Angle(0, 180, 14)
			},
		},
		ExhaustPositions = {
			{
				pos = Vector(12, -88.3, 22.35),
				ang = Angle(90, -90, 0),
			},
		},
		StrengthenSuspension = false,
		FrontHeight = 9,
		FrontConstant = 43000,
		FrontDamping = 3000,
		FrontRelativeDamping = 3000,
		RearHeight = 9,
		RearConstant = 43000,
		RearDamping = 3000,
		RearRelativeDamping = 3000,
		FastSteeringAngle = 10,
		SteeringFadeFastSpeed = 535,
		TurnSpeed = 4,
		MaxGrip = 45,
		Efficiency = 1,
		GripOffset = -3,
		BrakePower = 60,
		IdleRPM = 650,
		LimitRPM = 5000,
		Revlimiter = false,
		PeakTorque = 100,
		PowerbandStart = 750,
		PowerbandEnd = 4000,
		Turbocharged = false,
		Supercharged = false,
		Backfire = false,
		FuelFillPos = Vector(-43.65, 13.9, 38.7),
		FuelType = FUELTYPE_PETROL,
		FuelTankSize = 77,
		PowerBias = 0,
		EngineSoundPreset = -1,
		snd_pitch = 0.85,
		snd_idle = "vehicles/sim_fphys_uaz-452/idle.wav",
		snd_low = "vehicles/sim_fphys_uaz-452/low.wav",
		snd_low_revdown = "vehicles/sim_fphys_uaz-452/low.wav",
		snd_low_pitch = 0.8,
		snd_mid = "vehicles/sim_fphys_uaz-452/mid.wav",
		snd_mid_gearup = "vehicles/sim_fphys_uaz-452/second.wav",
		snd_mid_geardown = "vehicles/sim_fphys_uaz-452/second.wav",
		snd_mid_pitch = 0.8,
		snd_horn = "simulated_vehicles/horn_7.wav",
		DifferentialGear = 0.4,
		Gears = {-0.15, 0, 0.15, 0.275, 0.4, 0.5}
	}
}

if file.Exists("models/negleb/uaz_452_wagner.mdl", "GAME") then
	list.Set("simfphys_vehicles", "sim_fphys_uaz-452_wagner", V)
end