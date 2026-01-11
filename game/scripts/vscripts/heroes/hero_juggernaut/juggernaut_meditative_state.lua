juggernaut_meditative_state = class({})

function juggernaut_meditative_state:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("buff_duration")
	caster:AddNewModifier( caster, self, "modifier_juggernaut_meditative_state", {duration = duration} )
	if self:GetSpecialValueFor("aspd") ~= 0 then
		caster:AddNewModifier(caster, self, "modifier_juggernaut_meditative_state_sohei", {duration = duration})
	else
		caster:AddNewModifier(caster, self, "modifier_juggernaut_meditative_state_ronin_buff", {duration = duration})
	end
	if self:GetSpecialValueFor("positive_aura") ~= 0 then
		for _, allies in ipairs(caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("positive_aura"))) do
			allies:AddNewModifier(caster, self, "modifier_juggernaut_meditative_state", {duration = duration})
		end
	end
	if self:GetSpecialValueFor("negative_aura") ~= 0 then
		caster:AddNewModifier(caster, self, "modifier_juggernaut_meditative_state_asura", {duration = duration})
	end
end

modifier_juggernaut_meditative_state = class({})
LinkLuaModifier("modifier_juggernaut_meditative_state", "heroes/hero_juggernaut/juggernaut_meditative_state", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_meditative_state:OnCreated()
	self:OnRefresh()
	if IsServer() then
		local parent = self:GetParent()
		parent:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_juggernaut_meditative_state_regen", {} )
		local fire = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf", PATTACH_POINT_FOLLOW, parent )
		ParticleManager:SetParticleControlEnt(fire, 0, parent, PATTACH_POINT_FOLLOW, "attach_head", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl( fire, 1, Vector(self.radius, 0, -self.radius ) )
		ParticleManager:SetParticleControlEnt(fire, 2, parent, PATTACH_POINT_FOLLOW, "attach_head", parent:GetAbsOrigin(), true)
		self:AddEffect(fire)
		self:StartIntervalThink(0)
	end
end

function modifier_juggernaut_meditative_state:OnRefresh()
	self.radius = self:GetSpecialValueFor("particle_radius")
	self.linger = self:GetSpecialValueFor("linger_duration")
	self.regen = self:GetSpecialValueFor("regeneration")
end

function modifier_juggernaut_meditative_state:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_juggernaut_meditative_state_regen")
	end
end

function modifier_juggernaut_meditative_state:OnIntervalThink()
	local parent = self:GetParent()
	if parent:IsMoving() then
		if self.nextCheckDisabled then
			self:StartIntervalThink(0.1)
			--[[
			for _, unit in ipairs( parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
				unit:RemoveModifierByName("modifier_juggernaut_meditative_state_regen")
			end]]
			parent:RemoveModifierByName("modifier_juggernaut_meditative_state_regen")
		else
			self:StartIntervalThink(self.linger)
			self.nextCheckDisabled = true
		end
	else
		if self.nextCheckDisabled then
			self.nextCheckDisabled = false
			parent:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_juggernaut_meditative_state_regen", {} )
		end
	end
end


--[[ is the base skill supposed to heal or just the regen state
function modifier_juggernaut_meditative_state:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_juggernaut_meditative_state:GetModifierHealthRegenPercentage()
	return self.regen
end]]

modifier_juggernaut_meditative_state_regen = class({})
LinkLuaModifier("modifier_juggernaut_meditative_state_regen", "heroes/hero_juggernaut/juggernaut_meditative_state", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_meditative_state_regen:OnCreated()
	self.regen = self:GetSpecialValueFor("regeneration")
end

function modifier_juggernaut_meditative_state_regen:OnRefresh()
	self.regen = self:GetSpecialValueFor("regeneration")
end

function modifier_juggernaut_meditative_state_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_juggernaut_meditative_state_regen:GetModifierHealthRegenPercentage()
	return self.regen
end

modifier_juggernaut_meditative_state_asura = class({})
LinkLuaModifier("modifier_juggernaut_meditative_state_asura", "heroes/hero_juggernaut/juggernaut_meditative_state", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_meditative_state_asura:IsHidden()
	return true
end

function modifier_juggernaut_meditative_state_asura:OnCreated()
	self:OnRefresh()
end

function modifier_juggernaut_meditative_state_asura:OnRefresh()
	self.negative_damage = self:GetSpecialValueFor("negative_damage") / 100
	self.radius = self:GetSpecialValueFor("negative_aura")
	self:StartIntervalThink(0.2)
end

function modifier_juggernaut_meditative_state_asura:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local maxHP = parent:GetMaxHealth()
	local damage = maxHP * self.negative_damage

	for _, enemy in ipairs(parent:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius)) do
		self:GetAbility():DealDamage(caster, enemy, damage)
	end
end

function modifier_juggernaut_meditative_state_asura:OnDestroy()
	self:StartIntervalThink(-1)
end

modifier_juggernaut_meditative_state_sohei = class({})
LinkLuaModifier("modifier_juggernaut_meditative_state_sohei", "heroes/hero_juggernaut/juggernaut_meditative_state", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_meditative_state_sohei:IsHidden()
	return true
end

function modifier_juggernaut_meditative_state_sohei:OnCreated()
	self:OnRefresh()
end

function modifier_juggernaut_meditative_state_sohei:OnRefresh()
	self.pulse_interval = self:GetSpecialValueFor("pulse_interval")
	self.pulse_radius = self:GetSpecialValueFor("pulse_radius")
	self.buff_duration = self:GetSpecialValueFor("extra_buff_duration")
	if IsServer() then self:StartIntervalThink(self.pulse_interval) end
end

function modifier_juggernaut_meditative_state_sohei:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	ParticleManager:CreateParticle("particles/econ/items/venomancer/veno_2022_immortal_tail/veno_2022_immortal_poison_nova_shockwave_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	for _, allies in ipairs(parent:FindFriendlyUnitsInRadius(parent:GetAbsOrigin(), self.pulse_radius)) do
		allies:AddNewModifier(caster, self:GetAbility(), "modifier_juggernaut_meditative_state_sohei_buff",{duration = self.buff_duration})
	end
end

modifier_juggernaut_meditative_state_sohei_buff = class({})
LinkLuaModifier("modifier_juggernaut_meditative_state_sohei_buff", "heroes/hero_juggernaut/juggernaut_meditative_state", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_meditative_state_sohei_buff:OnCreated()
	self:OnRefresh()
end

function modifier_juggernaut_meditative_state_sohei_buff:OnRefresh()
	self.aspd = self:GetSpecialValueFor("aspd")
end

function modifier_juggernaut_meditative_state_sohei_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_juggernaut_meditative_state_sohei_buff:GetModifierAttackSpeedBonus_Constant()
	return self.aspd
end

modifier_juggernaut_meditative_state_ronin_buff = class({})
LinkLuaModifier("modifier_juggernaut_meditative_state_ronin_buff", "heroes/hero_juggernaut/juggernaut_meditative_state", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_meditative_state_ronin_buff:OnCreated()
	self:OnRefresh()
end

function modifier_juggernaut_meditative_state_ronin_buff:OnRefresh()
	self.armor = self:GetSpecialValueFor("armor")
	self.mres = self:GetSpecialValueFor("mres")
end

function modifier_juggernaut_meditative_state_ronin_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_juggernaut_meditative_state_ronin_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_juggernaut_meditative_state_ronin_buff:GetModifierMagicalResistanceBonus()
	return self.mres
end