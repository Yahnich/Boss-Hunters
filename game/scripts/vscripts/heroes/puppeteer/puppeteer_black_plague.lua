puppeteer_black_plague = puppeteer_black_plague or class({})

function puppeteer_black_plague:GetIntrinsicModifierName()
	return "modifier_puppeteer_black_plague_passive"
end

LinkLuaModifier("modifier_puppeteer_black_plague_passive", "heroes/puppeteer/puppeteer_black_plague.lua", LUA_MODIFIER_MOTION_NONE)
modifier_puppeteer_black_plague_passive = class({})

function modifier_puppeteer_black_plague_passive:OnCreated()
	self.stack_duration = self:GetAbility():GetTalentSpecialValueFor("duration")
	self.radius = self:GetAbility():GetTalentSpecialValueFor("radius")
end

function modifier_puppeteer_black_plague_passive:IsPurgable()
	return false
end

function modifier_puppeteer_black_plague_passive:IsHidden()
	return true
end

function modifier_puppeteer_black_plague_passive:IsPassive()
	return true
end

function modifier_puppeteer_black_plague_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ABILITY_EXECUTED,
			}
	return funcs
end

function modifier_puppeteer_black_plague_passive:OnAbilityExecuted(params)
	local parent = self:GetParent()
	if params.unit == parent and parent:HasAbility( params.ability:GetName() ) then
		self:CreatePlague(parent)
		parent.summonTable = parent.summonTable or {}
		for _,summon in pairs(parent.summonTable) do
			self:CreatePlague(summon)
		end
	end
end

function modifier_puppeteer_black_plague_passive:CreatePlague(entity)

	-- particle
	local plague = ParticleManager:CreateParticle("particles/heroes/puppeteer/puppeteer_black_plague.vpcf", PATTACH_POINT_FOLLOW, entity)
	ParticleManager:SetParticleControlEnt(plague, 0, entity, PATTACH_POINT_FOLLOW, "attach_hitloc", entity:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(plague)
	
	-- Apply plague
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), entity:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_puppeteer_black_plague_stack", {duration = self.stack_duration})
	end
end


LinkLuaModifier("modifier_puppeteer_black_plague_stack", "heroes/puppeteer/puppeteer_black_plague.lua", LUA_MODIFIER_MOTION_NONE)
modifier_puppeteer_black_plague_stack = class({})


function modifier_puppeteer_black_plague_stack:OnCreated()
	self.damage_pct = self:GetAbility():GetSpecialValueFor("int_damage_pct") / 100
	self.spread_radius = self:GetAbility():GetTalentSpecialValueFor("spread_radius")
	self.stack_duration = self:GetAbility():GetTalentSpecialValueFor("duration")
	self.reduction = self:GetAbility():GetTalentSpecialValueFor("scepter_reduction")
	self.transfer_rate = self:GetAbility():GetTalentSpecialValueFor("transfer_rate") or 1
	
	if IsServer() then
		self.expireTime = self:GetAbility():GetTalentSpecialValueFor("duration")
		self.plagueTable = {}
		table.insert(self.plagueTable, GameRules:GetGameTime())
		self:StartIntervalThink(0.1)
	end
end

function modifier_puppeteer_black_plague_stack:OnRefresh()
	self.damage_pct = self:GetAbility():GetSpecialValueFor("int_damage_pct") / 100
	self.spread_radius = self:GetAbility():GetTalentSpecialValueFor("spread_radius")
	self.stack_duration = self:GetAbility():GetTalentSpecialValueFor("duration")
	self.reduction = self:GetAbility():GetTalentSpecialValueFor("scepter_reduction")
	self.transfer_rate = self:GetAbility():GetTalentSpecialValueFor("transfer_rate") or 1

	if IsServer() then
		table.insert(self.plagueTable, GameRules:GetGameTime())
	end
end

function modifier_puppeteer_black_plague_stack:OnIntervalThink()
	if #self.plagueTable > 0 then
		for i = #self.plagueTable, 1, -1 do
			if self.plagueTable[i] + self.expireTime < GameRules:GetGameTime() then
				table.remove(self.plagueTable, i)		
			end
		end
		self:SetStackCount(#self.plagueTable)
		if #self.plagueTable == 0 then
			self:Destroy()
		end
	else
		self:Destroy()
	end
	self.internalTimer = (self.internalTimer or 0) + 0.1
	if self.internalTimer >= 0.2 then
		ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self:GetStackCount() * self:GetCaster():GetIntellect() * self.damage_pct, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self.spread_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _, enemy in pairs(enemies) do
			local modifier = enemy:FindModifierByName("modifier_puppeteer_black_plague_stack")
			if not modifier or modifier:GetStackCount() < self:GetStackCount() then
				if not modifier and self:GetCaster():HasTalent("puppeteer_black_plague_talent_1") then
					for id, gameTime in pairs(self.plagueTable) do -- refresh all stacks
						self.plagueTable[id] = GameRules:GetGameTime()
					end
				end
				for i = 1, self.transfer_rate do
					enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_puppeteer_black_plague_stack", {duration = self.stack_duration})
				end
			end
			break -- only one enemy spreads per second
		end
		self.internalTimer = self.internalTimer - 1
	end
end


function modifier_puppeteer_black_plague_stack:GetModifierTotalDamageOutgoing_Percentage()
	return self.reduction
end


function modifier_puppeteer_black_plague_stack:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			}
	return funcs
end


function modifier_puppeteer_black_plague_stack:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_poison_debuff.vpcf"
end