lycan_summon_wolves_bh = class({})

function lycan_summon_wolves_bh:OnSpellStart()
	local caster = self:GetCaster()
	caster.summonedWolves = caster.summonedWolves or {}
	for _, wolf in ipairs( caster.summonedWolves ) do
		if wolf and IsValidEntity(wolf) then
            wolf:ForceKill(true)
        end
	end
	
	
	local startPos = caster:GetAbsOrigin()
	local wolfCount = self:GetTalentSpecialValueFor("wolf_count")
	
	if caster:HasTalent("special_bonus_unique_lycan_summon_wolves_2") then 
		wolfCount = math.floor(wolfCount / 2)
	else
		caster.summonedWolves = {}
	end
	
	local distance = self:GetTalentSpecialValueFor("spawn_distance")
	EmitSoundOn("Hero_Lycan.SummonWolves", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_summon_wolves_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	for i = 1, wolfCount do
		local angPoint = QAngle(0, ((-1)^i)*30, 0)
		local fv = caster:GetForwardVector()*((-1)^( math.ceil( i/2 ) -1 ) )
		local spawnOrigin = startPos + fv * distance
		local position = RotatePosition(startPos, angPoint, spawnOrigin)

		local wolf = caster.summonedWolves[i]
		if #caster.summonedWolves < wolfCount or wolf:IsNull() or ( caster:HasTalent("special_bonus_unique_lycan_summon_wolves_2") and  not wolf:UnitCanRespawn() ) then
			self:CreateWolf(position)
		else
			wolf:RespawnUnit()
			self:ScaleWolf( wolf )
			FindClearSpaceForUnit( wolf, position, true )
			wolf:SetForwardVector(caster:GetForwardVector())
			wolf:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetTalentSpecialValueFor("wolf_duration")})
			
		end
	end
end

function lycan_summon_wolves_bh:CreateWolf(position, duration)
	local caster = self:GetCaster()
	local fDur = duration or self:GetTalentSpecialValueFor("wolf_duration")
	local wolf = caster:CreateSummon("npc_dota_lycan_wolf1", position, fDur)
	wolf:SetForwardVector(caster:GetForwardVector())
	table.insert(caster.summonedWolves, wolf)
	-- health handling
	if caster:HasTalent("special_bonus_unique_lycan_summon_wolves_2") then
		wolf:SetHasInventory(true)
		wolf:SetUnitCanRespawn(true)
		wolf:SetCanSellItems(true)
	end
	if self:GetLevel() > 1 then
		wolf:AddAbility("lycan_summon_wolves_critical_strike")
	end
	if self:GetLevel() >= 4 then
		wolf:AddAbility("lycan_summon_wolves_invisibility")
	end
	self:ScaleWolf( wolf )
end

function lycan_summon_wolves_bh:ScaleWolf( wolf )
	local wolfHP = self:GetTalentSpecialValueFor("wolf_hp")
	local wolfDamage = self:GetTalentSpecialValueFor("wolf_damage")
	wolf:SetCoreHealth(wolfHP)
	wolf:SetAverageBaseDamage(wolfDamage, 15)
	wolf:SetModelScale(0.8 + (self:GetLevel()/2)/10)
	if self:GetLevel() > 1 then
		wolf:FindAbilityByName("lycan_summon_wolves_critical_strike"):SetLevel( self:GetLevel() - 1 )
	end
	if self:GetLevel() >= 4 then
		wolf:FindAbilityByName("lycan_summon_wolves_invisibility"):SetLevel( 1 )
	end
	if self:GetLevel() >= 5 then
		wolf:SetBaseHealthRegen(25 + (self:GetLevel() - 5) * 15)
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_POINT_FOLLOW, wolf)
end