dazzle_shallow_grave_bh = class({})

function dazzle_shallow_grave_bh:GetCastRange( target, position )
	return self:GetTalentSpecialValueFor("radius")
end

function dazzle_shallow_grave_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("duration")
	
	caster:EmitSound("Hero_Dazzle.Shallow_Grave")
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		ally:AddNewModifier( caster, self, "modifier_dazzle_shallow_grave_bh", {duration = duration})
	end
end

modifier_dazzle_shallow_grave_bh = class({})
LinkLuaModifier("modifier_dazzle_shallow_grave_bh", "heroes/hero_dazzle/dazzle_shallow_grave_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_dazzle_shallow_grave_bh:OnCreated()
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_shallow_grave_1")
	if self.talent1 then
		self.respawnTime = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_1")
		self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_1", "radius") / 100
		self.damagePct = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_1", "dmg") / 100
	end
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_shallow_grave_2")
	if self.talent2 then
		self.red = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_2", "red")
		self.hAmp = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_2", "amp")
	end
end

function modifier_dazzle_shallow_grave_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_dazzle_shallow_grave_bh:OnDeath(params)
	if self.talent1 and params.unit == self:GetParent() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		
		local damage = parent:GetMaxHealth() * self.damagePct
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
			ability:DealDamage( caster, enemy, damage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		end
		
		Timers:CreateTimer(self.respawnTime, function()
			if not parent:IsAlive() then
				local origin = parent:GetOrigin()
				parent:RespawnHero(false, false)
				parent:SetOrigin(origin)
			end
		end)
	end
end

function modifier_dazzle_shallow_grave_bh:GetMinHealth()
	if not self.talent1 and not self.talent2 then
		return 1
	end
end

function modifier_dazzle_shallow_grave_bh:GetModifierHealAmplify_Percentage()
	return self.hAmp
end

function modifier_dazzle_shallow_grave_bh:GetModifierIncomingDamage_Percentage()
	return self.red
end

function modifier_dazzle_shallow_grave_bh:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_shallow_grave.vpcf"
end