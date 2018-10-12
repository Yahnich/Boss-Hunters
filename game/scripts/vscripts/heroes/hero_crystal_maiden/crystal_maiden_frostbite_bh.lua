crystal_maiden_frostbite_bh = class({})

function crystal_maiden_frostbite_bh:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_crystal_maiden_frostbite_1") then
		return "modifier_crystal_maiden_frostbite_bh_talent"
	end
end

function crystal_maiden_frostbite_bh:OnTalentLearned(talent)
	if talent == "special_bonus_unique_crystal_maiden_frostbite_1" then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_crystal_maiden_frostbite_bh_talent", {} )
	end
end

function crystal_maiden_frostbite_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local freezeDur = self:GetTalentSpecialValueFor("freeze_duration")
	local rootDur = TernaryOperator( self:GetTalentSpecialValueFor("root_duration"), target:IsRoundBoss(), self:GetTalentSpecialValueFor("creep_duration") )
	local totDur = rootDur + freezeDur
	
	local chill = target:GetChillCount()
	target:Freeze(self, caster, freezeDur)

	local chillDamage = chill * self:GetTalentSpecialValueFor("chill_damage")
	if chillDamage > 0 then
		self:DealDamage( caster, target, chillDamage)
	end
	
	local mod = target:AddNewModifier(caster, self, "modifier_crystal_maiden_frostbite_bh", {duration = totDur})
	
	target:EmitSound( "hero_Crystal.frostbite" )
end

modifier_crystal_maiden_frostbite_bh = class({})
LinkLuaModifier( "modifier_crystal_maiden_frostbite_bh", "heroes/hero_crystal_maiden/crystal_maiden_frostbite_bh" ,LUA_MODIFIER_MOTION_NONE )

function modifier_crystal_maiden_frostbite_bh:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage") * 0.5
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_crystal_maiden_frostbite_bh:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage )
end

function modifier_crystal_maiden_frostbite_bh:OnDestroy()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_crystal_maiden_frostbite_2") then
		local chill = caster:FindTalentValue("special_bonus_unique_crystal_maiden_frostbite_2")
		local cDur = caster:FindTalentValue("special_bonus_unique_crystal_maiden_frostbite_2", "duration")
		self:GetParent():AddChill(self:GetAbility(), caster, cDur, chill)
	end
end

function modifier_crystal_maiden_frostbite_bh:CheckState()
    local state = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

function modifier_crystal_maiden_frostbite_bh:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

modifier_crystal_maiden_frostbite_bh_talent = class({})
LinkLuaModifier( "modifier_crystal_maiden_frostbite_bh_talent", "heroes/hero_crystal_maiden/crystal_maiden_frostbite_bh" ,LUA_MODIFIER_MOTION_NONE )
function modifier_crystal_maiden_frostbite_bh_talent:OnCreated()
	self.internal = self:GetCaster():FindTalentValue("special_bonus_unique_crystal_maiden_frostbite_1")
end

function modifier_crystal_maiden_frostbite_bh_talent:OnIntervalThink()
	self:SetDuration(-1, true)
	self:StartIntervalThink(-1)
end

function modifier_crystal_maiden_frostbite_bh_talent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_crystal_maiden_frostbite_bh_talent:OnAttackLanded(params)
	if params.target == self:GetParent() and self:GetDuration() == -1 then
		params.target:SetCursorCastTarget( params.attacker )
		self:GetAbility():OnSpellStart()
		self:SetDuration( self.internal + 0.1, true )
		self:StartIntervalThink( self.internal )
	end
end

function modifier_crystal_maiden_frostbite_bh_talent:DestroyOnExpire()
	return false
end

function modifier_crystal_maiden_frostbite_bh_talent:RemoveOnDeath()
	return false
end