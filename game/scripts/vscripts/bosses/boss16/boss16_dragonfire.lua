boss16_dragonfire = class({})

function boss16_dragonfire:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	ParticleManager:FireLinearWarningParticle(caster:GetAbsOrigin(), caster:GetAbsOrigin() + CalculateDirection(self:GetCursorPosition(), self:GetCaster()) * self:GetSpecialValueFor("range"))
	return true
end

function boss16_dragonfire:OnSpellStart()
	EmitSoundOn( "Hero_DragonKnight.BreathFire", self:GetCaster() )
	self:FireLinearProjectile("particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf", self:GetSpecialValueFor("speed") * CalculateDirection(self:GetCursorPosition(), self:GetCaster()), self:GetSpecialValueFor("range"), self:GetSpecialValueFor("start_radius"), {width_end = self:GetSpecialValueFor("")})
end

function boss16_dragonfire:OnProjectileHit(hTarget, vPosition)
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local caster = self:GetCaster()
		local damage = self:GetSpecialValueFor("initial_damage")
		local duration = self:GetSpecialValueFor("duration")
		self:DealDamage(caster, hTarget, damage)
		if self:GetLevel() > 2 then hTarget:AddNewModifier(caster, self, "modifier_boss16_dragonfire", {duration = duration}) end
	end
	return false
end

modifier_boss16_dragonfire = class({})
LinkLuaModifier("modifier_boss16_dragonfire", "bosses/boss16/boss16_dragonfire.lua", 0)

function modifier_boss16_dragonfire:OnCreated()
	self.armor = self:GetSpecialValueFor("armor_reduction")
	self.dot = self:GetSpecialValueFor("damage_over_time")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_boss16_dragonfire:OnIntervalThink()
	if self:GetAbility() and self:GetCaster() and self:GetParent() then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.dot)
	end
end

function modifier_boss16_dragonfire:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_boss16_dragonfire:GetModifierPhysicalArmorBonus()
	return self.armor
end