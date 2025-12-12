vengefulspirit_haunt = class({})

function vengefulspirit_haunt:IsStealable()
	return true
end

function vengefulspirit_haunt:IsHiddenWhenStolen()
	return false
end

function vengefulspirit_haunt:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_vengefulspirit_haunt_2") then
		return DOTA_ABILITY_BEHAVIOR_POINT
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function vengefulspirit_haunt:OnSpellStart()
	local caster = self:GetCaster()
	
	if caster:HasTalent("special_bonus_unique_vengefulspirit_haunt_2") then
		local position = self:GetCursorPosition()
		FindClearSpaceForUnit( caster, position, true )
	end
	
	caster:AddNewModifier( caster, self, "modifier_vengefulspirit_haunt", {duration = self:GetSpecialValueFor("duration")} )
	
	if caster:HasScepter() then
		local scepter_stun = self:GetSpecialValueFor("scepter_stun")
		local radius = self:GetSpecialValueFor("effect_radius") 
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
			self:Stun(enemy, scepter_stun)
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_vengeful/vengeful_spirit_haunt_scepter.vpcf", PATTACH_POINT_FOLLOW, caster, {[0] = caster:GetAbsOrigin(), [1] = Vector(radius, radius, radius)} )
	end
end

function vengefulspirit_haunt:LaunchPhantasms( radius, origin )
	local caster = self:GetCaster()
	local source = origin or caster
	local targets = 1
	if caster:HasTalent("special_bonus_unique_vengefulspirit_haunt_1") then
		targets = targets + 1
	end
	for _, target in ipairs( caster:FindEnemyUnitsInRadius( source:GetAbsOrigin(), radius, {order = FIND_CLOSEST} ) ) do
		if not target:HasModifier("modifier_vengefulspirit_haunt_debuff") then
			EmitSoundOn("Hero_ArcWarden.SparkWraith.Appear", source)
			self:FireTrackingProjectile("particles/units/heroes/hero_vengeful/vengeful_haunt.vpcf", target, 900, {source = source}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, 100)
			targets = targets - 1
			if targets == 0 then
				return true
			end
		end
	end
	if targets > 0 then
		for _, target in ipairs( caster:FindEnemyUnitsInRadius( source:GetAbsOrigin(), radius ) ) do
			EmitSoundOn("Hero_ArcWarden.SparkWraith.Appear", source)
			self:FireTrackingProjectile("particles/units/heroes/hero_vengeful/vengeful_haunt.vpcf", target, 900, {source = source}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, 100)
			targets = targets - 1
			if targets == 0 then
				return true
			end
		end
	end
	return false
end

function vengefulspirit_haunt:OnProjectileHit(target, position)
	if target ~= nil and not target:TriggerSpellAbsorb( self ) then
		local caster = self:GetCaster()
		EmitSoundOn("Hero_Bane.Nightmare.End", target)
		target:AddNewModifier(self:GetCaster(), self, "modifier_vengefulspirit_haunt_debuff", {Duration = self:GetSpecialValueFor("debuff_duration")})
		self:DealDamage( caster, target, self:GetSpecialValueFor("phantasm_damage") )
	end
end

modifier_vengefulspirit_haunt = class({})
LinkLuaModifier( "modifier_vengefulspirit_haunt", "heroes/hero_vengeful/vengefulspirit_haunt.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_vengefulspirit_haunt:OnCreated(table)
	self:OnRefresh()
end

function modifier_vengefulspirit_haunt:OnRefresh(table)
	self.radius = self:GetSpecialValueFor("effect_radius")
	self.tick_rate = self:GetSpecialValueFor("phantasm_rate")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_vengefulspirit_haunt_2")
	self.talent2CDR = -self:GetCaster():FindTalentValue("special_bonus_unique_vengefulspirit_haunt_2")
	if IsServer() then
		self:StartIntervalThink(self.tick_rate)
	end
end

function modifier_vengefulspirit_haunt:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if not ability:LaunchPhantasms( self.radius ) and self.talent2 then
		ability:ModifyCooldown( self.talent2CDR )
	end
end

function modifier_vengefulspirit_haunt:GetEffectName()
	return "particles/vengefulspirit_nether_furor_debuff.vpcf"
end

modifier_vengefulspirit_haunt_debuff = class({})
LinkLuaModifier( "modifier_vengefulspirit_haunt_debuff", "heroes/hero_vengeful/vengefulspirit_haunt.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_vengefulspirit_haunt_debuff:OnCreated()
	self:OnRefresh()
end

function modifier_vengefulspirit_haunt_debuff:OnRefresh()
	self.spell_amp = -self:GetSpecialValueFor("spell_damage_reduction")
	self.attack_dmg = -self:GetSpecialValueFor("attack_damage_reduction")
end

function modifier_vengefulspirit_haunt_debuff:OnDestroy()
	if IsServer() and not self:GetParent():IsAlive() then
		
	end
end

function modifier_vengefulspirit_haunt_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_DEATH }
end

function modifier_vengefulspirit_haunt_debuff:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_vengefulspirit_haunt_debuff:GetModifierBaseDamageOutgoing_Percentage()
	return self.attack_dmg
end

function modifier_vengefulspirit_haunt_debuff:OnDeath(params)
	if params.unit == self:GetParent() then
		self:GetAbility():LaunchPhantasms( self:GetSpecialValueFor("effect_radius"), self:GetParent() )
	end
end

function modifier_vengefulspirit_haunt_debuff:GetEffectName()
	return "particles/units/heroes/hero_vengeful/vengeful_haunt_debuff.vpcf"
end