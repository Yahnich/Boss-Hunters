spectre_dimensional_interjection = class({})

function spectre_dimensional_interjection:GetIntrinsicModifierName()
	return "modifier_spectre_dimensional_interjection"
end

function spectre_dimensional_interjection:ShouldUseResources()
	return true
end

modifier_spectre_dimensional_interjection = class({})
LinkLuaModifier("modifier_spectre_dimensional_interjection", "heroes/hero_spectre/spectre_dimensional_interjection", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_dimensional_interjection:OnCreated()
	self.search_range = self:GetTalentSpecialValueFor("teleport_distance")
end

function modifier_spectre_dimensional_interjection:OnRefresh()
	self.search_range = self:GetTalentSpecialValueFor("teleport_distance")
end

function modifier_spectre_dimensional_interjection:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ORDER
    }
    return funcs
end

function modifier_spectre_dimensional_interjection:OnOrder(params)
	if IsServer() then
		if self:GetAbility():IsCooldownReady() and params.unit == self:GetParent() then
			if params.target and params.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET 
			and CalculateDistance( params.target, self:GetParent() ) >= self.search_range then
				if params.unit:GetAttackRange() < CalculateDistance( params.target, self:GetParent() ) then
					local parentPos = self:GetParent():GetAbsOrigin()
					local position = parentPos + CalculateDirection( params.target, parentPos ) * self.search_range
					self:Blink( position )
				end
			end
			if params.order_type == DOTA_UNIT_ORDER_CAST_TARGET or params.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
				local parentPos = self:GetParent():GetAbsOrigin()
				local distance = CalculateDistance( params.new_pos, parentPos )
				local direction = CalculateDirection( params.new_pos, parentPos )
				if params.target then
					distance = CalculateDistance( params.target, parentPos )
					direction = CalculateDirection( params.target, parentPos )
				end
				local range = math.max( self.search_range, params.ability:GetTrueCastRange() )
				if distance >= range then
					local position = parentPos + direction * self.search_range
					self:Blink( position )
				end
			end
		end
	end
end

function modifier_spectre_dimensional_interjection:Blink(position)
	local parent = self:GetParent()
	parent:EmitSound("Hero_Spectre.Reality")
	ParticleManager:FireParticle("particles/units/heroes/hero_spectre/spectre_death.vpcf", PATTACH_ABSORIGIN, parent, {[0] = parent:GetAbsOrigin()})
	FindClearSpaceForUnit(parent, position, true)
	ProjectileManager:ProjectileDodge( parent )
	ParticleManager:FireParticle("particles/econ/events/nexon_hero_compendium_2014/blink_dagger_end_glow_nexon_hero_cp_2014.vpcf", PATTACH_ABSORIGIN, parent, {[0] = parent:GetAbsOrigin()})
	parent:EmitSound("Hero_Spectre.HauntCast")
	self:GetAbility():SetCooldown()
end

function modifier_spectre_dimensional_interjection:IsHidden()
	return true
end