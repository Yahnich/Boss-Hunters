item_father_pipe = class({})
LinkLuaModifier( "modifier_item_father_pipe_active", "items/item_father_pipe.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_father_pipe_passive", "items/item_father_pipe.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_father_pipe:GetIntrinsicModifierName()
	return "modifier_item_father_pipe_passive"
end

function item_father_pipe:OnSpellStart()
	local caster = self:GetCaster()
	
	local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,friend in pairs(allies) do
		friend:AddNewModifier(caster, self, "modifier_item_father_pipe_active", {Duration = self:GetSpecialValueFor("duration")}):SetStackCount(self:GetSpecialValueFor("block"))
	end
end

modifier_item_father_pipe_passive = class(itemBaseClass)
function modifier_item_father_pipe_passive:OnCreated()
	self.stat = self:GetSpecialValueFor("bonus_all")
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_father_pipe_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_father_pipe_passive:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_father_pipe_passive:GetModifierBonusStats_Agility()
	return self.stat
end

function modifier_item_father_pipe_passive:GetModifierBonusStats_Intellect()
	return self.stat
end

function modifier_item_father_pipe_passive:IsAura()
	return true
end

function modifier_item_father_pipe_passive:GetModifierAura()
	return "modifier_item_father_pipe_aura"
end

function modifier_item_father_pipe_passive:GetAuraRadius()
	return self.radius
end

function modifier_item_father_pipe_passive:GetAuraDuration()
	return 0.5
end

function modifier_item_father_pipe_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_father_pipe_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_father_pipe_passive:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_father_pipe_passive:IsHidden()
	return true
end

function modifier_item_father_pipe_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


modifier_item_father_pipe_aura = class({})
LinkLuaModifier( "modifier_item_father_pipe_aura", "items/item_father_pipe.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_father_pipe_aura:OnCreated()
	self.magic_resist = self:GetSpecialValueFor("aura_magic_resist")
	self.hp_regen = self:GetSpecialValueFor("hp_regen")
end

function modifier_item_father_pipe_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_item_father_pipe_aura:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_item_father_pipe_aura:GetModifierConstantHealthRegen()
	return self.hp_regen
end


modifier_item_father_pipe_active = class({})
function modifier_item_father_pipe_active:OnCreated(table)
	self.block = self:GetSpecialValueFor("block")

	if IsServer() then
		local target = self:GetParent()
		local radius = target:GetModelRadius() * 2
		local nfx = ParticleManager:CreateParticle("particles/items2_fx/pipe_of_insight.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nfx, 2, Vector(radius, 0, 0))
		self:AddEffect(nfx)
	end
end

function modifier_item_father_pipe_active:OnRefresh(table)
	self.block = self:GetSpecialValueFor("block")
end

function modifier_item_father_pipe_active:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL}
end

function modifier_item_father_pipe_active:OnTakeDamage(params)
	local hero = self:GetParent()
    local damage = params.damage
	local dmgtype = params.damage_type
	local attacker = params.attacker

	if attacker:GetTeamNumber() ~= hero:GetTeamNumber() and dmgtype == DAMAGE_TYPE_MAGICAL then
		if params.unit == hero then
			if self:GetStackCount() > 1 and damage < self.block then
				self.block = self.block - damage
				self:SetStackCount(self.block)
			else
				local newDamage = damage - self.block
				hero:SetHealth(hero:GetHealth() - newDamage)
				self:Destroy()
			end
		end
	end
end

function modifier_item_father_pipe_active:GetAbsoluteNoDamageMagical()
	return true
end