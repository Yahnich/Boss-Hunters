void_spirit_resonant_pulse_bh = class({})

function void_spirit_resonant_pulse_bh:GetCastRange( target, position )
	return self:GetSpecialValueFor("radius")
end

function void_spirit_resonant_pulse_bh:OnAbilityPhaseStart()
	EmitSoundOn( "Hero_VoidSpirit.Pulse.Cast", self:GetCaster() )
	return true
end

function void_spirit_resonant_pulse_bh:OnAbilityPhaseInterrupted()
	StopSoundOn( "Hero_VoidSpirit.Pulse.Cast", self:GetCaster() )
end

function void_spirit_resonant_pulse_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("buff_duration")
	local damage = self:GetSpecialValueFor("damage")
	local speed = self:GetSpecialValueFor("speed")
	local enemies = 0
	local talent = caster:HasTalent("special_bonus_unique_void_spirit_resonant_pulse_1")
	local talentDuration = caster:FindTalentValue("special_bonus_unique_void_spirit_resonant_pulse_1")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			self:DealDamage( caster, enemy, damage )
			enemies = enemies + 1
			EmitSoundOn( "Hero_VoidSpirit.Pulse.Target", caster )
			if talent then
				enemy:Disarm(self, caster, talentDuration)
				enemy:Break(self, caster, talentDuration)
				enemy:Silence(self, caster, talentDuration)
			end
		end
	end
	ParticleManager:FireParticle( "particles/units/heroes/hero_void_spirit/pulse/void_spirit_pulse.vpcf", PATTACH_POINT_FOLLOW, caster, {[1] = Vector( radius * 2, speed, speed )} )
	EmitSoundOn( "Hero_VoidSpirit.Pulse", caster )
	
	local buff = caster:AddNewModifier( caster, self, "modifier_void_spirit_resonant_pulse_shield", {duration = duration} )
	buff:SetStackCount( enemies )
	caster:AddNewModifier( caster, self, "modifier_void_spirit_resonant_pulse_shield", {duration = duration} )
end

modifier_void_spirit_resonant_pulse_talent = class({})
LinkLuaModifier( "modifier_void_spirit_resonant_pulse_talent", "heroes/hero_void_spirit/void_spirit_resonant_pulse_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_void_spirit_resonant_pulse_talent:OnCreated()
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_void_spirit_resonant_pulse_2", "damage")
	self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_void_spirit_resonant_pulse_2", "amp")
end

function modifier_void_spirit_resonant_pulse_talent:OnRefresh()
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_void_spirit_resonant_pulse_2", "damage")
	self.amp = self:GetCaster():FindTalentValue("special_bonus_unique_void_spirit_resonant_pulse_2", "amp")
end

function modifier_void_spirit_resonant_pulse_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end

function modifier_void_spirit_resonant_pulse_talent:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_void_spirit_resonant_pulse_talent:GetModifierSpellAmplify_Percentage()
	return self.amp
end

modifier_void_spirit_resonant_pulse_shield = class({})
LinkLuaModifier( "modifier_void_spirit_resonant_pulse_shield", "heroes/hero_void_spirit/void_spirit_resonant_pulse_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_void_spirit_resonant_pulse_shield:OnCreated()
	self.damageBlock = self:GetSpecialValueFor("base_absorb_amount")
	if IsServer() then
		local FX = ParticleManager:CreateParticle( "particles/units/heroes/hero_void_spirit/pulse/void_spirit_pulse_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( FX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl( FX, 1, Vector( 128, 128, 128 ) )
		ParticleManager:SetParticleControl( FX, 4, Vector( 128, 128, 128 ) )
		self:AddEffect( FX )
	end
end

function modifier_void_spirit_resonant_pulse_shield:OnRefresh()
	self.damageBlock = self:GetSpecialValueFor("base_absorb_amount") + self:GetStackCount() * self:GetSpecialValueFor("absorb_per_hero_hit")
end

function modifier_void_spirit_resonant_pulse_shield:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		EmitSoundOn( "Hero_VoidSpirit.Pulse.Destroy", caster )
		if caster:HasTalent("special_bonus_unique_void_spirit_resonant_pulse_2") then
			caster:AddNewModifier( caster, self:GetAbility(), "modifier_void_spirit_resonant_pulse_talent", {duration = caster:FindTalentValue("special_bonus_unique_void_spirit_resonant_pulse_2")} )
		end
	end
end

function modifier_void_spirit_resonant_pulse_shield:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK}
end

function modifier_void_spirit_resonant_pulse_shield:GetModifierPhysical_ConstantBlock(params)
	local block = self.damageBlock
	self.damageBlock = self.damageBlock - params.damage
	if self.damageBlock <= 0 then
		self:Destroy()
		return block
	end
	return params.damage + 1
end