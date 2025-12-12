doom_infernal_blade_ebf = class({})

function doom_infernal_blade_ebf:GetIntrinsicModifierName()
	return "modifier_doom_infernal_blade_ebf_autocast"
end

function doom_infernal_blade_ebf:IsStealable()
	return false
end

function doom_infernal_blade_ebf:GetCastRange( position, target )
	return self:GetCaster():GetAttackRange()
end

function doom_infernal_blade_ebf:OnSpellStart()
	local target = self:GetCursorTarget()
	self.autocast = true
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
	self:RefundManaCost()
	self:EndCooldown()
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
	-- ParticleManager:FireParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	EmitSoundOn("Hero_DoomBringer.InfernalBlade.PreAttack", self:GetCaster())
end

function doom_infernal_blade_ebf:InfernalBlade(target)
	local caster = self:GetCaster()
	if caster:HasScepter() then
		local startPos = target:GetAbsOrigin()
		local direction = CalculateDirection( target, caster )
		local length = self:GetSpecialValueFor("scepter_length")
		local width = self:GetSpecialValueFor("scepter_width")
		for _, enemy in ipairs( caster:FindEnemyUnitsInLine( startPos, startPos + direction * length, width ) ) do
			if not enemy:TriggerSpellAbsorb(self) then
				enemy:AddNewModifier(caster, self, "modifier_doom_infernal_blade_ebf_debuff", {duration = self:GetSpecialValueFor("burn_duration")})
				self:Stun(enemy, self:GetSpecialValueFor("ministun_duration"), false)
				ParticleManager:FireParticle("particles/units/heroes/hero_doom_bringer/doom_infernal_blade_impact.vpcf", PATTACH_POINT_FOLLOW, enemy)
			end
		end
		for i = 1, math.floor( length / width + 0.5 ) do
			ParticleManager:FireParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", PATTACH_ABSORIGIN, caster, {[0] = startPos + direction * (i-1) * width } )
		end
	elseif not target:TriggerSpellAbsorb(self) then
		target:AddNewModifier(caster, self, "modifier_doom_infernal_blade_ebf_debuff", {duration = self:GetSpecialValueFor("burn_duration")})
		self:Stun(target, self:GetSpecialValueFor("ministun_duration"), false)
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
	return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

if IsServer() then
	function modifier_doom_infernal_blade_ebf_autocast:OnAttackStart(params)
		if params.attacker == self:GetParent() and params.target and (( self:GetAbility():GetAutoCastState() and self:GetAbility():IsCooldownReady() ) or self:GetAbility().autocast) then
			self:GetAbility():StartInfernalBlade()
		end
	end
	function modifier_doom_infernal_blade_ebf_autocast:OnAttack(params)
		if params.attacker == self:GetParent() and params.target and (( self:GetAbility():GetAutoCastState() and self:GetAbility():IsCooldownReady() ) or self:GetAbility().autocast) then
			self:GetAbility():UseResources( true, false, true )
			self:GetAbility():InfernalBlade(params.target)
			self:GetAbility().autocast = false
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

function modifier_doom_infernal_blade_ebf_debuff:OnCreated()
	self.damage = self:GetParent():GetMaxHealth() * self:GetSpecialValueFor("burn_damage_pct") / 100
	self.baseDamage = self:GetSpecialValueFor("burn_damage")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_doom_infernal_blade_ebf_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_doom_infernal_blade_ebf_2")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_doom_infernal_blade_ebf_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage + self.baseDamage * self:GetCaster():GetSpellAmplification( false ), {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

function modifier_doom_infernal_blade_ebf_debuff:CheckState()
	if self.talent1 then
		return {[MODIFIER_STATE_PASSIVES_DISABLED] = true}
	end
end

function modifier_doom_infernal_blade_ebf_debuff:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end