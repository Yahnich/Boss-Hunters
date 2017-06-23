lich_mage_heal = class({})

function lich_mage_heal:GetIntrinsicModifierName()
	return "modifier_lich_mage_heal_ai"
end

function lich_mage_heal:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_Lich.FrostArmor", target)
	if caster:GetOwnerEntity():HasTalent("puppeteer_lich_mage_talent_1") then
		local allies = FindUnitsInRadius(self:GetCaster():GetTeam(), target:GetAbsOrigin(), nil, caster:GetOwnerEntity():FindTalentValue("puppeteer_lich_mage_talent_1"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _, ally in pairs(allies) do
			ally:Heal(ally:GetMaxHealth() * self:GetSpecialValueFor("heal") / 100, caster)
			local heal = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_dark_ritual.vpcf", PATTACH_POINT_FOLLOW, ally)
			ParticleManager:SetParticleControl(heal, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(heal, 1, ally:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(heal)
		end
	else
		target:Heal(target:GetMaxHealth() * self:GetSpecialValueFor("heal") / 100, caster)
		local heal = ParticleManager:CreateParticle("particles/units/heroes/hero_lich/lich_dark_ritual.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControl(heal, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(heal, 1, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(heal)
	end
end


LinkLuaModifier("modifier_lich_mage_heal_ai", "summons/lich_mage/lich_mage_heal.lua", LUA_MODIFIER_MOTION_NONE)
modifier_lich_mage_heal_ai = class({})

function modifier_lich_mage_heal_ai:OnCreated()
	if IsServer() then self:StartIntervalThink(0.2) end
end

function modifier_lich_mage_heal_ai:OnIntervalThink()
	if not self:GetAbility():IsFullyCastable() then return end
	if self:GetAbility():GetAutoCastState() then -- cast on random ally below health treshhold or spam on whatever ally is being attacked
		local target
		local allies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("cast_range"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _, ally in pairs(allies) do
			if ally:IsBeingAttacked() then 
				target = ally
				break
			end
		end
		if not target then
			for _, ally in pairs(allies) do
				if ally:GetHealthDeficit() > ally:GetMaxHealth() * 0.1 then 
					target = ally 
					break
				end
			end
			
		end
		if not target then return end
		self:GetCaster():Interrupt()
		ExecuteOrderFromTable({
			UnitIndex = self:GetCaster():entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = target:entindex(),
			AbilityIndex = self:GetAbility():entindex(),
			Queue = true
		})
	end
end