shinigami_grievous_strike = class({})

function shinigami_grievous_strike:GetCastRange(entity, position)
	return self:GetCaster():GetAttackRange()
end

function shinigami_grievous_strike:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_shinigami_grievous_strike", {duration = self:GetTalentSpecialValueFor("duration")})
	caster:SetForceAttackTarget(self:GetCursorTarget())
end


modifier_shinigami_grievous_strike = class({})
LinkLuaModifier("modifier_shinigami_grievous_strike", "heroes/shinigami/shinigami_grievous_strike.lua", 0)

function modifier_shinigami_grievous_strike:OnCreated()
	self.crit = self:GetAbility():GetSpecialValueFor("crit_damage")
	
end

function modifier_shinigami_grievous_strike:OnRefresh()
	self.crit = self:GetAbility():GetSpecialValueFor("crit_damage")
end

function modifier_shinigami_grievous_strike:IsHidden()
	return true
end

function modifier_shinigami_grievous_strike:DeclareFunctions()
	funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED,
			 MODIFIER_EVENT_ON_ATTACK_START,
			 MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
			}
	return funcs
end

function modifier_shinigami_grievous_strike:OnAttackStart(params)
	if params.attacker == self:GetParent() then
		local attackblur = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_attack_blur_crit.vpcf", PATTACH_ABSORIGIN, params.attacker)
		ParticleManager:SetParticleControlEnt(attackblur, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_attack1", params.attacker:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(attackblur)
	end
end

function modifier_shinigami_grievous_strike:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:GetParent():SetForceAttackTarget(nil)
		EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace.Arcana", caster)
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true )
		ParticleManager:SetParticleControl( nFXIndex, 1, params.target:GetAbsOrigin() )
		local flHPRatio = math.min( 1.0, params.target:GetMaxHealth() / 200 )
		ParticleManager:SetParticleControlForward( nFXIndex, 1, RandomFloat( 0.5, 1.0 ) * flHPRatio * ( params.attacker:GetAbsOrigin() - params.target:GetAbsOrigin() ):Normalized() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 10, params.target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_shinigami_grievous_strike_daze", {duration = self:GetAbility():GetSpecialValueFor("daze_duration")})
		self:Destroy()
	end
end

function modifier_shinigami_grievous_strike:GetModifierPreAttack_CriticalStrike()
	return self.crit
end


modifier_shinigami_grievous_strike_daze = class({})
LinkLuaModifier("modifier_shinigami_grievous_strike_daze", "heroes/shinigami/shinigami_grievous_strike.lua", 0)


function modifier_shinigami_grievous_strike_daze:OnCreated()
	if IsServer() then
		local silence = ParticleManager:CreateParticle("particles/generic_dazed.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(silence,false, false, 0, false, true)
		ParticleManager:ReleaseParticleIndex(silence)
		self:StartIntervalThink(0.1)
	end
end

function modifier_shinigami_grievous_strike_daze:OnIntervalThink()
	if math.random(2) then
		self:GetParent():Stop()
		self:GetParent():Interrupt()
	end
end


function modifier_shinigami_grievous_strike_daze:IsDaze()
	return true
end