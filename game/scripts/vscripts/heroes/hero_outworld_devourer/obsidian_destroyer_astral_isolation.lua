obsidian_destroyer_astral_isolation = class({})

function obsidian_destroyer_astral_isolation:OnSpellStart()
	if IsServer() then
		local hTarget = self:GetCursorTarget()
		EmitSoundOn("Hero_ObsidianDestroyer.AstralImprisonment.Cast", self:GetCaster())
		local flash = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_start.vpcf", PATTACH_ABSORIGIN , hTarget)
			ParticleManager:SetParticleControl(flash, 0, hTarget:GetAbsOrigin())
			ParticleManager:SetParticleControl(flash, 1, hTarget:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(flash)
		if hTarget:GetTeam() == self:GetCaster():GetTeam() then
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_obsidian_destroyer_astral_isolation_prison", {duration = self:GetTalentSpecialValueFor("prison_duration")})
		else
			local modifier = self:GetCaster():AddNewModifier(self:GetCaster(), self,"modifier_obsidian_destroyer_astral_isolation_int_gain", {duration = self:GetTalentSpecialValueFor("steal_duration")})
			modifier:IncrementStackCount()
			local endFlash = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_end.vpcf", PATTACH_ABSORIGIN , hTarget)
				ParticleManager:SetParticleControl(endFlash, 0, hTarget:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(endFlash)
			EmitSoundOn("Hero_ObsidianDestroyer.AstralImprisonment.End", hTarget)
			hTarget:AddNewModifier(self:GetCaster(), self,"modifier_stunned", {duration = self:GetTalentSpecialValueFor("prison_duration") / 2})
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hTarget:GetAbsOrigin(), nil, self:GetTalentSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			for _,enemy in pairs(enemies) do
				ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self:GetTalentSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
			end
		end
	end
end

LinkLuaModifier( "modifier_obsidian_destroyer_astral_isolation_int_gain", "lua_abilities/heroes/obsidian_destroyer.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_obsidian_destroyer_astral_isolation_int_gain = class({})

function modifier_obsidian_destroyer_astral_isolation_int_gain:OnCreated()
	self.intgain = self:GetAbility():GetTalentSpecialValueFor("int_gain")
	if IsServer() then
		self.buff = ParticleManager:CreateParticle("particles/obsidian_imprisonment_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW , self:GetParent())
			ParticleManager:SetParticleControl(self.buff, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(self.buff, 12, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		self.expireTime = self:GetAbility():GetTalentSpecialValueFor("steal_duration")
		self.intTable = {}
		table.insert(self.intTable, GameRules:GetGameTime())
		self:StartIntervalThink(0.1)
	end
end

function modifier_obsidian_destroyer_astral_isolation_int_gain:OnRefresh()
	self.intgain = self:GetAbility():GetTalentSpecialValueFor("int_gain")
	if IsServer() then
		table.insert(self.intTable, GameRules:GetGameTime())
	end
end

function modifier_obsidian_destroyer_astral_isolation_int_gain:OnIntervalThink()
	if #self.intTable > 0 then
		for i = #self.intTable, 1, -1 do
			if self.intTable[i] + self.expireTime < GameRules:GetGameTime() then
				table.remove(self.intTable, i)		
			end
		end
		self:SetStackCount(#self.intTable)
		if #self.intTable == 0 then
			self:Destroy()
		end
		self:GetParent():CalculateStatBonus()
	else
		self:Destroy()
	end
end

function modifier_obsidian_destroyer_astral_isolation_int_gain:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.buff, false)
		ParticleManager:ReleaseParticleIndex(self.buff)
	end
end

function modifier_obsidian_destroyer_astral_isolation_int_gain:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
			}
	return funcs
end

function modifier_obsidian_destroyer_astral_isolation_int_gain:GetModifierBonusStats_Intellect()
	return self.intgain * self:GetStackCount()
end

LinkLuaModifier( "modifier_obsidian_destroyer_astral_isolation_prison", "lua_abilities/heroes/obsidian_destroyer.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_obsidian_destroyer_astral_isolation_prison = class({})

function modifier_obsidian_destroyer_astral_isolation_prison:OnCreated()
	if IsServer() then
		EmitSoundOn("Hero_ObsidianDestroyer.AstralImprisonment", hTarget)
	end
end

function modifier_obsidian_destroyer_astral_isolation_prison:OnDestroy()
	if IsServer() then
		local endFlash = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison_end.vpcf", PATTACH_ABSORIGIN , hTarget)
				ParticleManager:SetParticleControl(endFlash, 0, hTarget:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(endFlash)
		EmitSoundOn("Hero_ObsidianDestroyer.AstralImprisonment.End", hTarget)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hTarget:GetAbsOrigin(), nil, self:GetTalentSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _,enemy in pairs(enemies) do
			ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self:GetTalentSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
		end
	end
end

function modifier_obsidian_destroyer_astral_isolation_prison:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true
	}
	return state
end

function modifier_obsidian_destroyer_astral_isolation_prison:GetEffectName()
	return "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison.vpcf"
end