abaddon_stygian_ward = class({})

function abaddon_stygian_ward:IsStealable()
	return true
end

function abaddon_stygian_ward:IsHiddenWhenStolen()
	return false
end

function abaddon_stygian_ward:GetBehavior(iLvl)
	if self:GetSpecialValueFor("no_target") == 1 then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function abaddon_stygian_ward:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or caster
	target:Dispel(caster, true)
	target:RemoveModifierByName("modifier_abaddon_stygian_ward")
	if caster:HasTalent("special_bonus_unique_abaddon_stygian_ward_1") then
		local targets = caster:FindFriendlyUnitsInRadius( target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_abaddon_stygian_ward_1") )
		for _, hitTarget in ipairs( targets ) do
			hitTarget:AddNewModifier(caster, self, "modifier_abaddon_stygian_ward", {duration = self:GetSpecialValueFor("duration")})
		end
	else
		target:AddNewModifier(caster, self, "modifier_abaddon_stygian_ward", {duration = self:GetSpecialValueFor("duration")})
	end
end


modifier_abaddon_stygian_ward = class({})
LinkLuaModifier("modifier_abaddon_stygian_ward", "heroes/hero_abaddon/abaddon_stygian_ward", LUA_MODIFIER_MOTION_NONE)

function modifier_abaddon_stygian_ward:OnCreated()
	self.absorb = self:GetSpecialValueFor("damage_absorb")
	self.radius = self:GetSpecialValueFor("radius")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_abaddon_stygian_ward_2")
	if IsServer() then
		local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		local sRadius = self:GetParent():GetModelRadius() * 0.6 + 25
		local vFX = Vector(sRadius,0,sRadius)
		ParticleManager:SetParticleControlEnt(nFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nFX, 1, vFX)
		ParticleManager:SetParticleControl(nFX, 2, vFX)
		ParticleManager:SetParticleControl(nFX, 4, vFX)
		ParticleManager:SetParticleControl(nFX, 5, vFX)
		self:AddEffect(nFX)
	end
end

function modifier_abaddon_stygian_ward:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		
		EmitSoundOn("Hero_Abaddon.AphoticShield.Destroy", parent)
		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
		local damage =  self:GetSpecialValueFor("damage_absorb")
		for _, enemy in ipairs( enemies ) do
			if not enemy:TriggerSpellAbsorb(self:GetAbility()) then
				self:GetAbility():DealDamage(caster, enemy, damage)
			end
		end
	end
end

function modifier_abaddon_stygian_ward:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_abaddon_stygian_ward:GetModifierIncomingDamage_Percentage(params)
	if not self:GetParent():HasModifier("modifier_abaddon_borrowed_time_active") and params.damage > 0 then
		if self.absorb > params.damage then
			if self.talent2 and not HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) then
				local caster = self:GetCaster()
				local ability = self:GetAbility()
				ParticleManager:FireParticle( "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion_wave.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self.radius ) ) do
					ability:DealDamage( caster, enemy, params.damage, {damage_type = params.damage_type, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION } )
				end
			end
			self.absorb = self.absorb - params.damage
			return -999
		else
			self:Destroy()
			return ((self.absorb / params.damage) * 100) * (-1)
		end
	end
end

function modifier_abaddon_stygian_ward:OnTooltip()
	return self.absorb
end