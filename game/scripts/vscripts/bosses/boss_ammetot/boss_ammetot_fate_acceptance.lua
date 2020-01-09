boss_ammetot_fate_acceptance = class({})

function boss_ammetot_fate_acceptance:GetIntrinsicModifierName()
	return "modifier_boss_ammetot_fate_acceptance"
end

modifier_boss_ammetot_fate_acceptance = class({})
LinkLuaModifier( "modifier_boss_ammetot_fate_acceptance", "bosses/boss_ammetot/boss_ammetot_fate_acceptance", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ammetot_fate_acceptance:OnCreated()
	self.timer = self:GetSpecialValueFor("death_timer")
	self:SetDuration( self.timer+0.1, true )
	self:StartIntervalThink( self.timer )
end

function modifier_boss_ammetot_fate_acceptance:OnRefresh()
	self:OnCreated()
end

function modifier_boss_ammetot_fate_acceptance:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if caster:IsNull() or not caster:IsAlive() then return end
		EmitSoundOn( "Hero_Necrolyte.ReapersScythe.Target", caster )
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
			enemy:SetHealth( 1 )
			if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then enemy:AttemptKill( ability , caster ) end
		end
	end
end

function modifier_boss_ammetot_fate_acceptance:IsPurgable()
	return false
end