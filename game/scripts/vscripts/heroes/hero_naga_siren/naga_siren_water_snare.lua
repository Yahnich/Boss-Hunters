naga_siren_water_snare = class({})

function naga_siren_water_snare:GetAOERadius()
	return self:GetCaster():FindTalentValue("special_bonus_unique_naga_siren_water_snare_2")
end

function naga_siren_water_snare:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	caster:EmitSound("Hero_NagaSiren.Ensnare.Cast")
	self:FireTrackingProjectile( "particles/units/heroes/hero_siren/siren_net_projectile.vpcf", target, self:GetTalentSpecialValueFor("net_speed") )
end

function naga_siren_water_snare:OnProjectileHit(target, position)
	if target and not target:IsMagicImmune() and not target:TriggerSpellAbsorb(self) then
		local duration = self:GetTalentSpecialValueFor("duration")
		local damage = self:GetTalentSpecialValueFor("base_damage")
		local caster = self:GetCaster()
		
		target:EmitSound("Hero_NagaSiren.Ensnare.Target")
		if caster:HasTalent("special_bonus_unique_naga_siren_water_snare_2") then
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_naga_siren_water_snare_2") ) ) do
				enemy:Interrupt()
				self:DealDamage( caster, enemy, damage )
				enemy:AddNewModifier(caster, self, "modifier_naga_siren_water_snare", {duration = duration})
			end
		else
			target:Interrupt()
			self:DealDamage( caster, target, damage )
			target:AddNewModifier(caster, self, "modifier_naga_siren_water_snare", {duration = duration})
		end
		if caster:HasTalent("special_bonus_unique_naga_siren_water_snare_1") then
			caster:AddNewModifier(caster, self, "modifier_naga_siren_water_snare_talent", {duration = duration + 0.1})
		end
	end
end

modifier_naga_siren_water_snare = class({})
LinkLuaModifier("modifier_naga_siren_water_snare", "heroes/hero_naga_siren/naga_siren_water_snare", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_naga_siren_water_snare:OnCreated()
		self.dmg = self:GetTalentSpecialValueFor("agility_damage") / 100
		self:StartIntervalThink(1)
	end
	
	function modifier_naga_siren_water_snare:OnIntervalThink()
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetCaster():GetAgility() * self.dmg )
	end
end

function modifier_naga_siren_water_snare:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_naga_siren_water_snare:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_naga_siren_water_snare:GetModifierEvasion_Constant()
	return -100
end

function modifier_naga_siren_water_snare:GetEffectName()
	return "particles/units/heroes/hero_siren/siren_net.vpcf"
end

modifier_naga_siren_water_snare_talent = class({})
LinkLuaModifier("modifier_naga_siren_water_snare_talent", "heroes/hero_naga_siren/naga_siren_water_snare", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_water_snare_talent:OnCreated()
	self.attackspeed = self:GetCaster():FindTalentValue("special_bonus_unique_naga_siren_water_snare_1", "value")
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_naga_siren_water_snare_1", "value2")
	if IsServer() then
		self:SetStackCount(1)
		self:StartIntervalThink(0.1)
	end
end

function modifier_naga_siren_water_snare_talent:OnRefresh()
	self.attackspeed = self:GetCaster():FindTalentValue("special_bonus_unique_naga_siren_water_snare_1", "value")
	self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_naga_siren_water_snare_1", "value2")
end

function modifier_naga_siren_water_snare_talent:OnIntervalThink()
	if self:GetCaster():GetAttackTarget() and self:GetCaster():GetAttackTarget():HasModifier("modifier_naga_siren_water_snare") then
		self:SetStackCount(0)
	else
		self:SetStackCount(1)
	end
end

function modifier_naga_siren_water_snare_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_naga_siren_water_snare_talent:GetModifierAttackSpeedBonus_Constant()
	if self:GetStackCount() == 0 then
		return self.attackspeed
	end
end

function modifier_naga_siren_water_snare_talent:GetModifierBaseDamageOutgoing_Percentage()
	if self:GetStackCount() == 0 then
		return self.damage
	end
end

function modifier_naga_siren_water_snare_talent:IsHidden()
	return self:GetStackCount() ~= 0
end