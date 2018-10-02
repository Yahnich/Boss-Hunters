vile_archmage_unstable_wand = class({})

function vile_archmage_unstable_wand:GetIntrinsicModifierName()
	return "modifier_vile_archmage_unstable_wand"
end

modifier_vile_archmage_unstable_wand = class({})
LinkLuaModifier("modifier_vile_archmage_unstable_wand", "bosses/boss_vile_archmage/vile_archmage_unstable_wand", LUA_MODIFIER_MOTION_NONE)

function modifier_vile_archmage_unstable_wand:OnCreated()
	self.dmg = self:GetTalentSpecialValueFor("damage_pct") / 100
end

function modifier_vile_archmage_unstable_wand:OnRefresh()
	self.dmg = self:GetTalentSpecialValueFor("damage_pct") / 100
end

function modifier_vile_archmage_unstable_wand:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_vile_archmage_unstable_wand:OnTakeDamage(params)
	if params.attacker == self:GetParent() 
	and params.unit ~= self:GetParent() 
	and self:GetParent():GetHealth() > 0 
	and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) )
	and not params.inflictor then
		self:GetAbility():DealDamage( params.attacker, params.unit, params.original_damage * self.dmg, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
end

function modifier_vile_archmage_unstable_wand:IsHidden()
	return true
end