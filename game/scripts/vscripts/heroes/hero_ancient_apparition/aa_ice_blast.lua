aa_ice_blast = class({})
LinkLuaModifier("modifier_aa_ice_blast", "heroes/hero_ancient_apparition/aa_ice_blast", LUA_MODIFIER_MOTION_NONE)

function aa_ice_blast:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
	local vDir = CalculateDirection(targetPos, caster:GetAbsOrigin())
	local vDistance = CalculateDistance(targetPos, caster:GetAbsOrigin())
	local speed = 1500
	local initWidth = self:GetSpecialValueFor("radius_min")
	local endWidth = math.min( initWidth + (vDistance / speed) * self:GetSpecialValueFor("radius_grow"), self:GetSpecialValueFor("radius_max" ) )
	extraData = {}
	extraData["endWidth"] = endWidth
	
	EmitSoundOn("Hero_Ancient_Apparition.IceBlastRelease.Cast.Self", caster)
	
	self:FireLinearProjectile("particles/units/heroes/hero_aa/aa_ice_blastfinal.vpcf", vDir * speed, vDistance, initWidth, {width_end = endWidth, extraData = extraData}, false, true, 500)
end
	
function aa_ice_blast:OnProjectileHit_ExtraData(target, position, extraData)
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local coldFeet = caster:FindAbilityByName("aa_cold_feet")
	if target then
		if not target:TriggerSpellAbsorb(self) then
			target:AddNewModifier(caster, self, "modifier_aa_ice_blast", {duration = duration})
			if caster:HasScepter() and coldFeet then
				target:AddNewModifier(caster, coldFeet, "modifier_aa_cold_feet", {Duration = coldFeet:GetSpecialValueFor("duration")})
			end
		end
	else
		if caster:HasScepter() then
			local vortex = caster:FindAbilityByName("aa_ice_vortex")
			if vortex then
				CreateModifierThinker(caster, vortex, "modifier_aa_ice_vortex", {Duration = vortex:GetSpecialValueFor("duration")}, position, caster:GetTeam(), false)
			end
		end
		EmitSoundOnLocationWithCaster(position, "Hero_Ancient_Apparition.IceBlast.Target", self:GetCaster())
		local groundPos = GetGroundPosition(position, caster) + Vector(0,0,10)
		ParticleManager:FireParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_explode.vpcf", PATTACH_POINT, caster, {[0]=groundPos,[3]=groundPos})
		local targets = caster:FindEnemyUnitsInRadius(position, tonumber(extraData["endWidth"]))
		for _, enemy in ipairs(targets) do
			if not enemy:TriggerSpellAbsorb(self) then
				enemy:AddNewModifier(caster, self, "modifier_aa_ice_blast", {duration = duration})
				self:DealDamage(caster, enemy, self:GetSpecialValueFor("damage"))
				if caster:HasScepter() and coldFeet then
					enemy:AddNewModifier(caster, coldFeet, "modifier_aa_cold_feet", {Duration = coldFeet:GetSpecialValueFor("duration")})
				end
			end
		end
	end
end

modifier_aa_ice_blast = class({})
function modifier_aa_ice_blast:OnCreated(table)
	self.damage = self:GetSpecialValueFor("dot_damage")
	self.shatter = self:GetSpecialValueFor("kill_pct")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_aa_ice_blast:OnRefresh(table)
	self.damage = self:GetSpecialValueFor("dot_damage")
	self.shatter = self:GetSpecialValueFor("kill_pct")
end

function modifier_aa_ice_blast:OnIntervalThink()
	EmitSoundOn("Hero_Ancient_Apparition.IceBlastRelease.Tick", self:GetParent())
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
end

function modifier_aa_ice_blast:DeclareFunctions()
	return {MODIFIER_PROPERTY_DISABLE_HEALING, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_aa_ice_blast:GetDisableHealing()
	return 1
end

function modifier_aa_ice_blast:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.unit:GetHealthPercent() <= self.shatter and params.unit:IsAlive() 
	and not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR) then
		ParticleManager:FireParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_death.vpcf", PATTACH_POINT, self:GetParent(), {})
		self:GetParent():AttemptKill( self:GetAbility(), self:GetCaster() )
	end
end

function modifier_aa_ice_blast:GetEffectName()
	return "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_debuff.vpcf"
end

function modifier_aa_ice_blast:GetStatusEffectName()
	return "particles/status_fx/status_effect_iceblast.vpcf"
end

function modifier_aa_ice_blast:StatusEffectPriority()
	return 10
end