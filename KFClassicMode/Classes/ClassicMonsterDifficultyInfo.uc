class ClassicMonsterDifficultyInfo extends KFMonsterDifficultyInfo
	abstract;

defaultproperties
{
	Normal={(HealthMod=1.f,
		HeadHealthMod=1.f,
		DamageMod=1.f,
		SoloDamageMod=1.f,
		MovementSpeedMod=1.f,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
        BlockSettings={(Chance=0.0, Duration=0.0, MaxBlocks=0, Cooldown=0.0, DamagedHealthPctToTrigger=0.0,
        MeleeDamageModifier=0.0, DamageModifier=1.0, AfflictionModifier=1.0, SoloChanceMultiplier=0.0)}
	)}
	
	Hard={(HealthMod=1.35,
		HeadHealthMod=1.35,
		DamageMod=1.25,
		SoloDamageMod=1.25,
		MovementSpeedMod=1.15,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
        BlockSettings={(Chance=0.0, Duration=0.0, MaxBlocks=0, Cooldown=0.0, DamagedHealthPctToTrigger=0.0,
        MeleeDamageModifier=0.0, DamageModifier=1.0, AfflictionModifier=1.0, SoloChanceMultiplier=0.0)}
	)}
	
	Suicidal={(HealthMod=1.55,
		HeadHealthMod=1.55,
		DamageMod=1.5,
		SoloDamageMod=1.5,
		MovementSpeedMod=1.22,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
        BlockSettings={(Chance=0.0, Duration=0.0, MaxBlocks=0, Cooldown=0.0, DamagedHealthPctToTrigger=0.0,
        MeleeDamageModifier=0.0, DamageModifier=1.0, AfflictionModifier=1.0, SoloChanceMultiplier=0.0)}
	)}
	
	HellOnEarth={(HealthMod=1.75,
		HeadHealthMod=1.75,
		DamageMod=1.75,
		SoloDamageMod=1.75,
		MovementSpeedMod=1.3,
		SprintChance=1.000000,
		DamagedSprintChance=1.000000,
        BlockSettings={(Chance=0.0, Duration=0.0, MaxBlocks=0, Cooldown=0.0, DamagedHealthPctToTrigger=0.0,
        MeleeDamageModifier=0.0, DamageModifier=1.0, AfflictionModifier=1.0, SoloChanceMultiplier=0.0)}
	)}
}