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
	self.radius = self:GetSpecialValueFor("radius")
	self.absorbed_to_damage = self:GetSpecialValueFor("absorbed_to_damage") / 100
	self.damage_reflect = self:GetSpecialValueFor("damage_reflect") / 100
	self.absorb = self:GetSpecialValueFor("damage_absorb")
	self.original_absorb = self.absorb
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
		
		self:SetHasCustomTransmitterData(true)
	end
end

function modifier_abaddon_stygian_ward:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		
		EmitSoundOn("Hero_Abaddon.AphoticShield.Destroy", parent)
		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
		local damage = self.original_absorb * self.absorbed_to_damage
		for _, enemy in ipairs( enemies ) do
			if not enemy:TriggerSpellAbsorb(self:GetAbility()) then
				self:GetAbility():DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL})
			end
		end
	end
end

function modifier_abaddon_stygian_ward:DeclareFunctions(params)
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT
    }
    return funcs
end

function modifier_abaddon_stygian_ward:GetModifierIncomingDamageConstant( params )
	if IsServer() then
		local absorb = math.min( self.absorb, math.max( self.absorb, params.damage ) )
		self.absorb = math.max( self.absorb - params.damage, 0 )
		if self.damage_reflect > 0 and not HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) then
			local caster = self:GetCaster()
			local ability = self:GetAbility()
			ParticleManager:FireParticle( "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion_wave.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self.radius ) ) do
				ability:DealDamage( caster, enemy, params.damage * self.damage_reflect, {damage_type = params.damage_type, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION } )
			end
		end
		if self.absorb <= 0 then 
			self:Destroy()
			return
		end
		self:SendBuffRefreshToClients()
		return -absorb
	else
		return self.absorb
	end
end

function modifier_abaddon_stygian_ward:AddCustomTransmitterData()
	return {absorb = self.absorb}
end

function modifier_abaddon_stygian_ward:HandleCustomTransmitterData(data)
	self.absorb = data.absorb
end