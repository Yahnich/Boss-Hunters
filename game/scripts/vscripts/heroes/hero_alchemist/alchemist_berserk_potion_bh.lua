alchemist_berserk_potion_bh = class({})

function alchemist_berserk_potion_bh:IsStealable()
	return true
end

function alchemist_berserk_potion_bh:IsHiddenWhenStolen()
	return false
end

function alchemist_berserk_potion_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	self:FireTrackingProjectile("particles/units/heroes/hero_alchemist/alchemist_berserk_potion_projectile.vpcf", target, self:GetTalentSpecialValueFor("projectile_speed"))
	EmitSoundOn( "Hero_Alchemist.UnstableConcoction.Throw", caster )
end

function alchemist_berserk_potion_bh:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		target:Dispel( caster, true )
		target:HealEvent( target:GetMaxHealth() * self:GetTalentSpecialValueFor("max_hp_heal") / 100, self, caster )
		target:AddNewModifier( caster, self, "modifier_alchemist_berserk_potion_stats", {duration = self:GetTalentSpecialValueFor("duration")} )
		
		if caster:HasTalent("special_bonus_unique_alchemist_berserk_potion_1") then
			local rage = caster:FindAbilityByName("alchemist_chemical_rage_bh")
			if rage then	
				target:AddNewModifier(caster, rage, "modifier_alchemist_chemical_rage_bh", {duration = self:GetTalentSpecialValueFor("duration")})
			end
		end
		
		EmitSoundOn( "Hero_Alchemist.Scepter.Cast", target )
	end
end

modifier_alchemist_berserk_potion_stats = class({})
LinkLuaModifier("modifier_alchemist_berserk_potion_stats", "heroes/hero_alchemist/alchemist_berserk_potion_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_berserk_potion_stats:OnCreated()
	self:OnRefresh()
end

function modifier_alchemist_berserk_potion_stats:OnRefresh()
	if self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
		self.strength = self:GetTalentSpecialValueFor("primary_bonus")
	elseif self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY  then
		self.agility = self:GetTalentSpecialValueFor("primary_bonus")
	elseif self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT  then
		self.intelligence = self:GetTalentSpecialValueFor("primary_bonus")
	end
end

function modifier_alchemist_berserk_potion_stats:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function modifier_alchemist_berserk_potion_stats:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_alchemist_berserk_potion_stats:GetModifierBonusStats_Agility()
	return self.agility
end

function modifier_alchemist_berserk_potion_stats:GetModifierBonusStats_Intellect()
	return self.intelligence
end

function modifier_alchemist_berserk_potion_stats:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_berserk_buff.vpcf"
end