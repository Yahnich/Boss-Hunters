witch_doctor_maledict_bh = class({})

function witch_doctor_maledict_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local position = self:GetCursorPosition()
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("duration_tooltip")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		enemy:AddNewModifier(caster, self, "modifier_witch_doctor_maledict_bh", {duration = duration})
	end
end

modifier_witch_doctor_maledict_bh = class({})
LinkLuaModifier("modifier_witch_doctor_maledict_bh", "heroes/hero_witch_doctor/witch_doctor_maledict_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_witch_doctor_maledict_bh:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("base_damage")
	self.burst = self:GetTalentSpecialValueFor("bonus_damage")
	if IsServer() then
		self.burstTimer = self:GetTalentSpecialValueFor("burst_interval")
		self.currentTime = GameRules():GetGameTime()
		self.hp = self:GetHealth()
		self:StartIntervalThink( 1 )
	end
end

function modifier_witch_doctor_maledict_bh:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("base_damage")
	self.burst = self:GetTalentSpecialValueFor("bonus_damage") / 10
end

function modifier_witch_doctor_maledict_bh:OnIntervalThink()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	
	if self.currentTime + self.burstTimer <= GameRules:GetGameTime() then
		self.currentTime = GameRules:GetGameTime()
		ability:DealDamage( caster, parent, math.max( 0, self.hp - parent:GetHealth() ) * self.burst, {damage_flags = DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
	ability:DealDamage( caster, parent, self.damage )
end

function modifier_witch_doctor_maledict_bh:OnDestroy()
	ability:DealDamage( caster, parent, math.max( 0, self.hp - parent:GetHealth() ) * self.burst, {damage_flags = DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
end