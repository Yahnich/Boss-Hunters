centaur_great_edge = class({})

function centaur_great_edge:IsStealable()
	return true
end

function centaur_great_edge:IsHiddenWhenStolen()
	return false
end

function centaur_great_edge:GetIntrinsicModifierName()
	return "modifier_centaur_great_edge_autocast"
end

function centaur_great_edge:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown(self, iLevel) + self:GetCaster():FindTalentValue("special_bonus_unique_centaur_great_edge_1", "cd")
end

function centaur_great_edge:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local edgeDamage = self:GetTalentSpecialValueFor( "edge_damage" )
	local bonusDamage = caster:GetStrength() * self:GetTalentSpecialValueFor( "edge_str_damage" ) / 100
	local selfDamage = self:GetTalentSpecialValueFor("self_damage") / 100
	local radius = self:GetTalentSpecialValueFor("radius")
	
	EmitSoundOn( "Hero_Centaur.DoubleEdge", caster )
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()) -- Origin
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin()) -- Destination
	ParticleManager:SetParticleControl(particle, 5, target:GetAbsOrigin()) -- Hit Glow
	
	self:DealDamage( caster, caster, (edgeDamage + bonusDamage) * selfDamage, {damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL})
	local units = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius)
	for _, enemy in ipairs(units) do
		if not enemy:TriggerSpellAbsorb( self ) then
			self:DealDamage( caster, enemy, edgeDamage + bonusDamage )
			-- if caster:HasTalent("special_bonus_unique_centaur_great_edge_2") then self:Stun(enemy, caster:FindTalentValue("special_bonus_unique_centaur_great_edge_2"), false) end
			if caster:HasTalent("special_bonus_unique_centaur_great_edge_3") then
				enemy:AddNewModifier( caster, self, "modifier_centaur_great_edge_talent", {duration = caster:FindTalentValue("special_bonus_unique_centaur_great_edge_3")} )
			end
		end
	end
end

modifier_centaur_great_edge_autocast = class({})
LinkLuaModifier( "modifier_centaur_great_edge_autocast", "heroes/hero_centaur/centaur_great_edge", LUA_MODIFIER_MOTION_NONE )

function modifier_centaur_great_edge_autocast:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_centaur_great_edge_autocast:OnAttackLanded( params )
	if params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() and self:GetAbility():GetAutoCastState() then
		self:GetAbility():CastSpell( params.target )
	end
end

function modifier_centaur_great_edge_autocast:IsHidden()
	return true
end

modifier_centaur_great_edge_talent = class({})
LinkLuaModifier( "modifier_centaur_great_edge_talent", "heroes/hero_centaur/centaur_great_edge", LUA_MODIFIER_MOTION_NONE )

function modifier_centaur_great_edge_talent:OnCreated()
	self:OnRefresh()
end

function modifier_centaur_great_edge_talent:OnRefresh()
	self.damage = self:GetCaster():GetStrength()
end

function modifier_centaur_great_edge_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_centaur_great_edge_talent:GetModifierPreAttack_BonusDamage()
	return -self.damage
end