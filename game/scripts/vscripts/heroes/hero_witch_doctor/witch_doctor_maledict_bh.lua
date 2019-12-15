witch_doctor_maledict_bh = class({})

function witch_doctor_maledict_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local position = self:GetCursorPosition()
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("duration_tooltip")
	
	EmitSoundOnLocationWithCaster(position, "Hero_WitchDoctor.Maledict_Cast", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:AddNewModifier(caster, self, "modifier_witch_doctor_maledict_bh", {duration = duration})
		end
	end
end

modifier_witch_doctor_maledict_bh = class({})
LinkLuaModifier("modifier_witch_doctor_maledict_bh", "heroes/hero_witch_doctor/witch_doctor_maledict_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_witch_doctor_maledict_bh:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("base_damage")
	self.burst = self:GetTalentSpecialValueFor("bonus_damage") / 100
	if IsServer() then
		self.burstTimer = self:GetTalentSpecialValueFor("burst_interval")
		self.currentTime = GameRules:GetGameTime()
		self.hp = self:GetParent():GetHealth()
		self:StartIntervalThink( 0.25 )
		self:GetParent():EmitSound("Hero_WitchDoctor.Maledict_Loop")
		local maledictFX = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl( maledictFX, 1, Vector(self.burstTimer,0,0) )
		self:AddEffect(maledictFX)
	end
end

function modifier_witch_doctor_maledict_bh:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("base_damage")
	self.burst = self:GetTalentSpecialValueFor("bonus_damage") / 100
end

function modifier_witch_doctor_maledict_bh:OnIntervalThink()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	
	if self.currentTime + self.burstTimer <= GameRules:GetGameTime() then
		self.currentTime = GameRules:GetGameTime()
		ability:DealDamage( caster, parent, math.max( 0, self.hp - parent:GetHealth() ) * self.burst, {damage_flags = DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		self:GetParent():EmitSound("Hero_WitchDoctor.Maledict_Tick")
	end
	ability:DealDamage( caster, parent, self.damage * 0.25 )
end

function modifier_witch_doctor_maledict_bh:OnDestroy()
	if IsServer() then
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		self:GetParent():StopSound("Hero_WitchDoctor.Maledict_Loop")
		self:GetParent():EmitSound("Hero_WitchDoctor.Maledict_Tick")
		ability:DealDamage( caster, parent, math.max( 0, self.hp - parent:GetHealth() ) * self.burst, {damage_flags = DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
end