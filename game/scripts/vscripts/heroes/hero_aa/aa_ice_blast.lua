aa_ice_blast = class({})
LinkLuaModifier("modifier_aa_ice_blast", "heroes/hero_aa/aa_ice_blast", LUA_MODIFIER_MOTION_NONE)

function aa_ice_blast:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
	local vDir = CalculateDirection(targetPos, caster:GetAbsOrigin())
	local vDistance = CalculateDistance(targetPos, caster:GetAbsOrigin())
	local speed = 1500
	local initWidth = self:GetTalentSpecialValueFor("radius_min")
	local endWidth = math.min( initWidth + (vDistance / speed) * self:GetTalentSpecialValueFor("radius_grow"), self:GetTalentSpecialValueFor("radius_max" ) )
	extraData = {}
	extraData["endWidth"] = endWidth
	
	EmitSoundOn("Hero_Ancient_Apparition.IceBlastRelease.Cast.Self", caster)
	
	self:FireLinearProjectile("particles/units/heroes/hero_aa/aa_ice_blastfinal.vpcf", vDir * speed, vDistance, initWidth, {width_end = endWidth, extraData = extraData}, false, true, 500)
end
	
function aa_ice_blast:OnProjectileHit_ExtraData(target, position, extraData)
	local caster = self:GetCaster()
	local duration = self:GetTalentSpecialValueFor("duration")
	if target then
		target:AddNewModifier(caster, self, "modifier_aa_ice_blast", {duration = duration})
	else
		EmitSoundOnLocationWithCaster(position, "Hero_Ancient_Apparition.IceBlast.Target", self:GetCaster())
		local groundPos = GetGroundPosition(position, caster) + Vector(0,0,10)
		ParticleManager:FireParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_explode.vpcf", PATTACH_POINT, caster, {[0]=groundPos,[3]=groundPos})
		local targets = caster:FindEnemyUnitsInRadius(position, tonumber(extraData["endWidth"]))
		for _, target in ipairs(targets) do
			target:AddNewModifier(caster, self, "modifier_aa_ice_blast", {duration = duration})
			self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage"))
		end
	end
end

modifier_aa_ice_blast = class({})
function modifier_aa_ice_blast:OnCreated(table)
	self.damage = self:GetTalentSpecialValueFor("dot_damage")
	self.shatter = self:GetTalentSpecialValueFor("kill_pct")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_aa_ice_blast:OnRefresh(table)
	self.damage = self:GetTalentSpecialValueFor("dot_damage")
	self.shatter = self:GetTalentSpecialValueFor("kill_pct")
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
	if params.unit == self:GetParent() and params.unit:GetHealthPercent() <= self.shatter and params.unit:IsAlive() then
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