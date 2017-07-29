function FrenzyStacks(keys)
	local caster = keys.caster
	if not keys.ability:IsFullyCastable() then return end
	
	local ability = keys.ability
	EmitSoundOn("DOTA_Item.MaskOfMadness.Activate", caster)
	ability:ApplyDataDrivenModifier(caster,caster, "modifier_elite_frenzied_bonus", {duration = 5})
	caster:SetModifierStackCount("modifier_elite_frenzied_bonus",caster, 300 + 400 * (caster:GetMaxHealth() - caster:GetHealth()) / caster:GetMaxHealth() )
end

function ApplyFire(keys)
	local caster = keys.caster
	if caster:PassivesDisabled() then return end
	local ability = keys.ability
	if not caster:IsAlive() or not ability:IsFullyCastable() then return end
	local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )
	if #units == 0 then return end
	EmitSoundOn("n_black_dragon.Fireball.Target", caster)
	ability:StartCooldown(14)
	local initLoc = caster:GetAbsOrigin()
	local forwardLoc =  caster:GetForwardVector():Normalized() * 280
	
	for i = 1, 6 do
		local dummy = caster:CreateDummy(initLoc + forwardLoc * i)
		ability:ApplyDataDrivenModifier(caster, dummy, "modifier_elite_burning_dummy", {duration = 12})
		local  macropyre = ParticleManager:CreateParticle("particles/neutral_fx/black_dragon_fireball.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(macropyre, 0, dummy:GetOrigin())
			ParticleManager:SetParticleControl(macropyre, 2, Vector(12,0,0))
		ParticleManager:ReleaseParticleIndex(macropyre)
		Timers:CreateTimer(12.1, function() dummy:RemoveSelf() end)
	end
end

function BurningAura(keys)
	local damage = keys.target:GetMaxHealth() * 0.12
	-- ability:ApplyDataDrivenModifier(caster,unit,"modifier_elite_burning_health_regen_block",{duration = 0.5})
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage/keys.caster:GetSpellDamageAmp(), damage_type = DAMAGE_TYPE_MAGICAL, ability = ability })
end

function FarseerRange(keys)
	local caster = keys.caster
	local ability = keys.ability
	local bonusRange = caster:GetAttackRange() * 0.5
	caster:SetModifierStackCount("modifier_elite_farseer_passive", caster, bonusRange)
end

function CreateFrostShards(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsAlive() or not ability:IsFullyCastable() then return end
	local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )
	if #units == 0 then return end
	ability:StartCooldown(8)
	for _, unit in pairs(units) do
		
		local shardLoc = unit:GetAbsOrigin() + RandomVector(350)
		local  frostShard = ParticleManager:CreateParticle("particles/elite_freezing_parent.vpcf", PATTACH_WORLDORIGIN, nil)
			ParticleManager:SetParticleControl(frostShard, 0, shardLoc)
		EmitSoundOnLocationWithCaster(shardLoc, "hero_Crystal.frostbite", caster)
		Timers:CreateTimer(5, function() 
			ParticleManager:DestroyParticle(frostShard, false)
			ParticleManager:ReleaseParticleIndex(frostShard)
			EmitSoundOn("Hero_Ancient_Apparition.IceBlast.Target", caster)
			local targets = FindUnitsInRadius( caster:GetTeam(), shardLoc, nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )
			for _, frozenTarget in pairs(targets) do
				ApplyDamage({ victim = frozenTarget, attacker = keys.caster, damage = frozenTarget:GetMaxHealth() * 0.25/keys.caster:GetSpellDamageAmp(), damage_type = DAMAGE_TYPE_MAGICAL, ability = ability })
				ability:ApplyDataDrivenModifier(caster, frozenTarget, "modifier_elite_coldsnapped", {duration = 2})
			end
		end)
	end
end

function ApplyAttackSlow(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not ability then return end
	local target = keys.target
	ability:ApplyDataDrivenModifier(caster,target, "modifier_elite_freezing_moveslow", {duration = 5})
	ability:ApplyDataDrivenModifier(caster,target, "modifier_elite_freezing_attackslow", {duration = 5})
	local attackspeed = math.ceil(100 + target:GetIncreasedAttackSpeed() * 100)
	local slow = attackspeed / 2
	if attackspeed > 1400 then slow = slow + (attackspeed - 1400)/2 end
	target:SetModifierStackCount("modifier_elite_freezing_attackslow", caster, slow)
	target:SetModifierStackCount("modifier_elite_freezing_moveslow", caster, 100)
end

function AdjustAttackSlow(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local freezeMod = target:FindModifierByName("modifier_elite_afterfrost")
	local oldTick = freezeMod:GetRemainingTime() + 1
	local stacks = target:GetModifierStackCount("modifier_elite_freezing_moveslow", caster)
	target:SetModifierStackCount("modifier_elite_freezing_moveslow", caster, (stacks * freezeMod:GetRemainingTime()) / oldTick)
	
	local stacks2 = target:GetModifierStackCount("modifier_elite_freezing_attackslow", caster)
	target:SetModifierStackCount("modifier_elite_freezing_attackslow", caster, (stacks2 * freezeMod:GetRemainingTime()) / oldTick)
end

function Blink(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
	
	local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
	Timers:CreateTimer( 1, function()
		ParticleManager:DestroyParticle( blinkIndex, false )
		return nil
		end
	)
end

function BlinkAI(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not ability:IsCooldownReady() or caster:IsAttacking() then return end
	local enemies = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )
	local minRange = caster:GetAttackRange()
	local maxRange = 9999
	local target = nil
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (caster:GetOrigin() - enemy:GetOrigin()):Length2D()
		if enemy:IsAlive() and distanceToEnemy > minRange and distanceToEnemy < maxRange then
			maxRange = distanceToEnemy
			target = enemy
		end
	end
	if target then
		caster:SetCursorPosition(target:GetAbsOrigin() + Vector(math.random(200), math.random(200),0))
		ability:OnSpellStart()
		ability:StartCooldown(ability:GetCooldown(-1))
	end
end

function CreateBubbles(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsAlive() or not ability:IsFullyCastable() then return end
	local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )
	if #units == 0 then return end
	ability:StartCooldown(14)
	for _, unit in pairs(units) do
		local shardLoc = unit:GetAbsOrigin() + RandomVector(250)
		EmitSoundOnLocationWithCaster(shardLoc, "hero_Crystal.frostbite", caster)
		local bubble = caster:CreateDummy(shardLoc)
		ability:ApplyDataDrivenModifier(caster, bubble, "modifier_elite_temporal_aura_handler", {duration = 8})
		local bubbleFX = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chronosphere.vpcf", PATTACH_ABSORIGIN, bubble)
			ParticleManager:SetParticleControl(bubbleFX, 0, shardLoc)
			ParticleManager:SetParticleControl(bubbleFX, 1, Vector(300,300,300)) --radius
			ParticleManager:SetParticleControl(bubbleFX, 6, shardLoc)
			ParticleManager:SetParticleControl(bubbleFX, 10, shardLoc)
		Timers:CreateTimer(8, function() 
			ParticleManager:DestroyParticle(bubbleFX, false)
			ParticleManager:ReleaseParticleIndex(bubbleFX)
			bubble:RemoveSelf()
		end)
		break
	end
end


function IncreaseCD(keys)
	local ability = keys.ability
	local target = keys.target
	if target:IsMagicImmune() then return end
	for i = 0, 12 do
		local checkedAb = target:GetAbilityByIndex(i)
		if checkedAb  and not checkedAb:IsPassive() then
			if not checkedAb:IsCooldownReady() then
				local cd = checkedAb:GetCooldownTimeRemaining()
				checkedAb:EndCooldown()
				checkedAb:StartCooldown(cd + 0.06)
			else
				checkedAb:StartCooldown(0.06)
			end
		end
	end
end

function MindBlast(keys)
	local caster = keys.caster
	if caster:PassivesDisabled() then return end
	local ability = keys.ability
	local mindblast = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_sphere_shockwave.vpcf", PATTACH_POINT_FOLLOW, caster)
						ParticleManager:SetParticleControl(mindblast, 1, caster:GetOrigin())
						ParticleManager:SetParticleControl(mindblast, 3, caster:GetOrigin())
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									caster:GetAbsOrigin(), 
									caster, 
									900,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_HERO,
                                    DOTA_UNIT_TARGET_FLAG_NONE,
                                    FIND_ANY_ORDER,
                                    false)
	for _,unit in pairs(enemies) do
		ability:ApplyDataDrivenModifier(caster, unit, keys.modifierName, {duration = 4})
	end
end

function BashDamage(keys)
	local damage = keys.target:GetMaxHealth()*0.35
	if keys.caster:PassivesDisabled() then return end
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage/keys.caster:GetSpellDamageAmp(), damage_type = DAMAGE_TYPE_MAGICAL, ability = keys.ability })
end

function RootDamage(keys)
	local damage = keys.target:GetHealth()*0.15
	if keys.caster:PassivesDisabled() then return end
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage/keys.caster:GetSpellDamageAmp(), damage_type = DAMAGE_TYPE_MAGICAL, ability = keys.ability })
end

function ApplyPlague(keys)
	local target = keys.target
	local caster = keys.caster
	if caster:PassivesDisabled() then return end
	local ability = keys.ability
	local currstack = target:GetModifierStackCount(keys.counter, caster)
	target:RemoveModifierByName(keys.counter)
	ability:ApplyDataDrivenModifier(caster,target, keys.modifier, {duration = 4})
	ability:ApplyDataDrivenModifier(caster,target, keys.counter, {duration = 4})
	target:SetModifierStackCount(keys.counter, caster, currstack + 1)
end

function DecreasePlague(keys)
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local currstack = target:GetModifierStackCount(keys.counter, caster)
	target:SetModifierStackCount(keys.counter, caster, currstack - 1)
end


function PlagueDamage(keys)
	if keys.caster:PassivesDisabled() then return end
	local damage = keys.target:GetHealth()*0.03 / keys.caster:GetSpellDamageAmp()
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = keys.ability })
end

function PiercingDamage(keys)
	if keys.caster:PassivesDisabled() then return end
	local damage = keys.damage*50/(GameRules._roundnumber*25) + keys.target:GetMaxHealth() * 0.02
	ApplyDamage({ victim = keys.target, attacker = keys.caster, damage = damage/keys.caster:GetSpellDamageAmp(), damage_type = DAMAGE_TYPE_PURE, ability = keys.ability })
end

function IncreaseGrav(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsAlive() or not ability:IsFullyCastable() then return end
	local units = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, 0, false )
	if #units == 0 then return end
	ability:StartCooldown(12)
	ability:ApplyDataDrivenModifier(caster, caster, "elite_massive_increase", {duration = 5})
end

function TestGravityFunc(keys)
    local targetPos = keys.target:GetAbsOrigin()
    local casterPos = keys.caster:GetAbsOrigin()
	if keys.caster:PassivesDisabled() then return end
	if not keys.caster:IsAlive() then return end
    local direction = targetPos - casterPos
	local gravMod = 1
	if keys.caster:HasModifier("elite_massive_increase") then gravMod = 2 end
    local vec = direction:Normalized() * 4 * gravMod
	if direction:Length2D() <= 900 and direction:Length2D() >= 200 and keys.caster:IsAlive() then
		keys.target:SetAbsOrigin(targetPos - vec)
		ResolveNPCPositions(keys.target:GetAbsOrigin(), 100)
	else
		FindClearSpaceForUnit(target, targetPos, false)
	end
end

function SweepingStrikes(keys)
	if keys.caster:PassivesDisabled() then return end
	local caster = keys.caster
	local radius = caster:GetAttackRange() + caster:GetAttackRangeBuffer() + 100
	local counter = 3
	local units = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                  FIND_ANY_ORDER,
                                  false)
	for _, unit in pairs( units ) do
		if counter > 0 then
			caster:PerformAttack(unit, false, false, true, false, true, false, true)
			counter = counter - 1
		end
	end
end

function ArmorCheck(keys)
	local ability = keys.ability
	local caster = keys.caster
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									caster:GetAbsOrigin(), 
									caster, 
									FIND_UNITS_EVERYWHERE,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_HERO,
                                    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                    FIND_ANY_ORDER,
                                    false)
	local totalarmor = 0
	for _,unit in pairs(enemies) do
		totalarmor = totalarmor + unit:GetPhysicalArmorValue()
	end
	ability.armor = totalarmor / #enemies
end

function ArmorDebuff(keys)
	local target = keys.target
	local caster = keys.caster
	if keys.caster:PassivesDisabled() then return end
	local ability = keys.ability
	local armordebuff = math.ceil(ability.armor * 0.04)
	ability:ApplyDataDrivenModifier(caster,target, keys.modifier, {duration = 10})
	ability:ApplyDataDrivenModifier(caster,target, keys.counter, {duration = 10})
	local currstack = target:GetModifierStackCount(keys.counter, caster)
	target:SetModifierStackCount(keys.counter,caster, currstack + 1)
	target:SetModifierStackCount(keys.modifier,caster, armordebuff * currstack)
end

function ArmorDebuffAura(keys)
	local target = keys.target
	local caster = keys.caster
	if keys.caster:PassivesDisabled() then return end
	local ability = keys.ability
	if not ability.armor then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
										caster:GetAbsOrigin(), 
										caster, 
										FIND_UNITS_EVERYWHERE,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO,
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
										FIND_ANY_ORDER,
										false)
		local totalarmor = 0
		for _,unit in pairs(enemies) do
			totalarmor = totalarmor + unit:GetPhysicalArmorValue()
		end
		ability.armor = totalarmor / #enemies
	end
	local armordebuff = ability.armor * 0.5
	ability:ApplyDataDrivenModifier(caster,target, keys.modifier, {})
	target:SetModifierStackCount(keys.modifier,caster, armordebuff)
end

function NimbleHealth( keys )
	local caster = keys.caster
	local ability = keys.ability

	ability.caster_hp_old = ability.caster_hp_old or caster:GetMaxHealth()
	ability.caster_hp = ability.caster_hp or caster:GetMaxHealth()

	ability.caster_hp_old = ability.caster_hp
	ability.caster_hp = caster:GetHealth()
end

function NimbleHeal( keys )
	local caster = keys.caster
	local ability = keys.ability
	if keys.caster:PassivesDisabled() then return end
	caster:SetHealth(ability.caster_hp_old)
end

function UnstableFunction(keys)
	local caster = keys.caster
	local ability = keys.ability
	if keys.caster:PassivesDisabled() then return end
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
									caster:GetAbsOrigin(), 
									caster, 
									900,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
                                    DOTA_UNIT_TARGET_ALL,
                                    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                    FIND_ANY_ORDER,
                                    false)
	if not enemies then return end
	local totalhp = 0
	for _,unit in pairs(enemies) do
		totalhp = totalhp + unit:GetHealth()
	end
	local averagehp = totalhp / #enemies
	local damage = averagehp / caster:GetSpellDamageAmp()
	for _,unit in pairs(enemies) do
		if RollPercentage(15) then
			local location = unit:GetAbsOrigin() + Vector(math.random(700),math.random(700),0)
			local rnd = RandomInt(1,100)
			if rnd > 33 and rnd < 66 then
				ability:ApplyAOE({particles = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf",
								  location = location,
								  radius = 250,
								  damage = damage*0.35,
								  damage_type = DAMAGE_TYPE_MAGICAL,
								  delay = 1.5,
								  sound = "Hero_Enigma.Demonic_Conversion"})				
			elseif rnd < 33 then
				ability:ApplyAOE({particles = "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf",
								  location = location,
								  radius = 200,
								  damage = damage*0.2,
								  damage_type = DAMAGE_TYPE_MAGICAL,
								  modifier = "modifier_elite_unstable_stun",
								  duration = 2,
								  delay = 1.5,
								  sound = "Hero_Enigma.Demonic_Conversion"})
			else
				ability:ApplyAOE({particles = "particles/econ/items/kunkka/kunkka_weapon_whaleblade/kunkka_spell_torrent_splash_whaleblade.vpcf",
								  location = location,
								  radius = 250,
								  damage = damage*0.25,
								  damage_type = DAMAGE_TYPE_MAGICAL,
								  modifier = "modifier_elite_unstable_slow",
								  duration = 4,
								  delay = 1.5,
								  sound = "Hero_Enigma.Demonic_Conversion"})
			end
		end
	end
end

function Parrying(keys)
	local caster = keys.caster
	local ability = keys.ability
	if keys.caster:PassivesDisabled() then return end
	local target = keys.attacker
	if not ability:IsCooldownReady() then return end
	ability:StartCooldown(ability:GetCooldown(-1))
	caster:SetHealth(caster:GetHealth() + keys.damage + caster:GetMaxHealth()*0.02)
	local parry = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(parry, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(parry, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	local damageTable = {victim = target,
                        attacker = caster,
                        damage = target:GetHealth()*0.25 / caster:GetSpellDamageAmp(),
                        ability = keys.ability,
                        damage_type = DAMAGE_TYPE_PURE,
                        }
    ApplyDamage(damageTable)
end

function BlockSet(keys)
	local caster = keys.caster
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), 
										caster:GetAbsOrigin(), 
										caster, 
										FIND_UNITS_EVERYWHERE,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO,
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
										FIND_ANY_ORDER,
										false)
	caster.totaldamage = 0
	for _,unit in pairs(enemies) do
		caster.totaldamage = caster.totaldamage + unit:GetAverageTrueAttackDamage(unit)
		caster.averagedps = unit:GetAttacksPerSecond()
	end
	caster.averagedps = caster.averagedps / #enemies
	local block = caster.totaldamage * #enemies * keys.ability:GetSpecialValueFor("block") / 100
	caster:SetModifierStackCount("elite_blocking_block", caster ,block)
end

function BlockPurgeHeal(keys)
	local caster = keys.caster
	if keys.caster:PassivesDisabled() then return end
	caster:Purge(false, true, false, false, false)
	local heal = (caster.totaldamage * caster.averagedps) * 0.01
	if GameRules._NewGamePlus then heal = heal / 99.95 end
	caster:Heal(caster:GetMaxHealth() * 0.01 + heal, caster)
end
	