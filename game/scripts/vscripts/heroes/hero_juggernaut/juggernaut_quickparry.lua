juggernaut_quickparry = class({})

function juggernaut_quickparry:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown(self, iLvl)
end

function juggernaut_quickparry:ShouldUseResources()
	return true
end

function juggernaut_quickparry:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_juggernaut_quickparry", {duration = self:GetTalentSpecialValueFor("duration")} )
end

function juggernaut_quickparry:QuickParry(caster, target)
	
	caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK_EVENT, 5 )
	if CalculateDistance( caster, target ) <= caster:GetAttackRange() then
		local direction = caster:GetForwardVector()
		local hp = target:GetHealth()
		caster:SetForwardVector( CalculateDirection( target, caster ) )
		caster:PerformAbilityAttack(target, true, self)
		local hpDiff = hp - target:GetHealth()
		caster:SetForwardVector( direction )
		if caster:HasTalent("special_bonus_unique_juggernaut_quickparry_2") then
			caster:HealEvent( hpDiff, self, caster )
			Timers:CreateTimer( 0.2, function()
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
						break
					end
				end
			end)
		end
	end
	if caster:HasTalent("special_bonus_unique_juggernaut_quickparry_2") then
		caster:AddNewModifier(caster, self, "modifier_juggernaut_quickparry_talent", {duration = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "duration")})
	end
end

modifier_juggernaut_quickparry = class({})
LinkLuaModifier("modifier_juggernaut_quickparry", "heroes/hero_juggernaut/juggernaut_quickparry", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_quickparry:OnCreated()
	self.chance = self:GetAbility():GetTalentSpecialValueFor("parry_chance")
	self.cost = self:GetAbility():GetTalentSpecialValueFor("active_momentum_cost")
end

function modifier_juggernaut_quickparry:OnRefresh()
	self.chance = self:GetAbility():GetTalentSpecialValueFor("parry_chance")
	self.cost = self:GetAbility():GetTalentSpecialValueFor("active_momentum_cost")
end

function modifier_juggernaut_quickparry:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_ABSORB_SPELL}
end

function modifier_juggernaut_quickparry:GetModifierTotal_ConstantBlock(params)
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	if params.attacker == self:GetParent() then return end
	if ( ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and not params.inflictor) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) )
	and self:GetParent():GetHealth() > 0 
	and self:GetParent():IsRealHero() then
		ability:QuickParry(caster, params.attacker)
		return params.damage
	end
end

function modifier_juggernaut_quickparry:GetAbsorbSpell(params)
	if params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		self:GetAbility():QuickParry(self:GetParent(), params.ability:GetCaster() )
		return 1
	end
end

function modifier_juggernaut_quickparry:GetEffectName()
	return "particles/units/heroes/hero_juggernaut/juggernaut_patient_defense.vpcf"
end


modifier_juggernaut_quickparry_talent = class({})
LinkLuaModifier("modifier_juggernaut_quickparry_talent", "heroes/hero_juggernaut/juggernaut_quickparry", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_quickparry_talent:OnCreated()
	local caster = self:GetCaster()
	self.as = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "as")
	self.ms = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "ms")
	if IsServer() then self:SetStackCount(1) end
end

function modifier_juggernaut_quickparry_talent:OnRefresh()
	local caster = self:GetCaster()
	self.as = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "as")
	self.ms = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "ms")
	if IsServer() then
		self:AddIndependentStack( self:GetRemainingTime() )
	end
end

function modifier_juggernaut_quickparry_talent:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_juggernaut_quickparry_talent:GetModifierAttackSpeedBonus(params)
	return self.as * self:GetStackCount()
end

function modifier_juggernaut_quickparry_talent:GetModifierMoveSpeedBonus_Percentage(params)
	return self.ms * self:GetStackCount()
end