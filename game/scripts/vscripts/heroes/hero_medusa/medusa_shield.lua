medusa_shield = class({})
LinkLuaModifier("modifier_medusa_shield", "heroes/hero_medusa/medusa_shield", LUA_MODIFIER_MOTION_NONE)

function medusa_shield:IsStealable()
	return false
end

function medusa_shield:IsHiddenWhenStolen()
	return false
end

function medusa_shield:OnToggle()
	local caster = self:GetCaster()

	if self:GetToggleState() then
		EmitSoundOn("Hero_Medusa.ManaShield.On", caster)
		caster:AddNewModifier(caster, self, "modifier_medusa_shield", {})
	else
		EmitSoundOn("Hero_Medusa.ManaShield.Off", caster)
		caster:RemoveModifierByName("modifier_medusa_shield")
	end
end

modifier_medusa_shield = class({})

function modifier_medusa_shield:OnCreated(table)
	if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self.damageMana = self:GetTalentSpecialValueFor("damage_per_mana")
		self.absorb = self:GetTalentSpecialValueFor("absorb")
	end
end

function modifier_medusa_shield:OnRefresh(table)
	if IsServer() then
		self.damageMana = self:GetTalentSpecialValueFor("damage_per_mana")
		self.absorb = self:GetTalentSpecialValueFor("absorb")
	end
end

function modifier_medusa_shield:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }

    return funcs
end

function modifier_medusa_shield:GetModifierIncomingDamage_Percentage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local ogDamage = params.original_damage
		if target == caster then
			if caster:GetMana() > self.damageMana then
				EmitSoundOn("Hero_Medusa.ManaShield.Proc", caster)
				caster:SpendMana(ogDamage/self.damageMana, self:GetAbility())
			else
				self:GetAbility():ToggleAbility()
			end
		end
		return -self.absorb
	end
end