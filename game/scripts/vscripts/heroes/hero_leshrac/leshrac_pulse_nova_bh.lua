leshrac_pulse_nova_bh = class({})

function leshrac_pulse_nova_bh:IsStealable()
	return true
end

function leshrac_pulse_nova_bh:IsHiddenWhenStolen()
	return false
end

function leshrac_pulse_nova_bh:GetManaCost( iLvl )
	return self.BaseClass.GetManaCost( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_leshrac_pulse_nova_1")
end

function leshrac_pulse_nova_bh:OnUpgrade()
	self:OnToggle()
	self:OnToggle()
end

function leshrac_pulse_nova_bh:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier( caster, self, "modifier_leshrac_pulse_nova_bh", {})
	else
		caster:RemoveModifierByName( "modifier_leshrac_pulse_nova_bh" )
	end
end

modifier_leshrac_pulse_nova_bh = class(toggleModifierBaseClass)
LinkLuaModifier( "modifier_leshrac_pulse_nova_bh", "heroes/hero_leshrac/leshrac_pulse_nova_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_leshrac_pulse_nova_bh:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.damage = self:GetSpecialValueFor("damage")
	
	if IsServer() then
		self:GetCaster():EmitSound("Hero_Leshrac.Pulse_Nova")
		self:StartIntervalThink(1)
	end
end

function modifier_leshrac_pulse_nova_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
		ability:DealDamage( caster, enemy, self.damage )
		
		enemy:EmitSound("Hero_Leshrac.Pulse_Nova_Strike")
		ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf", PATTACH_POINT_FOLLOW, enemy)
	end
	caster:SpendMana( self:GetSpecialValueFor("mana_cost_per_second"), ability )
	if caster:GetMana() == 0 then
		self:GetAbility():ToggleAbility()
	end
end

function modifier_leshrac_pulse_nova_bh:OnDestroy()
	if IsServer() then
		self:GetCaster():StopSound("Hero_Leshrac.Pulse_Nova")
	end
end

function modifier_leshrac_pulse_nova_bh:GetEffectName()
	return "particles/units/heroes/hero_leshrac/leshrac_pulse_nova_ambient.vpcf"
end