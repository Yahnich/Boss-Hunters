rattletrap_automated_artillery = class({})

function rattletrap_automated_artillery:IsStealable()
	return true
end

function rattletrap_automated_artillery:IsHiddenWhenStolen()
	return false
end

function rattletrap_automated_artillery:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_rattletrap_automated_artillery_1") then
		return DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
end

function rattletrap_automated_artillery:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_rattletrap_automated_artillery", {duration = self:GetTalentSpecialValueFor("duration")})
end

function rattletrap_automated_artillery:OnUpgrade()
	local sisterAb = self:GetCaster():FindAbilityByName("rattletrap_reactive_shielding")
	if sisterAb and sisterAb:GetLevel() < self:GetLevel() then sisterAb:SetLevel( self:GetLevel() ) end
end

function rattletrap_automated_artillery:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_rattletrap_automated_artillery", {})
	else
		caster:RemoveModifierByName("modifier_rattletrap_automated_artillery")
	end
end

function rattletrap_automated_artillery:OnProjectileHit(target, position)
	if target and not target:IsMagicImmune() then	
		EmitSoundOn( "Hero_Rattletrap.Automated_Artillery.Explode", target )
		self:DealDamage(self:GetCaster(), target, self:GetTalentSpecialValueFor("damage_per_rocket") )
	end
end

modifier_rattletrap_automated_artillery = class({})
LinkLuaModifier("modifier_rattletrap_automated_artillery", "heroes/hero_rattletrap/rattletrap_automated_artillery", LUA_MODIFIER_MOTION_NONE)

function modifier_rattletrap_automated_artillery:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage_per_rocket")
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.rockets = self:GetTalentSpecialValueFor("rockets_per_second")
	if IsServer() then 
		self.sisterAb = self:GetCaster():FindAbilityByName("rattletrap_reactive_shielding")
		if self.sisterAb then
			self.sisterAb:SetActivated(false)
		end
		if not self:GetAbility():IsToggle() then self:GetAbility():StartDelayedCooldown() end
		self:StartIntervalThink(1 / self.rockets)
	end
end

function modifier_rattletrap_automated_artillery:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("damage_per_rocket")
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.rockets = self:GetTalentSpecialValueFor("rockets_per_second")
	if IsServer() then 
		if self.sisterAb then
			self.sisterAb:SetActivated(false)
		end
		if not self:GetAbility():IsToggle() then self:GetAbility():StartDelayedCooldown() end
		self:StartIntervalThink(1 / self.rockets)
	end
end

function modifier_rattletrap_automated_artillery:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	for _, enemy in ipairs( self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius ) ) do
		if caster:HasTalent("special_bonus_unique_rattletrap_automated_artillery_1") and ability:GetToggleState() then
			if caster:GetMana() >= ability:GetManaCost(-1) then
				local manaCost = ability:GetManaCost(-1) / ( self.rockets * (self:GetTalentSpecialValueFor("duration") / 2) )
				caster:SpendMana( manaCost, ability )
			else
				ability:ToggleAbility()
			end
		end
		EmitSoundOn( "Hero_Rattletrap.Automated_Artillery.Fire", self:GetParent())
		local projectile = {
			Target = enemy,
			Source = caster,
			Ability = ability,
			EffectName = "particles/units/heroes/hero_rattletrap/rattletrap_automated_artillery_projectile.vpcf",
			bDodgable = true,
			bProvidesVision = false,
			iMoveSpeed = 1200,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		}
		ProjectileManager:CreateTrackingProjectile(projectile)
		break
	end
end

function modifier_rattletrap_automated_artillery:OnDestroy()
	if IsServer() then
		if self.sisterAb then
			self.sisterAb:SetActivated(true)
		end
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_rattletrap_automated_artillery:IsPurgable()
	return not self:GetCaster():HasTalent("special_bonus_unique_rattletrap_automated_artillery_1")
end