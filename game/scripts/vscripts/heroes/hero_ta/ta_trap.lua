ta_trap = class({})
LinkLuaModifier( "modifier_ta_trap", "heroes/hero_ta/ta_trap.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ta_trap_spring", "heroes/hero_ta/ta_trap.lua" ,LUA_MODIFIER_MOTION_NONE )

function ta_trap:GetCooldown( iLvl )
	local cd = self.BaseClass.GetCooldown( self, iLvl )
	if self:GetCaster():HasScepter() then
		cd = cd + self:GetTalentSpecialValueFor("scepter_cooldown_reduction")
	end
	return cd
end

function ta_trap:GetAOERadius()
	local radius = self:GetTalentSpecialValueFor("trap_radius")
	if self:GetCaster():HasScepter() then
		radius = radius + self:GetTalentSpecialValueFor("scepter_bonus_radius")
	end
	return radius
end

function ta_trap:IsStealable()
	return false
end

function ta_trap:IsHiddenWhenStolen()
	return false
end

function ta_trap:OnUpgrade()
	local abil1 = self:GetCaster():FindAbilityByName("ta_trap_tp")
	local abil2 = self:GetCaster():FindAbilityByName("ta_trap_spring")

	if not abil1:IsTrained() then
		abil1:SetLevel(1)
	end

	if not abil2:IsTrained() then
		abil2:SetLevel(1)
	end
end

function ta_trap:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local max_traps = self:GetTalentSpecialValueFor("max_traps")
	
	self.traps = self.traps or {}
	
	-- Ensures there are fewer than the maximum traps
	if #self.traps > max_traps then
		local trap = self.traps[1]
		table.remove(self.traps, 1)
		trap:ForceKill(false)
	end
	local trap = CreateUnitByName("npc_dota_templar_assassin_psionic_trap", point, true, caster, nil, caster:GetTeam())
		
	self.traps[#self.traps+1] = trap
		
	-- Applies the modifier to the trap
	trap:AddNewModifier(caster, self, "modifier_ta_trap", {})
	
	trap:SetOwner(caster)
	trap:SetControllableByPlayer(caster:GetPlayerID(), true)
		
	caster:FindAbilityByName("ta_trap_spring"):UpgradeAbility(true)
	caster:FindAbilityByName("ta_trap_tp"):UpgradeAbility(true)
	
	-- Plays the sounds
	EmitSoundOn("Hero_TemplarAssassin.Trap.Cast", caster)
	EmitSoundOn("Hero_TemplarAssassin.Trap", trap)
		
	-- Renders the trap particle on the target position (it is not a model particle, so cannot be attached to the unit)
	trap.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf", PATTACH_POINT_FOLLOW, trap)
	ParticleManager:SetParticleControl(trap.particle, 0, point)
	ParticleManager:SetParticleControl(trap.particle, 1, point)
end

modifier_ta_trap = class({})

function modifier_ta_trap:OnCreated()
	self.minDmg = self:GetAbility():GetTalentSpecialValueFor("damage_min_tooltip")
	self.minSlow = self:GetAbility():GetTalentSpecialValueFor("movement_speed_min_tooltip")
	self.maxDmg = self:GetAbility():GetTalentSpecialValueFor("damage_max_tooltip")
	self.maxSlow = self:GetAbility():GetTalentSpecialValueFor("movement_speed_max_tooltip")

	if IsServer() then	
		self.timer = 0
		self.maxTimer = self:GetAbility():GetTalentSpecialValueFor("total_tick_time")
		self.tick = self:GetAbility():GetTalentSpecialValueFor("tick_rate")
		self.dmgPerTick = ( (self.maxDmg - self.minDmg) * self.tick ) / self.maxTimer
		self.slowPerTick = ( (self.maxSlow - self.minSlow) * self.tick ) / self.maxTimer
		if self:GetCaster():HasScepter() then
			self:GetParent().currDamage = self.maxDmg
		else
			self:GetParent().currDamage = self.minDmg
		end
		self:GetParent().currSlow = self.minSlow
		if self:GetParent().currDamage < self.maxDmg then
			self:StartIntervalThink(self.tick)
		end
	end
end

function modifier_ta_trap:OnIntervalThink()
	if self.timer < self.maxTimer then
		self.timer = self.timer + self.tick
		self:GetParent().currSlow = self:GetParent().currSlow + self.slowPerTick
		self:GetParent().currDamage = self:GetParent().currDamage + self.dmgPerTick
	else
		self:StartIntervalThink(-1)
	end
end

function modifier_ta_trap:OnDestroy()
	if IsServer() then
		if self:GetParent().particle then
			ParticleManager:DestroyParticle( self:GetParent().particle , true )
			ParticleManager:ReleaseParticleIndex( self:GetParent().particle )
		end
	end
end

function modifier_ta_trap:IsHidden()
	return true
end

function modifier_ta_trap:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		--[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return state
end

modifier_ta_trap_spring = class({})

function modifier_ta_trap_spring:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
			}
	return funcs
end

function modifier_ta_trap_spring:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()*(-1)
end

function modifier_ta_trap_spring:GetEffectName()
	return "particles/units/heroes/hero_templar_assassin/templar_assassin_trap_slow.vpcf"
end