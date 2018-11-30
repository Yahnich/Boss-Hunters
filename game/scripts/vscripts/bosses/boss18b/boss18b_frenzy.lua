boss18b_frenzy = class({})

function boss18b_frenzy:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	ParticleManager:FireWarningParticle(caster:GetAbsOrigin(), caster:GetAttackRange())
	return true
end

function boss18b_frenzy:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_boss18b_frenzy_thinker", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("Hero_Ursa.Enrage", caster)
end

modifier_boss18b_frenzy_thinker = class({})
LinkLuaModifier("modifier_boss18b_frenzy_thinker", "bosses/boss18b/boss18b_frenzy.lua", 0)

function modifier_boss18b_frenzy_thinker:OnCreated()
	self.movespeed = self:GetSpecialValueFor("movespeed_bonus")
	self.attackspeed = self:GetSpecialValueFor("attackspeed_bonus")
	if IsServer() then
		self.initHP = self:GetParent():GetHealth()
		Timers:CreateTimer(function()
			self:StartIntervalThink(self:GetParent():GetSecondsPerAttack())
		end)
	end
end

function modifier_boss18b_frenzy_thinker:OnIntervalThink()
	local caster = self:GetCaster()
	
	if caster:GetHealth() < self.initHP - caster:GetMaxHealth() * 0.1 then
		self:Destroy()
		return
	end
	
	if caster:IsStunned() or caster:IsDisarmed() or caster:IsRooted() then return end
	
	local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), caster:GetAttackRange() )
	AddFOWViewer(DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), caster:GetAttackRange(), self:GetParent():GetSecondsPerAttack() + 0.1, false)
	for _, enemy in ipairs(enemies) do
		caster:PerformGenericAttack(enemy, true)
		ParticleManager:FireParticle("particles/units/heroes/hero_riki/riki_backstab.vpcf", PATTACH_POINT_FOLLOW, enemy)
	end
end

function modifier_boss18b_frenzy_thinker:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, }
end

function modifier_boss18b_frenzy_thinker:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end

function modifier_boss18b_frenzy_thinker:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_boss18b_frenzy_thinker:GetModifierAttackSpeedBonus()
	return self.attackspeed
end

function modifier_boss18b_frenzy_thinker:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_boss18b_frenzy_thinker:GetHeroEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_hero_effect.vpcf"
end

function modifier_boss18b_frenzy_thinker:GetStatusEffectName()
	return "particles/status_fx/status_effect_bloodrage.vpcf"
end

function modifier_boss18b_frenzy_thinker:StatusEffectPriority()
	return 20
end