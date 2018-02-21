beast_hawk_spirit = class({})
LinkLuaModifier( "modifier_hawk_spirit", "heroes/hero_beast/beast_hawk_spirit.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hawk_spirit_ally", "heroes/hero_beast/beast_hawk_spirit.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hawk_spirit_enemy", "heroes/hero_beast/beast_hawk_spirit.lua" ,LUA_MODIFIER_MOTION_NONE )

function beast_hawk_spirit:IsStealable()
	return true
end

function beast_hawk_spirit:IsHiddenWhenStolen()
	return false
end

function beast_hawk_spirit:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Beastmaster.Call.Hawk", caster)

	local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
	for _,unit in pairs(units) do
		if unit:GetUnitName() == "npc_dota_beastmaster_hawk_1" then
			unit:ForceKill(false)
		end
	end

	local hawk = caster:CreateSummon("npc_dota_beastmaster_hawk_1", caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("duration"))

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_call_bird.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx, 0, hawk:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(nfx)

	hawk:AddNewModifier(caster, self, "modifier_hawk_spirit", {})

	if caster:HasTalent("special_bonus_unique_beast_hawk_spirit_2") then
		local hawk2 = caster:CreateSummon("npc_dota_beastmaster_hawk_1", caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("duration"))
		hawk2:AddNewModifier(caster, self, "modifier_hawk_spirit", {})
	end
end

modifier_hawk_spirit = class({})
function modifier_hawk_spirit:OnCreated(table)
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_beast/beast_hawk_spirit_aura/beast_hawk_spirit_aura.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
		ParticleManager:SetParticleControl(self.nfx, 1, Vector(self:GetTalentSpecialValueFor("radius"), 0, 0))

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_hawk_spirit:OnIntervalThink()
	local units = self:GetCaster():FindAllUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
	for _,unit in pairs(units) do
		if unit:GetTeam() == self:GetCaster():GetTeam() then
			if unit ~= self:GetParent() then
				unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_hawk_spirit_ally", {Duration = 1.0})
			end
		else
			if self:GetCaster():HasTalent("special_bonus_unique_beast_hawk_spirit_1") then
				unit:DisableHeal(self:GetAbility(), self:GetCaster(), 0.1)
			end
		end
	end
end

function modifier_hawk_spirit:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx, false)
		StopSoundOn("Hero_Beastmaster.Call.Hawk", self:GetCaster())
	end
end

function modifier_hawk_spirit:IsDebuff()
	return false
end

modifier_hawk_spirit_ally = class({})
function modifier_hawk_spirit_ally:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
	return funcs
end

function modifier_hawk_spirit_ally:GetModifierConstantManaRegen()
	return self:GetTalentSpecialValueFor("mana_regen")
end

function modifier_hawk_spirit_ally:GetModifierHealthRegenPercentage()
	return self:GetTalentSpecialValueFor("health_regen")
end

function modifier_hawk_spirit_ally:IsDebuff()
	return false
end