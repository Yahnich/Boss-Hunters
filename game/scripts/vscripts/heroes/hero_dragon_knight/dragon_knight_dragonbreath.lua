dragon_knight_dragonbreath = class({})

function dragon_knight_dragonbreath:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection( self:GetCursorPosition(), caster)
	
	local velocity = self:GetTalentSpecialValueFor("speed")
	local distance = self:GetTalentSpecialValueFor("range")
	local width = self:GetTalentSpecialValueFor("start_radius")
	local endWidth = self:GetTalentSpecialValueFor("end_radius")

	self:FireLinearProjectile("particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf", velocity * direction, distance, width, {width_end = endWidth})
	
	EmitSoundOn("Hero_DragonKnight.BreathFire", caster)
end

function dragon_knight_dragonbreath:OnProjectileHit(target, position)
	if target and not target:IsMagicImmune() and not target:IsInvulnerable() then
		local caster = self:GetCaster()
		
		local damage = self:GetTalentSpecialValueFor("end_radius")
		local duration = self:GetTalentSpecialValueFor("duration")
		
		self:DealDamage( caster, target, damage )
		target:AddNewModifier( caster, self, "modifier_dragon_knight_dragonbreath_debuff", {duration = duration} )
	end
	return false
end

modifier_dragon_knight_dragonbreath_debuff = class({})
LinkLuaModifier("modifier_dragon_knight_dragonbreath_debuff", "heroes/hero_dragon_knight/dragon_knight_dragonbreath", LUA_MODIFIER_MOTION_NONE)

function modifier_dragon_knight_dragonbreath_debuff:OnCreated()
	self.dmg_reduction = self:GetTalentSpecialValueFor("reduction")
	self.dot_dmg = self:GetTalentSpecialValueFor("dot_damage")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_dragon_knight_dragonbreath_debuff:OnRefresh()
	self.dmg_reduction = self:GetTalentSpecialValueFor("reduction")
	self.dot_dmg = self:GetTalentSpecialValueFor("dot_damage")
end

function modifier_dragon_knight_dragonbreath_debuff:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.dot_dmg )
end

function modifier_dragon_knight_dragonbreath_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_dragon_knight_dragonbreath_debuff:GetModifierDamageOutgoing_Percentage()
	local red = self.dmg_reduction
	if self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_dragon_knight_elder_dragon_berserker_active") then red = red * 2 end
	return red
end