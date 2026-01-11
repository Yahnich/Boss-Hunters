juggernaut_swift_retribution = class({})

function juggernaut_swift_retribution:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown(self, iLvl)
end

function juggernaut_swift_retribution:ShouldUseResources()
	return true
end

function juggernaut_swift_retribution:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_juggernaut_swift_retribution", {duration = self:GetSpecialValueFor("duration")} )
end

function juggernaut_swift_retribution:QuickParry(caster, target)
	self.cooldown = true
	caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK_EVENT, 5 )
	if CalculateDistance( caster, target ) <= caster:GetAttackRange() then
		local direction = caster:GetForwardVector()
		local hp = target:GetHealth()
		caster:SetForwardVector( CalculateDirection( target, caster ) )
		caster:PerformAbilityAttack(target, true, self)
		local hpDiff = hp - target:GetHealth()
		caster:SetForwardVector( direction )
		
		local lifesteal = self:GetSpecialValueFor("lifesteal")
		local bonus_attacks = self:GetSpecialValueFor("bonus_attacks")
		if lifesteal > 0 then
			caster:HealEvent( hpDiff, self, caster )
		end
		if bonus_attacks > 0 then
			Timers:CreateTimer( 0.1, function()
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), caster:GetAttackRange() ) ) do
					if enemy ~= target then
						caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK_EVENT, 5 )
						local direction = caster:GetForwardVector()
						hp = enemy:GetHealth()
						caster:SetForwardVector( CalculateDirection( enemy, caster ) )
						caster:PerformAbilityAttack(enemy, true, self)
						hpDiff = hp - enemy:GetHealth()
						caster:SetForwardVector( direction )
						caster:HealEvent( hpDiff, self, caster )
						
						bonus_attacks = bonus_attacks - 1
						if bonus_attacks > 0 then
							return 0.1
						end
						return
					end
				end
			end)
		end
	end
	Timers:CreateTimer( 0.2, function() self.cooldown = false end)
	local stack_duration = self:GetSpecialValueFor("stack_duration")
	if stack_duration > 0 then
		caster:AddNewModifier(caster, self, "modifier_juggernaut_swift_retribution_talent", {duration = stack_duration})
	end
end

modifier_juggernaut_swift_retribution = class({})
LinkLuaModifier("modifier_juggernaut_swift_retribution", "heroes/hero_juggernaut/juggernaut_swift_retribution", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_swift_retribution:OnCreated()
	self:OnRefresh()
end

function modifier_juggernaut_swift_retribution:OnRefresh()
	self.chance = self:GetSpecialValueFor("parry_chance")
	self.cost = self:GetSpecialValueFor("active_momentum_cost")
end

function modifier_juggernaut_swift_retribution:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_ABSORB_SPELL, MODIFIER_EVENT_ON_ATTACK_FAIL }
end

function modifier_juggernaut_swift_retribution:OnAttackFail(params)
	if params.target == self:GetParent() 
	and self:GetParent():GetHealth() > 0 
	and self:GetParent():IsRealHero()
	and not self:GetAbility().cooldown then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		ability:QuickParry(caster, params.attacker)
	end
end

function modifier_juggernaut_swift_retribution:GetModifierTotal_ConstantBlock(params)
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	if params.attacker == self:GetParent() then return end
	if ( ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and not params.inflictor) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) )
	and self:GetParent():GetHealth() > 0 
	and self:GetParent():IsRealHero() then
		if not self:GetAbility().cooldown then
			ability:QuickParry(caster, params.attacker)
		end
		return params.damage
	end
end

function modifier_juggernaut_swift_retribution:GetAbsorbSpell(params)
	if params.ability and params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		if not self:GetAbility().cooldown then self:GetAbility():QuickParry(self:GetParent(), params.ability:GetCaster() ) end
		return 1
	end
end

function modifier_juggernaut_swift_retribution:GetEffectName()
	return "particles/units/heroes/hero_juggernaut/juggernaut_patient_defense.vpcf"
end


modifier_juggernaut_swift_retribution_talent = class({})
LinkLuaModifier("modifier_juggernaut_swift_retribution_talent", "heroes/hero_juggernaut/juggernaut_swift_retribution", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_swift_retribution_talent:OnCreated()
	self:OnRefresh()
end

function modifier_juggernaut_swift_retribution_talent:OnRefresh()
	self.as = self:GetSpecialValueFor("stack_attack_speed")
	self.ms = self:GetSpecialValueFor("stack_move_speed")
	if IsServer() then
		self:AddIndependentStack( self:GetRemainingTime() )
	end
end

function modifier_juggernaut_swift_retribution_talent:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_juggernaut_swift_retribution_talent:GetModifierAttackSpeedBonus_Constant(params)
	return self.as * self:GetStackCount()
end

function modifier_juggernaut_swift_retribution_talent:GetModifierMoveSpeedBonus_Percentage(params)
	return self.ms * self:GetStackCount()
end