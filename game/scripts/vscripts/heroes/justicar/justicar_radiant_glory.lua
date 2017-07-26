justicar_radiant_glory = class({})

function justicar_radiant_glory:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	
	local speed = radius / self:GetTalentSpecialValueFor("duration")
	local damage = self:GetTalentSpecialValueFor("damage") + caster:GetInnerSun()
	caster:ResetInnerSun()
	
	local gloryFX = ParticleManager:CreateParticle("particles/heroes/justicar/justicar_radiant_glory.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(gloryFX, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(gloryFX, 1, Vector(radius, self:GetTalentSpecialValueFor("duration") * 1.33, speed))
	ParticleManager:ReleaseParticleIndex(gloryFX)
	local checkRadius = 0
	local speedTick = speed * FrameTime()
	
	EmitSoundOn("Hero_Chen.HandOfGodHealHero", caster)
	
	local checkTable = {}
	Timers:CreateTimer(FrameTime(), function()
		checkRadius = checkRadius + speedTick
		local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, checkRadius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
		for _, unit in ipairs(units) do
			if not checkTable[unit:entindex()] then
				if not unit:IsSameTeam(caster) then
					self:DealDamage(caster, unit, damage)
					unit:AddNewModifier(caster, self, "modifier_justicar_radiant_glory_miss", {duration = self:GetTalentSpecialValueFor("miss_duration")})
					EmitSoundOn("Hero_Omniknight.Repel", unit)
				elseif caster:HasTalent("justicar_radiant_glory_talent_1") then
					unit:HealEvent(damage, self, caster)
					EmitSoundOn("Hero_Omniknight.GuardianAngel", unit)
				end
				checkTable[unit:entindex()] = true
			end
		end
		if checkRadius < radius then return FrameTime() end
	end)
end

modifier_justicar_radiant_glory_miss = class({})
LinkLuaModifier("modifier_justicar_radiant_glory_miss", "heroes/justicar/justicar_radiant_glory.lua", 0)

function modifier_justicar_radiant_glory_miss:OnCreated()
	self.miss = self:GetAbility():GetTalentSpecialValueFor("miss_chance")
end

function modifier_justicar_radiant_glory_miss:OnRefresh()
	self.miss = self:GetAbility():GetTalentSpecialValueFor("miss_chance")
end

function modifier_justicar_radiant_glory_miss:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_MISS_PERCENTAGE
		}
		return funcs
	end

function modifier_justicar_radiant_glory_miss:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_justicar_radiant_glory_miss:GetEffectName()
	return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end