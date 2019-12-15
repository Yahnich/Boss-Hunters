axe_forced_shout = class({})
LinkLuaModifier( "modifier_forced_shout", "heroes/hero_axe/axe_forced_shout.lua" ,LUA_MODIFIER_MOTION_NONE )

function axe_forced_shout:PiercesDisableResistance()
    return true
end

function axe_forced_shout:IsStealable()
	return true
end

function axe_forced_shout:IsHiddenWhenStolen()
	return false
end

--------------------------------------------------------------------------------
function axe_forced_shout:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Axe.Berserkers_Call", self:GetCaster())

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_mouth", caster:GetAbsOrigin(), true)
	
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb(self) then
			if caster:IsAlive() and enemy then
				enemy:Taunt(self,caster,self:GetTalentSpecialValueFor("duration"))
			else
				enemy:Stop()
			end
		end
	end
	caster:AddNewModifier(caster,self,"modifier_forced_shout",{Duration = self:GetTalentSpecialValueFor("duration")})

	self:StartDelayedCooldown(self:GetTalentSpecialValueFor("duration"))
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_forced_shout = class({})
function modifier_forced_shout:OnCreated(table)
	-- self.armor = self:GetCaster():GetPhysicalArmorValue(false) + self:GetCaster():GetPhysicalArmorValue(false) * self:GetTalentSpecialValueFor("armor_bonus")/100
	self.armor = self:GetTalentSpecialValueFor("armor_bonus_base")
end

function modifier_forced_shout:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_forced_shout:GetModifierPhysicalArmorBonus()
	return self.armor
end