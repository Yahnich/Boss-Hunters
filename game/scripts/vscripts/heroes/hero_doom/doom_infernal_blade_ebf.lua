doom_infernal_blade_ebf = class({})

function doom_infernal_blade_ebf:GetIntrinsicModifierName()
	return "modifier_doom_infernal_blade_ebf_autocast"
end

function doom_infernal_blade_ebf:IsStealable()
	return false
end

function doom_infernal_blade_ebf:OnAbilityPhasteStart()
	self.autocast = true
	self:StartInfernalBlade()
	return true
end

function doom_infernal_blade_ebf:OnSpellStart()
	local target = self:GetCursorTarget()
	self.autocast = false
	self:InfernalBlade(target)
end

function doom_infernal_blade_ebf:IsStealable()
	return true
end

function doom_infernal_blade_ebf:GetCastRange(location, target)
	return self:GetCaster():GetAttackRange()
end

function doom_infernal_blade_ebf:GetAOERadius()
	return self:GetCaster():FindTalentValue("special_bonus_unique_doom_infernal_blade_ebf_1")	
end

function doom_infernal_blade_ebf:StartInfernalBlade()
	ParticleManager:FireParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	EmitSoundOn("Hero_DoomBringer.InfernalBlade.PreAttack", self:GetCaster())
end

function doom_infernal_blade_ebf:InfernalBlade(target)
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_doom_infernal_blade_ebf_1") then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_doom_infernal_blade_ebf_1", "radius") ) ) do
			if not enemy:TriggerSpellAbsorb(self) then
				enemy:AddNewModifier(caster, self, "modifier_doom_infernal_blade_ebf_debuff", {duration = self:GetTalentSpecialValueFor("burn_duration")})
				self:Stun(enemy, self:GetTalentSpecialValueFor("ministun_duration"), false)
				ParticleManager:FireParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_POINT_FOLLOW, enemy)
			end
		end
	elseif not target:TriggerSpellAbsorb(self) then
		target:AddNewModifier(caster, self, "modifier_doom_infernal_blade_ebf_debuff", {duration = self:GetTalentSpecialValueFor("burn_duration")})
		self:Stun(target, self:GetTalentSpecialValueFor("ministun_duration"), false)
		ParticleManager:FireParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_POINT_FOLLOW, enemy)
	end
	EmitSoundOn("Hero_DoomBringer.InfernalBlade.Target", target)
end

modifier_doom_infernal_blade_ebf_autocast = class({})
LinkLuaModifier("modifier_doom_infernal_blade_ebf_autocast", "heroes/hero_doom/doom_infernal_blade_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_doom_infernal_blade_ebf_autocast:IsHidden()
	return true
end

function modifier_doom_infernal_blade_ebf_autocast:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

if IsServer() then
	function modifier_doom_infernal_blade_ebf_autocast:OnAttackStart(params)
		if params.attacker == self:GetParent() and params.target and self:GetAbility():GetAutoCastState() and self:GetAbility():IsCooldownReady() then
			self:GetAbility():StartInfernalBlade()
		end
	end
	function modifier_doom_infernal_blade_ebf_autocast:OnAttack(params)
		if params.attacker == self:GetParent() and params.target and self:GetAbility():GetAutoCastState() and self:GetAbility():IsCooldownReady() then
			self:GetAbility():CastSpell(params.target)
		end
	end
end
function modifier_doom_infernal_blade_ebf_autocast:GetActivityTranslationModifiers(params)
	if IsServer() and (self:GetAbility():IsCooldownReady() and self:GetAbility():GetAutoCastState()) or self:GetAbility().autocast then
		return "infernal_blade"
	end
end

modifier_doom_infernal_blade_ebf_debuff = class({})
LinkLuaModifier("modifier_doom_infernal_blade_ebf_debuff", "heroes/hero_doom/doom_infernal_blade_ebf", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_doom_infernal_blade_ebf_debuff:OnCreated()
		self.damage = self:GetParent():GetMaxHealth() * self:GetTalentSpecialValueFor("burn_damage_pct") / 100
		self.baseDamage = self:GetTalentSpecialValueFor("burn_damage")
		self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_doom_infernal_blade_ebf_2")
		self:StartIntervalThink(1)
	end
	
	function modifier_doom_infernal_blade_ebf_debuff:OnIntervalThink()
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.baseDamage)
		SendOverheadEventMessage(self:GetCaster():GetPlayerOwner(), OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), self.damage + self.baseDamage,self:GetParent():GetPlayerOwner())
	end
	
	function modifier_doom_infernal_blade_ebf_debuff:OnDestroy()
		if self:GetParent():IsMinion() and self.talent2 then
			self:GetParent():AttemptKill( self:GetAbility(), self:GetCaster() )
		end
	end
end

function modifier_doom_infernal_blade_ebf_debuff:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end