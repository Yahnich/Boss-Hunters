rattletrap_reactive_shielding = class({})

function rattletrap_reactive_shielding:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_rattletrap_reactive_shielding", {duration = self:GetTalentSpecialValueFor("duration")})
	ParticleManager:FireParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_deploy.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("Hero_Rattletrap.Hookshot.Impact", caster)
	EmitSoundOn("Hero_Rattletrap.Hookshot.Damage", caster)
end

modifier_rattletrap_reactive_shielding = class({})
LinkLuaModifier("modifier_rattletrap_reactive_shielding", "heroes/hero_rattletrap/rattletrap_reactive_shielding", LUA_MODIFIER_MOTION_NONE)

function modifier_rattletrap_reactive_shielding:OnCreated()
	self.reduction = self:GetTalentSpecialValueFor("damage_reduction")
	self.slow = self:GetTalentSpecialValueFor("slow")
	if self:GetParent():HasTalent("special_bonus_unique_rattletrap_reactive_shielding_1") then self.slow = 0 end
	if IsServer() then 
		self.sisterAb = self:GetCaster():FindAbilityByName("rattletrap_automated_artillery")
		self:GetAbility():StartDelayedCooldown() 
		self.sisterAb:SetActivated(false)
		local sFX = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(sFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(sFX)
	end
end

function modifier_rattletrap_reactive_shielding:OnRefresh()
	self.reduction = self:GetTalentSpecialValueFor("damage_reduction")
	self.slow = self:GetTalentSpecialValueFor("slow")
	if self:GetParent():HasTalent("special_bonus_unique_rattletrap_reactive_shielding_1") then self.slow = 0 end
	if IsServer() then 
		self:GetAbility():StartDelayedCooldown() 
		self.sisterAb:SetActivated(false)
	end
end

function modifier_rattletrap_reactive_shielding:OnDestroy()
	if IsServer() then
		self.sisterAb:SetActivated(true)
		self:GetAbility():EndDelayedCooldown() 
	end
end

function modifier_rattletrap_reactive_shielding:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_rattletrap_reactive_shielding:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_rattletrap_reactive_shielding:GetModifierIncomingDamage_Percentage()
	return self.reduction
end