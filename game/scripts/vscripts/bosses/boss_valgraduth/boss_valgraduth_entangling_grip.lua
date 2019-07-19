boss_valgraduth_entangling_grip = class({})

function boss_valgraduth_entangling_grip:GetIntrinsicModifierName()
	return "modifier_boss_valgraduth_entangling_grip"
end

modifier_boss_valgraduth_entangling_grip = class({})
LinkLuaModifier( "modifier_boss_valgraduth_entangling_grip", "bosses/boss_valgraduth/boss_valgraduth_entangling_grip", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_valgraduth_entangling_grip:OnCreated()
	self.chance = self:GetSpecialValueFor("entangle_chance")
	self.duration = self:GetSpecialValueFor("entangle_duration")
end

function modifier_boss_valgraduth_entangling_grip:OnRefresh()
	self:OnCreated()
end

function modifier_boss_valgraduth_entangling_grip:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss_valgraduth_entangling_grip:OnAttackLanded(params)
	if self:GetAbility():IsCooldownReady() and params.attacker == self:GetParent() and self:RollPRNG( self.chance ) then
		params.target:Root( self:GetAbility(), params.attacker, self.duration )
		self:GetAbility():StartCooldown( self:GetAbility():GetCooldown( -1 ) )
		EmitSoundOn( "Hero_Treant.LeechSeed.Target", self:GetParent() )
	end
end

function modifier_boss_valgraduth_entangling_grip:IsHidden()
	return true
end