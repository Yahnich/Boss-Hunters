night_stalker_void_bh = class({})

function night_stalker_void_bh:GetIntriniscModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_night_stalker_void_1") then
		return "modifier_night_stalker_void_talent"
	end
end

function night_stalker_void_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("aoe")
end

function night_stalker_void_bh:OnSpellStart()
	self:Void(self:GetCursorTarget())
end

function night_stalker_void_bh:Void(target)
	local caster = self:GetCaster()
	local damage = self:GetAbilityDamage()
	local radius = self:GetTalentSpecialValueFor("aoe")
	local duration = self:GetTalentSpecialValueFor("duration_day")
	
	ParticleManager:FireParticle("particles/units/heroes/hero_night_stalker/nightstalker_loadout.vpcf", PATTACH_POINT_FOLLOW, target)
	EmitSoundOn( "Hero_Nightstalker.Void", target )
	
	if target:TriggerSpellAbsorb(self) then return end
	if not GameRules:IsDaytime() then
		duration = self:GetTalentSpecialValueFor("duration_night")
	end
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:DealDamage( caster, enemy, damage )
			ParticleManager:FireParticle("particles/units/heroes/hero_night_stalker/nightstalker_void_hit.vpcf", PATTACH_POINT_FOLLOW, enemy)
		end
	end
	
	self:Stun( target, self:GetTalentSpecialValueFor("mini_stun"), false )
	target:AddNewModifier(caster, self, "modifier_night_stalker_void_bh", {duration = duration})
	
	if caster:HasTalent("special_bonus_unique_night_stalker_void_2") then
		local nDur = caster:FindTalentValue("special_bonus_unique_night_stalker_void_2")
		GameRules:BeginNightstalkerNight( nDur )
	end
end

function night_stalker_void_bh:OnTalentLearned(talent)
	if self:GetCaster():HasTalent("special_bonus_unique_night_stalker_void_1") then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_night_stalker_void_talent", {})
	else
		self:GetCaster():RemoveModifierByName("modifier_night_stalker_void_talent")
	end
end

modifier_night_stalker_void_bh = class({})
LinkLuaModifier("modifier_night_stalker_void_bh", "heroes/hero_night_stalker/night_stalker_void_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_void_bh:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("movespeed_slow")
	self.as = self:GetTalentSpecialValueFor("attackspeed_slow")
end

function modifier_night_stalker_void_bh:OnRefresh()
	self.ms = self:GetTalentSpecialValueFor("movespeed_slow")
	self.as = self:GetTalentSpecialValueFor("attackspeed_slow")
end

function modifier_night_stalker_void_bh:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_night_stalker_void_bh:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_night_stalker_void_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_night_stalker_void_bh:GetEffectName()
	return "particles/units/heroes/hero_night_stalker/nightstalker_void.vpcf"
end

modifier_night_stalker_void_talent = class(relicBaseClass)
LinkLuaModifier("modifier_night_stalker_void_talent", "heroes/hero_night_stalker/night_stalker_void_bh", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_night_stalker_void_talent:OnCreated()
		self.delay = self:GetCaster():FindTalentValue("special_bonus_unique_night_stalker_void_1")
		self:SetDuration(-1, true)
		self:StartIntervalThink(0.25)
	end
	
	function modifier_night_stalker_void_talent:OnIntervalThink()
		local caster = self:GetCaster()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetAbility():GetTrueCastRange() ) ) do
			self:GetAbility():Void( enemy )
			self:SetDuration(self.delay, true)
			self:StartIntervalThink(self.delay)
			return
		end
		self:SetDuration(-1, true)
		self:StartIntervalThink(0.25)
	end
end