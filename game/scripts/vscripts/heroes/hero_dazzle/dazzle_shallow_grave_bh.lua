dazzle_shallow_grave_bh = class({})

function dazzle_shallow_grave_bh:GetManaCost( iLvl ) 
	return self.BaseClass.GetManaCost( self, iLvl ) + self:GetCaster():GetModifierStackCount( "modifier_dazzle_weave_bh_handler", self:GetCaster() )
end

function dazzle_shallow_grave_bh:GetCastRange( target, position )
	return self:GetTalentSpecialValueFor("radius")
end

function dazzle_shallow_grave_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("duration")
	local scepterDuration = duration + self:GetTalentSpecialValueFor("scepter_duration_extension")
	
	caster:EmitSound("Hero_Dazzle.Shallow_Grave")
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		local allyDur = duration
		if caster:HasScepter() and ally:HasModifier("modifier_dazzle_weave_bh") then
			allyDur = scepterDuration
		end
		ally:AddNewModifier( caster, self, "modifier_dazzle_shallow_grave_bh", {duration = duration})
	end
	if caster:HasScepter() then
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), -1 ) ) do
			if ally:HasModifier("modifier_dazzle_weave_bh") then
				ally:AddNewModifier( caster, self, "modifier_dazzle_shallow_grave_bh", {duration = scepterDuration})
			end
		end
	end
end

modifier_dazzle_shallow_grave_bh = class({})
LinkLuaModifier("modifier_dazzle_shallow_grave_bh", "heroes/hero_dazzle/dazzle_shallow_grave_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_dazzle_shallow_grave_bh:OnCreated()
	self:OnRefresh()
end

function modifier_dazzle_shallow_grave_bh:OnRefresh()
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_shallow_grave_1")
	self.talent1Dur = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_1", "duration")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_dazzle_shallow_grave_2")
	self.talent2Dur = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_2", "duration")
	self.talent2HP = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_2", "threshold_hp")
end

function modifier_dazzle_shallow_grave_bh:OnDestroy()
	if IsServer() then
		if self.talent1 then 
			self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_dazzle_shallow_grave_talent1", {duration = self.talent1Dur} )
		end
		if self.talent2 and self.talent2HP >= self:GetParent():GetHealthPercent() then 
			self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_dazzle_shallow_grave_talent2", {duration = self.talent2Dur} )
		end
	end

end

function modifier_dazzle_shallow_grave_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_dazzle_shallow_grave_bh:GetMinHealth()
	return 1
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

modifier_dazzle_shallow_grave_talent1 = class({})
LinkLuaModifier("modifier_dazzle_shallow_grave_talent1", "heroes/hero_dazzle/dazzle_shallow_grave_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_dazzle_shallow_grave_talent1:OnCreated()
	self.respawnTime = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_1")
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_1", "radius") / 100
	self.damagePct = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_1", "dmg") / 100
end

function modifier_dazzle_shallow_grave_talent1:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH }
end

function modifier_dazzle_shallow_grave_talent1:OnDeath(params)
	if params.unit == self:GetParent() then
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
modifier_dazzle_shallow_grave_talent2 = class({})
LinkLuaModifier("modifier_dazzle_shallow_grave_talent2", "heroes/hero_dazzle/dazzle_shallow_grave_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_dazzle_shallow_grave_talent2:OnCreated()
	self.damage_reduction = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_2")
	self.health_regen = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_2", "regen")
	self.dispel_hp = self:GetCaster():FindTalentValue("special_bonus_unique_dazzle_shallow_grave_2", "dispel_hp")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_dazzle_shallow_grave_talent2:OnRefresh()
end

function modifier_dazzle_shallow_grave_talent2:OnIntervalThink()
	if self:GetParent():GetHealthPercent() >= self.dispel_hp then
		self:Destroy()
	end
end

function modifier_dazzle_shallow_grave_talent2:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE }
end

function modifier_dazzle_shallow_grave_talent2:GetModifierIncomingDamage_Percentage()
	return self.damage_reduction
end

function modifier_dazzle_shallow_grave_talent2:GetModifierHealthRegenPercentage()
	return self.health_regen
end