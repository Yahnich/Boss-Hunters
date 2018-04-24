item_barrier_leaves = class({})
LinkLuaModifier( "modifier_item_barrier_leaves", "items/item_barrier_leaves.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_barrier_leaves:OnSpellStart()
	local caster = self:GetCaster()
	
	if not caster:HasModifier("modifier_item_father_pipe_active") then
		caster:AddNewModifier(caster, self, "modifier_item_barrier_leaves", {Duration = self:GetSpecialValueFor("duration")}):SetStackCount(self:GetSpecialValueFor("block"))
	end
end

modifier_item_barrier_leaves = class({})
function modifier_item_barrier_leaves:OnCreated(table)
	self.block = self:GetSpecialValueFor("block")

	if IsServer() then
		local target = self:GetParent()
		local radius = target:GetModelRadius() * 2
		local nfx = ParticleManager:CreateParticle("particles/items2_fx/pipe_of_insight.vpcf", PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nfx, 2, Vector(radius, 0, 0))
		self:AddEffect(nfx)
	end
end

function modifier_item_barrier_leaves:OnRefresh(table)
	self.block = self:GetSpecialValueFor("block")
end

function modifier_item_barrier_leaves:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL}
end

function modifier_item_barrier_leaves:OnTakeDamage(params)
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

function modifier_item_barrier_leaves:GetAbsoluteNoDamageMagical()
	return true
end