antimage_hex_guard = class ({})

function antimage_hex_guard:GetIntrinsicModifierName()
	return "modifier_antimage_hex_guard"
end

function antimage_hex_guard:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_antimage_hex_guard_2") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function antimage_hex_guard:GetCooldown()
	return self:GetCaster():FindTalentValue("special_bonus_unique_antimage_hex_guard_2", "cooldown")
end

function antimage_hex_guard:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_antimage_hex_guard_talent", {duration = caster:FindTalentValue("special_bonus_unique_antimage_hex_guard_2", "duration")})
	ParticleManager:FireParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_antimage_hex_guard_talent = class({})
LinkLuaModifier( "modifier_antimage_hex_guard_talent", "heroes/hero_antimage/antimage_hex_guard", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_antimage_hex_guard_talent:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
		
	function modifier_antimage_hex_guard_talent:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end
	
function modifier_antimage_hex_guard_talent:GetEffectName()
	return ""
end

modifier_antimage_hex_guard = class({})
LinkLuaModifier( "modifier_antimage_hex_guard", "heroes/hero_antimage/antimage_hex_guard", LUA_MODIFIER_MOTION_NONE)

function modifier_antimage_hex_guard:OnCreated()
	self.mr = self:GetTalentSpecialValueFor("magic_resistance")
	self.sr = self:GetTalentSpecialValueFor("status_resistance")
end

function modifier_antimage_hex_guard:OnRefresh()
	self.mr = self:GetTalentSpecialValueFor("magic_resistance")
	self.sr = self:GetTalentSpecialValueFor("status_resistance")
end

function modifier_antimage_hex_guard:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_STATUS_RESISTANCE, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_antimage_hex_guard:GetModifierMagicalResistanceBonus()
	if self:GetParent():HasModifier("modifier_antimage_hex_guard_talent") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_antimage_hex_guard_2")
	else
		return self.mr
	end
end

function modifier_antimage_hex_guard:GetModifierStatusResistance()
	if self:GetParent():HasModifier("modifier_antimage_hex_guard_talent") then
		return self:GetCaster():FindTalentValue("special_bonus_unique_antimage_hex_guard_2")
	else
		return self.sr
	end
end

function modifier_antimage_hex_guard:OnTakeDamage(params)
	local parent = self:GetParent()
	if params.unit == parent and params.damage_type == DAMAGE_TYPE_MAGICAL and parent:HasTalent("special_bonus_unique_antimage_hex_guard_1") 
	and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
		local damage = params.original_damage * self.mr / 100
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), parent:FindTalentValue("special_bonus_unique_antimage_hex_guard_1") ) ) do
			self:GetAbility():DealDamage( parent, params.attacker, damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION})
		end
	end
end

function modifier_antimage_hex_guard:IsHidden()
	return true
end