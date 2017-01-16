templar_assassin_psionic_trap_ebf = class({})

if IsServer() then
	function templar_assassin_psionic_trap_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local max_traps = self:GetSpecialValueFor("max_traps")
		
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
		trap:AddNewModifier(caster, self, "templar_assassin_psionic_trap_ebf_handler", {})
		
		trap:SetOwner(caster)
		trap:SetControllableByPlayer(caster:GetPlayerID(), true)
			
		trap:FindAbilityByName("self_trap_ebf"):UpgradeAbility(true)
		trap:FindAbilityByName("self_traptp_ebf"):UpgradeAbility(true)
		
		-- Plays the sounds
		EmitSoundOn("Hero_TemplarAssassin.Trap.Cast", caster)
		EmitSoundOn("Hero_TemplarAssassin.Trap", trap)
			
		-- Renders the trap particle on the target position (it is not a model particle, so cannot be attached to the unit)
		trap.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap.vpcf", PATTACH_POINT_FOLLOW, trap)
		ParticleManager:SetParticleControl(trap.particle, 0, point)
		ParticleManager:SetParticleControl(trap.particle, 1, point)
	end
end

LinkLuaModifier( "templar_assassin_psionic_trap_ebf_handler", "lua_abilities/heroes/templar_assassin.lua" ,LUA_MODIFIER_MOTION_NONE )
templar_assassin_psionic_trap_ebf_handler = class({})

function templar_assassin_psionic_trap_ebf_handler:OnCreated()
	self.minDmg = self:GetAbility():GetSpecialValueFor("damage_min_tooltip")
	self.minSlow = self:GetAbility():GetSpecialValueFor("movement_speed_min_tooltip")
	self.maxDmg = self:GetAbility():GetSpecialValueFor("damage_max_tooltip")
	self.maxSlow = self:GetAbility():GetSpecialValueFor("movement_speed_max_tooltip")
	if IsServer() then	
		self.timer = 0
		self.maxTimer = self:GetAbility():GetSpecialValueFor("total_tick_time")
		self.tick = self:GetAbility():GetSpecialValueFor("tick_rate")
		self.dmgPerTick = (self.maxDmg - self.minDmg) / self.maxTimer
		self.slowPerTick = (self.maxSlow - self.minSlow) / self.maxTimer
		self:GetParent().currDamage = self.minDmg
		self:GetParent().currSlow = self.minSlow
		self:StartIntervalThink(self.tick)
	end
end

function templar_assassin_psionic_trap_ebf_handler:OnIntervalThink()
	if self.timer < self.maxTimer then
		self.timer = self.timer + self.tick
		self:GetParent().currSlow = self:GetParent().currSlow + self.slowPerTick
		self:GetParent().currDamage = self:GetParent().currDamage + self.dmgPerTick
	else
		self:StartIntervalThink(-1)
	end
end

function templar_assassin_psionic_trap_ebf_handler:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle( self:GetParent().particle , true )
		ParticleManager:ReleaseParticleIndex( self:GetParent().particle )
	end
end

function templar_assassin_psionic_trap_ebf_handler:IsHidden()
	return true
end

function templar_assassin_psionic_trap_ebf_handler:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return state
end

templar_assassin_trap_ebf = class({})

if IsServer() then
	function templar_assassin_trap_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local trapAbility = caster:FindAbilityByName("templar_assassin_psionic_trap_ebf")
		local trap
		local closest = 100000
		if #trapAbility.traps > 0 then
			for _,tableTrap in pairs(trapAbility.traps) do
				local distance = (point - tableTrap:GetAbsOrigin()):Length2D()
			
				-- Notes the closest distance and closest trap
				if distance < closest then
					closest = distance
					trap = tableTrap
				end
			end
		end
		if trap then
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_WORLDORIGIN, trap)
				ParticleManager:SetParticleControl(particle, 0, trap:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, trap:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 2, trap:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex( particle )
			EmitSoundOn("Hero_TemplarAssassin.Trap.Trigger", caster)
			EmitSoundOn("Hero_TemplarAssassin.Trap.Explode", trap)
			local trap_radius = self:GetSpecialValueFor("trap_radius")
			local trap_duration = self:GetSpecialValueFor("trap_duration")
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), trap:GetAbsOrigin(), nil, trap_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			for _, enemy in pairs(enemies) do
				local slow = enemy:AddNewModifier(caster, trapAbility, "templar_assassin_psionic_trap_dynamic_slow", {duration = trap_duration})
				slow:SetStackCount(trap.currSlow)
				ApplyDamage({victim = enemy, attacker = caster, damage = trap.currDamage, damage_type = DAMAGE_TYPE_MAGICAL, ability = trapAbility})
			end
			trap:ForceKill(false)
			for index,tableTrap in pairs(trapAbility.traps) do
				if trap == tableTrap then
					table.remove(trapAbility.traps,index)
				end
			end
		end
	end
end

templar_assassin_traptp_ebf = class({})

if IsServer() then
	function templar_assassin_traptp_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local trapAbility = caster:FindAbilityByName("templar_assassin_psionic_trap_ebf")
		local trap
		local closest = 100000
		if #trapAbility.traps > 0 then
			for _,tableTrap in pairs(trapAbility.traps) do
				local distance = (point - tableTrap:GetAbsOrigin()):Length2D()
			
				-- Notes the closest distance and closest trap
				if distance < closest then
					closest = distance
					trap = tableTrap
				end
			end
		end
		if trap then
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_WORLDORIGIN, trap)
				ParticleManager:SetParticleControl(particle, 0, trap:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 1, trap:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle, 2, trap:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex( particle )
			local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(particle2, 0, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle2, 1, caster:GetAbsOrigin())
				ParticleManager:SetParticleControl(particle2, 2, caster:GetAbsOrigin())
			FindClearSpaceForUnit(caster, trap:GetAbsOrigin(), false)
			ProjectileManager:ProjectileDodge(caster)
			ParticleManager:ReleaseParticleIndex( particle2 )
			EmitSoundOn("Hero_TemplarAssassin.Trap.Trigger", caster)
			EmitSoundOn("Hero_TemplarAssassin.Trap.Explode", trap)
			local trap_radius = self:GetSpecialValueFor("trap_radius")
			local trap_duration = self:GetSpecialValueFor("trap_duration")
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), trap:GetAbsOrigin(), nil, trap_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			for _, enemy in pairs(enemies) do
				local slow = enemy:AddNewModifier(caster, trapAbility, "templar_assassin_psionic_trap_dynamic_slow", {duration = trap_duration})
				slow:SetStackCount(trap.currSlow)
				ApplyDamage({victim = enemy, attacker = caster, damage = trap.currDamage, damage_type = DAMAGE_TYPE_MAGICAL, ability = trapAbility})
			end
			trap:ForceKill(false)
			for index,tableTrap in pairs(trapAbility.traps) do
				if trap == tableTrap then
					table.remove(trapAbility.traps,index)
				end
			end
		end
	end
end

self_trap_ebf = class({})

if IsServer() then
	function self_trap_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local owner = caster:GetOwnerEntity()
		local trapAbility = owner:FindAbilityByName("templar_assassin_psionic_trap_ebf")
	
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_WORLDORIGIN, owner)
			ParticleManager:SetParticleControl(particle, 0, owner:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, owner:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 2, owner:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex( particle )
		
		EmitSoundOn("Hero_TemplarAssassin.Trap.Trigger", owner)
		EmitSoundOn("Hero_TemplarAssassin.Trap.Explode", caster)
		
		local trap_radius = self:GetSpecialValueFor("trap_radius")
		local trap_duration = self:GetSpecialValueFor("trap_duration")
		local enemies = FindUnitsInRadius(owner:GetTeamNumber(), caster:GetAbsOrigin(), nil, trap_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _, enemy in pairs(enemies) do
			local slow = enemy:AddNewModifier(owner, trapAbility, "templar_assassin_psionic_trap_dynamic_slow", {duration = trap_duration})
			slow:SetStackCount(caster.currSlow)
			ApplyDamage({victim = enemy, attacker = owner, damage = caster.currDamage, damage_type = DAMAGE_TYPE_MAGICAL, ability = trapAbility})
		end
		caster:ForceKill(false)
		for index,tableTrap in pairs(trapAbility.traps) do
			if caster == tableTrap then
				table.remove(trapAbility.traps,index)
			end
		end
	end
end


self_traptp_ebf = class({})

if IsServer() then
	function self_traptp_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local owner = caster:GetOwnerEntity()
		local trapAbility = owner:FindAbilityByName("templar_assassin_psionic_trap_ebf")
		
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_WORLDORIGIN, owner)
			ParticleManager:SetParticleControl(particle, 0, owner:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, owner:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 2, owner:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex( particle )
		
		local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_explode.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(particle2, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle2, 1, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle2, 2, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex( particle2 )
		
		FindClearSpaceForUnit(caster, trap:GetAbsOrigin(), false)
		ProjectileManager:ProjectileDodge(caster)
		
		EmitSoundOn("Hero_TemplarAssassin.Trap.Trigger", owner)
		EmitSoundOn("Hero_TemplarAssassin.Trap.Explode", caster)
		
		local trap_radius = self:GetSpecialValueFor("trap_radius")
		local trap_duration = self:GetSpecialValueFor("trap_duration")
		local enemies = FindUnitsInRadius(owner:GetTeamNumber(), caster:GetAbsOrigin(), nil, trap_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _, enemy in pairs(enemies) do
			local slow = enemy:AddNewModifier(owner, trapAbility, "templar_assassin_psionic_trap_dynamic_slow", {duration = trap_duration})
			slow:SetStackCount(caster.currSlow)
			ApplyDamage({victim = enemy, attacker = owner, damage = caster.currDamage, damage_type = DAMAGE_TYPE_MAGICAL, ability = trapAbility})
		end
		caster:ForceKill(false)
		caster:ForceKill(false)
		for index,tableTrap in pairs(trapAbility.traps) do
			if caster == tableTrap then
				table.remove(trapAbility.traps,index)
			end
		end
	end
end

LinkLuaModifier( "templar_assassin_psionic_trap_dynamic_slow", "lua_abilities/heroes/templar_assassin.lua" ,LUA_MODIFIER_MOTION_NONE )
templar_assassin_psionic_trap_dynamic_slow = class({})

function templar_assassin_psionic_trap_dynamic_slow:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			}
	return funcs
end

function templar_assassin_psionic_trap_dynamic_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()*(-1)
end

function templar_assassin_psionic_trap_dynamic_slow:GetEffectName()
	return "particles/units/heroes/hero_templar_assassin/templar_assassin_trap_slow.vpcf"
end