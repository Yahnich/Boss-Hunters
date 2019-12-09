boss_centaur_bash = class({})

function boss_centaur_bash:GetIntrinsicModifierName()
	return "modifier_boss_centaur_bash"
end

modifier_boss_centaur_bash = class({})
LinkLuaModifier( "modifier_boss_centaur_bash", "bosses/boss_centaur/boss_centaur_bash", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_centaur_bash:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss_centaur_bash:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() and self:RollPRNG( self:GetSpecialValueFor("chance") ) and not self:GetParent():PassivesDisabled() then
		local ability = self:GetAbility( )
		ability:Stun( params.target , ability:GetSpecialValueFor("duration") )
		ability:StartCooldown( ability:GetCooldown(-1) )
		params.target:EmitSound( "Hero_Slardar.Bash" )
	end
end

function modifier_boss_centaur_bash:IsHidden()	
	return true
end