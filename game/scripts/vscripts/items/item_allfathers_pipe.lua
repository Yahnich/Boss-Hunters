item_allfathers_pipe = class({})

function item_allfathers_pipe:GetIntrinsicModifierName()
	return "modifier_item_allfathers_pipe_passive"
end

function item_allfathers_pipe:OnSpellStart()
	local caster = self:GetCaster()
	
	local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("barrier_radius"))
	for _,friend in pairs(allies) do
		friend:AddNewModifier(caster, self, "modifier_item_allfathers_pipe_active", {Duration = self:GetSpecialValueFor("duration")})
	end
end

item_allfathers_pipe_2 = class(item_allfathers_pipe)
item_allfathers_pipe_3 = class(item_allfathers_pipe)
item_allfathers_pipe_4 = class(item_allfathers_pipe)
item_allfathers_pipe_5 = class(item_allfathers_pipe)
item_allfathers_pipe_6 = class(item_allfathers_pipe)
item_allfathers_pipe_7 = class(item_allfathers_pipe)
item_allfathers_pipe_8 = class(item_allfathers_pipe)
item_allfathers_pipe_9 = class(item_allfathers_pipe)

modifier_item_allfathers_pipe_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_allfathers_pipe_active", "items/item_allfathers_pipe.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_allfathers_pipe_passive:OnCreatedSpecific()
	self.mr = self:GetSpecialValueFor("magic_resist")
	self.radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_item_allfathers_pipe_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS )
	return funcs
end

function modifier_item_allfathers_pipe_passive:GetModifierMagicalResistanceBonus(params)
	return self.mr
end

function modifier_item_allfathers_pipe_passive:IsAura()
	return true
end

function modifier_item_allfathers_pipe_passive:GetModifierAura()
	return "modifier_item_allfathers_pipe_aura"
end

function modifier_item_allfathers_pipe_passive:GetAuraRadius()
	return self.radius
end

function modifier_item_allfathers_pipe_passive:GetAuraDuration()
	return 0.5
end

function modifier_item_allfathers_pipe_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_allfathers_pipe_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_allfathers_pipe_passive:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_allfathers_pipe_passive:IsHidden()
	return true
end

function modifier_item_allfathers_pipe_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


modifier_item_allfathers_pipe_aura = class({})
LinkLuaModifier( "modifier_item_allfathers_pipe_aura", "items/item_allfathers_pipe.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_allfathers_pipe_aura:OnCreated()
	self.magic_resist = self:GetSpecialValueFor("aura_resist")
end

function modifier_item_allfathers_pipe_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_item_allfathers_pipe_aura:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

modifier_item_allfathers_pipe_active = class({})
LinkLuaModifier( "modifier_item_allfathers_pipe_passive", "items/item_allfathers_pipe.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_allfathers_pipe_active:OnCreated(table)
	self:OnRefresh()
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

function modifier_item_allfathers_pipe_active:OnRefresh(table)
	self.block = self:GetSpecialValueFor("barrier")
	self:SetStackCount( self.block )
end

function modifier_item_allfathers_pipe_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			}
end

function modifier_item_allfathers_pipe_active:GetModifierIncomingDamage_Percentage(params)
	local hero = self:GetParent()
    local damage = params.damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
	if params.damage < 0 then return end
	if params.unit == hero and params.inflictor then
		if self:GetStackCount() > 1 and damage < self.block then
			self.block = self.block - damage
			self:SetStackCount(self.block)
			return -999
		else
			local newDamage = damage - self.block
			hero:SetHealth(hero:GetHealth() - newDamage)
			self:Destroy()
		end
	end
end