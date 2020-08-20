boss_genesis_pacifism = class({})

function boss_genesis_pacifism:GetIntrinsicModifierName()
	return "modifier_boss_genesis_pacifism"
end

function boss_genesis_pacifism:ShouldUseResources()
	return true
end

modifier_boss_genesis_pacifism = class({})
LinkLuaModifier( "modifier_boss_genesis_pacifism", "bosses/boss_genesis/boss_genesis_pacifism", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_genesis_pacifism:OnCreated()
	if IsServer() then self:StartIntervalThink(0.5) end
end
function modifier_boss_genesis_pacifism:OnIntervalThink()
	if self:GetAbility():IsCooldownReady() then
		self:SetStackCount(0)
	else
		self:SetStackCount(1)
	end
end

function modifier_boss_genesis_pacifism:DeclareFunctions()
	return {MODIFIER_PROPERTY_ABSORB_SPELL,
			MODIFIER_EVENT_ON_ATTACK,
			}
end

function modifier_boss_genesis_pacifism:OnAttack(params)
	local ability = self:GetAbility()
	if params.target == self:GetParent() and ability:IsCooldownReady() and not self:GetParent():PassivesDisabled() then
		local duration = self:GetSpecialValueFor("duration")
		params.attacker:Disarm( params.target, ability, duration)
		params.attacker:Silence( params.target, ability, duration)
		ability:SetCooldown( self:GetAbility():GetCooldown(-1) )
		params.target:Dispel( params.target, true )
		ParticleManager:FireParticle( "particles/fire_ball_explosion.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
	end
end

function modifier_boss_genesis_pacifism:GetAbsorbSpell(params)
	if params.ability and params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() and ability:IsCooldownReady() and not self:GetParent():PassivesDisabled() then
		local duration = self:GetSpecialValueFor("duration")
		params.ability:GetCaster():Disarm( self:GetParent(), ability, duration)
		params.ability:GetCaster():Silence( self:GetParent(), ability, duration)
		ability:SetCooldown( self:GetAbility():GetCooldown(-1) )
		self:GetParent():Dispel( self:GetParent(), true )
		ParticleManager:FireParticle( "particles/fire_ball_explosion.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		return 1
	end
end

function modifier_boss_genesis_pacifism:IsHidden()
	return self:GetStackCount() == 1
end