witch_doctor_maledict_bh = class({})

function witch_doctor_maledict_bh:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_witch_doctor_marasa_mirror") then
		return "custom/witch_doctor_maledict_heal"
	else
		return "witch_doctor_maledict"
	end
end

function witch_doctor_maledict_bh:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function witch_doctor_maledict_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local position = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration_tooltip")
	
	EmitSoundOnLocationWithCaster(position, "Hero_WitchDoctor.Maledict_Cast", caster)
	if caster:HasScepter() then
		ParticleManager:FireParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
		ParticleManager:FireParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe_heal.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
			if not enemy:TriggerSpellAbsorb( self ) then
				enemy:AddNewModifier(caster, self, "modifier_witch_doctor_maledict_bh", {duration = duration})
			end
		end
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( position, radius ) ) do
			ally:AddNewModifier(caster, self, "modifier_witch_doctor_maledict_bh_heal", {duration = duration})
		end
		-- find scepter target
		local scepterTarget
		for _, unit in ipairs( caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do	
			if not (unit:HasModifier("modifier_witch_doctor_maledict_bh") or unit:HasModifier("modifier_witch_doctor_maledict_bh_heal") ) then
				scepterTarget = unit
				break
			end
		end
		if scepterTarget then
			local scepterPos = scepterTarget:GetAbsOrigin()
			ParticleManager:FireParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = scepterPos, [1] = Vector(radius,1,1)})
			ParticleManager:FireParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe_heal.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = scepterPos, [1] = Vector(radius,1,1)})
			for _, unit in ipairs( caster:FindAllUnitsInRadius( scepterPos, radius ) ) do	
				if unit:IsSameTeam( caster ) then
					unit:AddNewModifier(caster, self, "modifier_witch_doctor_maledict_bh_heal", {duration = duration})
				else
					unit:AddNewModifier(caster, self, "modifier_witch_doctor_maledict_bh", {duration = duration})
				end
			end
		end
	else
		if not caster:HasModifier("modifier_witch_doctor_marasa_mirror") then	
			ParticleManager:FireParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
				if not enemy:TriggerSpellAbsorb( self ) then
					enemy:AddNewModifier(caster, self, "modifier_witch_doctor_maledict_bh", {duration = duration})
				end
			end
		else
			ParticleManager:FireParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_aoe_heal.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = Vector(radius,1,1)})
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( position, radius ) ) do
				ally:AddNewModifier(caster, self, "modifier_witch_doctor_maledict_bh_heal", {duration = duration})
			end
		end
	end
end

modifier_witch_doctor_maledict_bh = class({})
LinkLuaModifier("modifier_witch_doctor_maledict_bh", "heroes/hero_witch_doctor/witch_doctor_maledict_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_witch_doctor_maledict_bh:OnCreated()
	self.damage = self:GetSpecialValueFor("base_damage")
	self.burst = self:GetSpecialValueFor("bonus_damage") / 100
	if IsServer() then
		self.burstTimer = self:GetSpecialValueFor("burst_interval")
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
	self.damage = self:GetSpecialValueFor("base_damage")
	self.burst = self:GetSpecialValueFor("bonus_damage") / 100
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


modifier_witch_doctor_maledict_bh_heal = class({})
LinkLuaModifier("modifier_witch_doctor_maledict_bh_heal", "heroes/hero_witch_doctor/witch_doctor_maledict_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_witch_doctor_maledict_bh_heal:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self.burstTimer = self:GetSpecialValueFor("burst_interval")
		self.currentTime = GameRules:GetGameTime()
		self.hp = self:GetParent():GetHealth()
		self:StartIntervalThink( 0.25 )
		self:GetParent():EmitSound("Hero_WitchDoctor.Maledict_Loop")
		local maledictFX = ParticleManager:CreateParticle("particles/units/heroes/hero_witchdoctor/witchdoctor_maledict_heal.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl( maledictFX, 1, Vector(self.burstTimer,0,0) )
		self:AddEffect(maledictFX)
	end
end

function modifier_witch_doctor_maledict_bh_heal:OnRefresh()
	self.damage = self:GetSpecialValueFor("base_heal")
	self.burst = self:GetSpecialValueFor("bonus_damage") / 100
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_witch_doctor_maledict_1")
	self.magic_resistance = self:GetCaster():FindTalentValue("special_bonus_unique_witch_doctor_maledict_1", "mr")
end

function modifier_witch_doctor_maledict_bh_heal:OnIntervalThink()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	
	if self.currentTime + self.burstTimer <= GameRules:GetGameTime() then
		self.currentTime = GameRules:GetGameTime()
		parent:HealEvent(math.max( 0, parent:GetHealth() - self.hp ) * self.burst, ability, caster)
		self:GetParent():EmitSound("Hero_WitchDoctor.Maledict_Tick")
	end
	parent:HealEvent(self.damage * 0.25, ability, caster)
end

function modifier_witch_doctor_maledict_bh_heal:OnDestroy()
	if IsServer() then
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		self:GetParent():StopSound("Hero_WitchDoctor.Maledict_Loop")
		self:GetParent():EmitSound("Hero_WitchDoctor.Maledict_Tick")
		parent:HealEvent(math.max( 0, parent:GetHealth() - self.hp ) * self.burst, ability, caster)
	end
end

function modifier_witch_doctor_maledict_bh_heal:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_witch_doctor_maledict_bh_heal:GetModifierMagicalResistanceBonus()
	return self.magic_resistance
end

function modifier_witch_doctor_maledict_bh_heal:GetModifierPhysicalArmorBonus()
	return self.armor
end