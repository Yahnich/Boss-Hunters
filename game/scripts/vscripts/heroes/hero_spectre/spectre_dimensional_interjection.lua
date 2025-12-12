spectre_dimensional_interjection = class({})

function spectre_dimensional_interjection:GetIntrinsicModifierName()
	return "modifier_spectre_dimensional_interjection"
end

function spectre_dimensional_interjection:ShouldUseResources()
	return true
end

function spectre_dimensional_interjection:Blink(position)
	local caster = self:GetCaster()
	ParticleManager:FireParticle("particles/units/heroes/hero_spectre/spectre_death.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	
	if caster:IsRealHero() then
		caster:EmitSound("Hero_Spectre.Reality")
		if caster:HasScepter() then
			local haunt = caster:FindAbilityByName("spectre_haunt_bh")
			if haunt and haunt:GetLevel() > 0 then
				local duration = self:GetSpecialValueFor("scepter_duration")
				haunt:SpawnHauntIllusion( caster:GetAbsOrigin( ), duration )
			end
		end
	end
	
	FindClearSpaceForUnit(caster, position, true)
	ProjectileManager:ProjectileDodge( caster )
	ParticleManager:FireParticle("particles/econ/events/nexon_hero_compendium_2014/blink_dagger_end_glow_nexon_hero_cp_2014.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	caster:EmitSound("Hero_Spectre.HauntCast")
	self:SetCooldown()
end

modifier_spectre_dimensional_interjection = class({})
LinkLuaModifier("modifier_spectre_dimensional_interjection", "heroes/hero_spectre/spectre_dimensional_interjection", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_dimensional_interjection:OnCreated()
	self.search_range = self:GetSpecialValueFor("teleport_distance")
end

function modifier_spectre_dimensional_interjection:OnRefresh()
	self.search_range = self:GetSpecialValueFor("teleport_distance")
end

function modifier_spectre_dimensional_interjection:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ORDER
    }
    return funcs
end

function modifier_spectre_dimensional_interjection:OnOrder(params)
	if IsServer() then	
		local ability = self:GetAbility()
		if ability:IsCooldownReady() and params.unit == self:GetParent() and not self:GetParent():IsRooted() then
			if params.target and ( params.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET )
			and params.unit:GetAttackRange() + params.target:GetHullRadius() + params.target:GetCollisionPadding() <= CalculateDistance( params.target, self:GetParent() ) then
				if params.unit:HasModifier("modifier_spectre_spectral_dagger_bh") and params.unit:HasModifier("modifier_spectre_spectral_dagger_bh") then
					local attackPos = params.target:GetAbsOrigin()
					local position = attackPos + CalculateDirection( params.unit, attackPos ) * params.unit:GetAttackRange()
					ability:Blink( position )
				elseif CalculateDistance( params.target, self:GetParent() ) >= self.search_range then
					local parentPos = self:GetParent():GetAbsOrigin()
					local position = parentPos + CalculateDirection( params.target, parentPos ) * self.search_range
					ability:Blink( position )
				end
			end
			if ( params.order_type == DOTA_UNIT_ORDER_CAST_TARGET or params.order_type == DOTA_UNIT_ORDER_CAST_POSITION )
			and params.ability:GetCooldown( params.ability:GetLevel() ) > 0 then
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
					ability:Blink( position )
				end
			end
		end
	end
end

function modifier_spectre_dimensional_interjection:IsHidden()
	return true
end