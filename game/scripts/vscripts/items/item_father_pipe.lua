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
		if not friend:HasModifier("modifier_item_barrier_leaves") then
			friend:AddNewModifier(caster, self, "modifier_item_father_pipe_active", {Duration = self:GetSpecialValueFor("duration")}):SetStackCount(self:GetSpecialValueFor("block"))
		end
	end
end

modifier_item_father_pipe_passive = class({})
function modifier_item_father_pipe_passive:OnCreated()
	self.hp_regen = self:GetSpecialValueFor("hp_regen")
end

function modifier_item_father_pipe_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_item_father_pipe_passive:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_father_pipe_passive:IsHidden()
	return true
end

function modifier_item_father_pipe_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
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