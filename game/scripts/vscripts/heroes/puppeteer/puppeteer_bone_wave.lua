puppeteer_bone_wave = class({})

function puppeteer_bone_wave:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_puppeteer_bone_wave", {duration = self:GetTalentSpecialValueFor("duration")})
	EmitSoundOn("Hero_Undying.Tombstone", caster)
end

LinkLuaModifier("modifier_puppeteer_bone_wave", "heroes/puppeteer/puppeteer_bone_wave.lua", 0)
modifier_puppeteer_bone_wave = class({})

function modifier_puppeteer_bone_wave:OnCreated()
	self.speed = self:GetAbility():GetTalentSpecialValueFor("bonus_ms")
	self.damage = self:GetAbility():GetTalentSpecialValueFor("effect_damage")
	self.radius = self:GetAbility():GetTalentSpecialValueFor("effect_radius")
	self.duration = self:GetAbility():GetTalentSpecialValueFor("stun_duration")
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_puppeteer_bone_wave:OnRefresh()
	self.speed = self:GetAbility():GetTalentSpecialValueFor("bonus_ms")
	self.damage = self:GetAbility():GetTalentSpecialValueFor("effect_damage")
	self.radius = self:GetAbility():GetTalentSpecialValueFor("effect_radius")
	self.duration = self:GetAbility():GetTalentSpecialValueFor("stun_duration")
end

function modifier_puppeteer_bone_wave:OnIntervalThink()
	local caster = self:GetCaster()
	local enemies = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  self.radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
	if RollPercentage(40) then
		local int = RandomInt(1,3)
		if int == 1 then
			EmitSoundOn("ui.inv_drop_bone", caster)
		elseif int == 2 then
			EmitSoundOn("ui.inv_equip_bone", caster)
		else
			EmitSoundOn("ui.inv_pickup_bone", caster)
		end
	end
	for _,enemy in pairs(enemies) do
		if not enemy.hitByBoneWave then
			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_stunned_generic", {duration = self.duration})
			enemy.hitByBoneWave = true
			Timers:CreateTimer(self.duration * 1.5, function()
				enemy.hitByBoneWave = false
			end)
			ApplyDamage({victim = enemy, attacker = caster, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
			if caster:HasTalent("puppeteer_bone_wave_talent_1") then
				local skellington = caster:CreateSummon("npc_dota_puppeteer_skeleton_skirmisher", enemy:GetAbsOrigin(), 5 )
				skellington:FindAbilityByName("skeleton_skirmisher_magic_conversion"):SetLevel(self:GetAbility():GetLevel())
				skellington:SetControllableByPlayer(-1, true)
				local currPos = skellington:GetAbsOrigin()
				local distanceTravelled = 0
				local existenceTime = 0
				local distance = 500
				local runDir = CalculateDirection(enemy, skellington)
				Timers:CreateTimer(0.2, function()
					skellington:MoveToPositionAggressive(currPos + distance * runDir)
				end)
				Timers:CreateTimer(0.1, function()
					distanceTravelled = distanceTravelled + CalculateDistance(currPos, skellington:GetAbsOrigin())
					existenceTime = existenceTime + 0.1
					currPos = skellington:GetAbsOrigin()
					if distanceTravelled >= distance or existenceTime > 5 then
						skellington:ForceKill(true)
					else
						return 0.1
					end
				end)
			end
		end
	end
end

function modifier_puppeteer_bone_wave:CheckState()
	local state = {[MODIFIER_STATE_FLYING] = true}
	return state
end

function modifier_puppeteer_bone_wave:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_MAX
	}
	return funcs
end

function modifier_puppeteer_bone_wave:GetModifierMoveSpeedBonus_Constant()
	return self.speed
end

function modifier_puppeteer_bone_wave:GetModifierMoveSpeed_Limit()
	return 550 + self.speed
end

function modifier_puppeteer_bone_wave:GetModifierMoveSpeed_Max()
	return 550 + self.speed
end

function modifier_puppeteer_bone_wave:GetEffectName()
	return "particles/heroes/puppeteer/puppeteer_bone_wave.vpcf"
end