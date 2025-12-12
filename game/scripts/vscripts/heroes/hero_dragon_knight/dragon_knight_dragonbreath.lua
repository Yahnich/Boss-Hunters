dragon_knight_dragonbreath = class({})

function dragon_knight_dragonbreath:IsStealable()
	return true
end

function dragon_knight_dragonbreath:IsHiddenWhenStolen()
	return false
end

function dragon_knight_dragonbreath:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection( self:GetCursorPosition(), caster)
	
	local velocity = self:GetSpecialValueFor("speed")
	local distance = self:GetSpecialValueFor("range")
	local width = self:GetSpecialValueFor("start_radius")
	local endWidth = self:GetSpecialValueFor("end_radius")

	self:FireLinearProjectile("particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf", velocity * direction, distance, width, {width_end = endWidth})
	
	EmitSoundOn("Hero_DragonKnight.BreathFire", caster)
end

function dragon_knight_dragonbreath:DropFirePool( position, radius, duration )
	local vPos = GetGroundPosition( position, caster)
	local rad = radius
	local dur = duration
	local caster = self:GetCaster()
	local ability = self
	local poolFX = ParticleManager:CreateParticle("particles/neutral_fx/black_dragon_fireball.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(poolFX, 0, vPos )
	ParticleManager:SetParticleControl(poolFX, 1, vPos )
	ParticleManager:SetParticleControl(poolFX, 2, Vector(duration,0,0) )
	ParticleManager:SetParticleControl(poolFX, 3, vPos )
	local damage = ability:GetSpecialValueFor("dot_damage")
	Timers:CreateTimer(1, function()
		local enemies = caster:FindEnemyUnitsInRadius(vPos, rad)
		for _, enemy in ipairs( enemies ) do
			ability:DealDamage( caster, enemy, damage )
		end
		if dur >= 0 then
			dur = dur - 1
			return 1
		else
			ParticleManager:ClearParticle(poolFX)
		end
	end)
end

function dragon_knight_dragonbreath:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	if target and not target:IsMagicImmune() and not target:IsInvulnerable() and not target:TriggerSpellAbsorb(self) then
		local damage = self:GetSpecialValueFor("hit_damage")
		local duration = self:GetSpecialValueFor("duration")
		
		self:DealDamage( caster, target, damage )
		target:AddNewModifier( caster, self, "modifier_dragon_knight_dragonbreath_debuff", {duration = duration} )
	else
		if caster:HasTalent("special_bonus_unique_dragon_knight_dragonbreath_1") then
			self:DropFirePool( position, self:GetSpecialValueFor("end_radius"), self:GetSpecialValueFor("duration") * caster:FindTalentValue("special_bonus_unique_dragon_knight_dragonbreath_1"))
		end
	end
	return false
end

modifier_dragon_knight_dragonbreath_debuff = class({})
LinkLuaModifier("modifier_dragon_knight_dragonbreath_debuff", "heroes/hero_dragon_knight/dragon_knight_dragonbreath", LUA_MODIFIER_MOTION_NONE)

function modifier_dragon_knight_dragonbreath_debuff:OnCreated()
	self.dmg_reduction = self:GetSpecialValueFor("reduction")
	self.dot_dmg = self:GetSpecialValueFor("dot_damage")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_dragon_knight_dragonbreath_debuff:OnRefresh()
	self.dmg_reduction = self:GetSpecialValueFor("reduction")
	self.dot_dmg = self:GetSpecialValueFor("dot_damage")
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