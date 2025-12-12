abyssal_underlord_abyssal_expulsion = class({})

function abyssal_underlord_abyssal_expulsion:IsStealable()
	return true
end

function abyssal_underlord_abyssal_expulsion:IsHiddenWhenStolen()
	return false
end

function abyssal_underlord_abyssal_expulsion:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = self:GetSpecialValueFor("search_radius")
	local duration = self:GetSpecialValueFor("duration")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			enemy:AddNewModifier( caster, self, "modifier_abyssal_underlord_abyssal_expulsion", {duration = duration} )
			enemy:EmitSound("Hero_AbyssalUnderlord.DarkRift.Aftershock")
		end
	end
	
	if caster:HasTalent("special_bonus_unique_abyssal_underlord_abyssal_expulsion_2") then
		caster:AddNewModifier( caster, self, "modifier_abyssal_underlord_abyssal_expulsion_talent", {duration = duration} )
	end
	
	ParticleManager:FireParticle("particles/underlord_expulsion_aura.vpcf", PATTACH_ABSORIGIN, caster, {[1] = Vector(radius,1,1)})
	caster:EmitSound("Hero_AbyssalUnderlord.DarkRift.Cast")
end

modifier_abyssal_underlord_abyssal_expulsion = class({})
LinkLuaModifier( "modifier_abyssal_underlord_abyssal_expulsion", "heroes/hero_abyssal_underlord/abyssal_underlord_abyssal_expulsion", LUA_MODIFIER_MOTION_NONE )

function modifier_abyssal_underlord_abyssal_expulsion:OnCreated(kv)
	self.dps = self:GetSpecialValueFor("damage_per_sec") * self:GetSpecialValueFor("explosion_interval")
	self.hps = self:GetSpecialValueFor("heal_per_sec") * self:GetSpecialValueFor("explosion_interval")
	self.hRadius = self:GetSpecialValueFor("heal_radius")
	self.dDamage = self:GetSpecialValueFor("death_damage")
	self.dRadius = self:GetSpecialValueFor("death_radius")
	self.duration = self:GetSpecialValueFor("duration")
	self.tick = (self:GetDuration() / self.duration ) * self:GetSpecialValueFor("explosion_interval")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_abyssal_underlord_abyssal_expulsion_1")
	if IsServer() then
		self:StartIntervalThink( self.tick )
	end
end

function modifier_abyssal_underlord_abyssal_expulsion:OnRefresh()
	self.dps = self:GetSpecialValueFor("damage_per_sec") * self:GetSpecialValueFor("explosion_interval")
	self.hps = self:GetSpecialValueFor("heal_per_sec") * self:GetSpecialValueFor("explosion_interval")
	self.hRadius = self:GetSpecialValueFor("heal_radius")
	self.dDamage = self:GetSpecialValueFor("death_damage")
	self.dRadius = self:GetSpecialValueFor("death_radius")
	self.duration = self:GetSpecialValueFor("duration")
	self.tick = (self:GetDuration() / self.duration ) * self:GetSpecialValueFor("explosion_interval")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_abyssal_underlord_abyssal_expulsion_1")
	if IsServer() then
		self:StartIntervalThink( self.tick )
	end
end

function modifier_abyssal_underlord_abyssal_expulsion:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	ability:DealDamage( caster, parent, self.dps )
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.hRadius ) ) do
		ally:HealEvent( self.hps, ability, caster )
	end
end

function modifier_abyssal_underlord_abyssal_expulsion:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_abyssal_underlord_abyssal_expulsion:OnDeath(params)
	if params.unit == self:GetParent() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.dRadius ) ) do
			if not enemy:TriggerSpellAbsorb(ability) then
				ability:DealDamage( caster, enemy, self.dDamage )
				enemy:AddNewModifier( caster, ability, "modifier_abyssal_underlord_abyssal_expulsion", {duration = self.duration} )
				enemy:EmitSound("Hero_AbyssalUnderlord.DarkRift.Aftershock")
			end
		end
		
		if self.talent1 then
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.dRadius ) ) do
				ally:HealEvent( self.dDamage, ability, caster )
			end
		end
		
		params.unit:EmitSound("Hero_AbyssalUnderlord.DarkRift.Complete")
		ParticleManager:FireParticle("particles/underlord_expulsion_explosion.vpcf", PATTACH_POINT_FOLLOW, params.unit, {[1] = Vector(self.dRadius,1,1)})
	end
end

function modifier_abyssal_underlord_abyssal_expulsion:GetEffectName()
	return "particles/underlord_expulsion_debuff.vpcf"
end

modifier_abyssal_underlord_abyssal_expulsion_talent = class({})
LinkLuaModifier( "modifier_abyssal_underlord_abyssal_expulsion_talent", "heroes/hero_abyssal_underlord/abyssal_underlord_abyssal_expulsion", LUA_MODIFIER_MOTION_NONE )

function modifier_abyssal_underlord_abyssal_expulsion_talent:OnCreated(kv)
	self.dps = self:GetCaster():FindTalentValue("special_bonus_unique_abyssal_underlord_abyssal_expulsion_2") * self:GetSpecialValueFor("explosion_interval") / 100
	self.radius = self:GetSpecialValueFor("search_radius")
	self.duration = self:GetSpecialValueFor("duration")
	self.tick = (self:GetDuration() / self.duration ) * self:GetSpecialValueFor("explosion_interval")
	if IsServer() then
		self:StartIntervalThink( self.tick )
	end
end

function modifier_abyssal_underlord_abyssal_expulsion_talent:OnRefresh()
	self.dps = self:GetCaster():FindTalentValue("special_bonus_unique_abyssal_underlord_abyssal_expulsion_2") * self:GetSpecialValueFor("explosion_interval")
	self.radius = self:GetSpecialValueFor("search_radius")
	self.duration = self:GetSpecialValueFor("duration")
	self.tick = (self:GetDuration() / self.duration ) * self:GetSpecialValueFor("explosion_interval")
	if IsServer() then
		self:StartIntervalThink( self.tick )
	end
end

function modifier_abyssal_underlord_abyssal_expulsion_talent:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	local damage = parent:GetHealth() * self.dps
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
		ability:DealDamage( caster, enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
end

function modifier_abyssal_underlord_abyssal_expulsion_talent:GetEffectName()
	return "particles/underlord_expulsion_debuff.vpcf"
end