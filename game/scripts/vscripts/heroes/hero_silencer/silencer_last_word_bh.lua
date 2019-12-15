silencer_last_word_bh = class({})

function silencer_last_word_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local duration = self:GetTalentSpecialValueFor("debuff_duration")
	if not target:TriggerSpellAbsorb( self ) then
		target:RemoveModifierByName("modifier_silencer_last_word_bh")
		target:AddNewModifier(caster, self, "modifier_silencer_last_word_bh", {duration = duration})
		if caster:HasTalent("special_bonus_unique_silencer_last_word_2") then
			target:AddNewModifier(caster, self, "modifier_silencer_last_word_bh_talent", {duration = duration + self:GetTalentSpecialValueFor("duration")})
		end
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_silencer/silencer_last_word_status_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlForward(fx, 0, caster:GetForwardVector() )
		ParticleManager:SetParticleControlEnt(fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlForward(fx, 1, caster:GetForwardVector() )
		ParticleManager:SetParticleControlEnt(fx, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlForward(fx, 2, caster:GetForwardVector() )
		target:EmitSound("Hero_Silencer.LastWord.Target")
	end
	caster:EmitSound("Hero_Silencer.LastWord.Cast")
end

modifier_silencer_last_word_bh = class({})
LinkLuaModifier( "modifier_silencer_last_word_bh", "heroes/hero_silencer/silencer_last_word_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_silencer_last_word_bh:OnCreated()
		self.silenceDuration = self:GetTalentSpecialValueFor("duration")
		self.damage = self:GetTalentSpecialValueFor("damage")
		self:GetAbility():StartDelayedCooldown()
	end

	function modifier_silencer_last_word_bh:OnDestroy()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		parent:EmitSound("Hero_Silencer.LastWord.Damage")
		ParticleManager:FireParticle("particles/units/heroes/hero_silencer/silencer_last_word_dmg.vpcf", PATTACH_POINT_FOLLOW, parent)
		ability:DealDamage( caster, parent, self.damage )
		self:GetAbility():EndDelayedCooldown()
		parent:Silence(ability, caster, self.silenceDuration, true)
		if caster:HasTalent("special_bonus_unique_silencer_last_word_1") then
			parent:Paralyze(ability, caster, self.silenceDuration)
		end
	end
end

function modifier_silencer_last_word_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_silencer_last_word_bh:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		self:Destroy()
	end
end

function modifier_silencer_last_word_bh:GetEffectName()
	return "particles/units/heroes/hero_silencer/silencer_last_word_status.vpcf"
end

modifier_silencer_last_word_bh_talent = class({})
LinkLuaModifier( "modifier_silencer_last_word_bh_talent", "heroes/hero_silencer/silencer_last_word_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_silencer_last_word_bh_talent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START}
end

function modifier_silencer_last_word_bh_talent:OnAttackStart(params)
	if params.attacker:IsSameTeam( self:GetCaster() ) then
		params.attacker:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_silencer_last_word_bh_talent_buff", { duration = params.attacker:GetSecondsPerAttack() + 0.1 })
	end
end

function modifier_silencer_last_word_bh_talent:IsHidden()
	return true
end

modifier_silencer_last_word_bh_talent_buff = class({})
LinkLuaModifier( "modifier_silencer_last_word_bh_talent_buff", "heroes/hero_silencer/silencer_last_word_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_silencer_last_word_bh_talent_buff:OnCreated()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_silencer_last_word_2")
end

function modifier_silencer_last_word_bh_talent_buff:DeclareFunctions()
	return {}
end

function modifier_silencer_last_word_bh_talent_buff:GetModifierAttackSpeedBonus()
	return self.as
end