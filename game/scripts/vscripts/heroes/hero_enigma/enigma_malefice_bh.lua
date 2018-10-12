enigma_malefice_bh = class({})

function enigma_malefice_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	caster:EmitSound( "Hero_Enigma.Malefice" )
	target:AddNewModifier(caster, self, "modifier_enigma_malefice_bh", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_enigma_malefice_bh = class({})
LinkLuaModifier("modifier_enigma_malefice_bh", "heroes/hero_enigma/enigma_malefice_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_enigma_malefice_bh:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.tick = self:GetTalentSpecialValueFor("tick_rate") * (self:GetRemainingTime() / self:GetTalentSpecialValueFor("duration"))
	self.stun = self:GetTalentSpecialValueFor("stun_duration")
	if IsServer() then
		self.tRadius = self:GetCaster():FindTalentValue("special_bonus_unique_enigma_malefice_1")
		self:Malefice()
		self:StartIntervalThink( self.tick )
	end
end

function modifier_enigma_malefice_bh:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.tick = self:GetTalentSpecialValueFor("tick_rate") * (self:GetRemainingTime() / self:GetTalentSpecialValueFor("duration"))
	self.stun = self:GetTalentSpecialValueFor("stun_duration")
	if IsServer() then
		self.tRadius = self:GetCaster():FindTalentValue("special_bonus_unique_enigma_malefice_1")
		self:Malefice()
		self:StartIntervalThink( self.tick )
	end
end

function modifier_enigma_malefice_bh:OnIntervalThink()
	self:Malefice()
end

function modifier_enigma_malefice_bh:OnDestroy()
	if IsServer() then self:Malefice() end
end

function modifier_enigma_malefice_bh:Malefice()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	
	local position = parent:GetAbsOrigin()
	parent:EmitSound("Hero_Enigma.MaleficeTick")
	local wave = ParticleManager:FireParticle( "particles/units/heroes/hero_enigma/enigma_malefice_talent_mid.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent,{	[0] = position + Vector(0,0,64),
																																						[1] = Vector(5,0.5,self.tRadius),
																																						[2] = position + Vector(0,0,64)} )
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, self.tRadius ) ) do
		ability:DealDamage( caster, enemy, self.damage )
		ability:Stun( enemy, self.stun )
	end
end

function modifier_enigma_malefice_bh:GetEffectName()
	return "particles/units/heroes/hero_enigma/enigma_malefice.vpcf"
end

function modifier_enigma_malefice_bh:GetStatusEffectName()
	return "particles/status_fx/status_effect_enigma_malefice.vpcf"
end

function modifier_enigma_malefice_bh:StatusEffectPriority()
	return 1
end
