shinigami_deep_wounds = class({})

function shinigami_deep_wounds:GetIntrinsicModifierName()
	return "modifier_shinigami_deep_wounds_passive"
end


modifier_shinigami_deep_wounds_passive = class({})
LinkLuaModifier("modifier_shinigami_deep_wounds_passive", "heroes/shinigami/shinigami_deep_wounds.lua", 0)

function modifier_shinigami_deep_wounds_passive:OnCreated()
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.damage_pct = self:GetAbility():GetSpecialValueFor("damage_pct") / 100
end

function modifier_shinigami_deep_wounds_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE,
			}
	return funcs
end

function modifier_shinigami_deep_wounds_passive:OnTakeDamage(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.inflictor ~= self:GetAbility() and params.damage > 0 and (not params.inflictor or self:GetParent():HasAbility(params.inflictor:GetName())) then
			local duration = self.duration
			if params.inflictor and self:GetParent():HasTalent("shinigami_deep_wounds_talent_1") then duration = duration + self:GetParent():FindTalentValue("shinigami_deep_wounds_talent_1") end
			params.unit:AddNewModifier(params.attacker, self:GetAbility(), "modifier_shinigami_deep_wounds_stacks", {duration = duration, damage = math.ceil((params.damage * self.damage_pct * 0.2) / self.duration)})
		end
	end
end

function modifier_shinigami_deep_wounds_passive:IsHidden()
	return true
end


modifier_shinigami_deep_wounds_stacks = class({})
LinkLuaModifier("modifier_shinigami_deep_wounds_stacks", "heroes/shinigami/shinigami_deep_wounds.lua", 0)

function modifier_shinigami_deep_wounds_stacks:OnCreated(kv)
	self.moveslow = self:GetAbility():GetSpecialValueFor("moveslow")
	self.turnslow = self:GetAbility():GetSpecialValueFor("turnslow")
	if IsServer() then
		self.expireTime = self:GetAbility():GetTalentSpecialValueFor("duration")
		self.deepWoundsTable = {}
		table.insert(self.deepWoundsTable, {insertTime = GameRules:GetGameTime(), damage = tonumber(kv.damage)})
		self:SetStackCount(1)
		self.woundFX = ParticleManager:CreateParticle("particles/heroes/shinigami/shinigami_deep_wounds_debuff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.woundFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.woundFX, 0, Vector(self:GetStackCount(),0,0))
		self:AddParticle(self.woundFX, false, false, 0, false, false)
		self:StartIntervalThink(0.2)
	end
end

function modifier_shinigami_deep_wounds_stacks:OnRefresh(kv)
	self.moveslow = self:GetAbility():GetSpecialValueFor("moveslow")
	self.turnslow = self:GetAbility():GetSpecialValueFor("turnslow")
	if IsServer() then
		table.insert(self.deepWoundsTable, {insertTime = GameRules:GetGameTime(), damage = tonumber(kv.damage)})
	end
end

function modifier_shinigami_deep_wounds_stacks:OnIntervalThink()
	local damage = 0
	if #self.deepWoundsTable > 0 then
		for i = #self.deepWoundsTable, 1, -1 do	
			if self.deepWoundsTable[i].insertTime + self.expireTime < GameRules:GetGameTime() then
				table.remove(self.deepWoundsTable, i)		
			else
				damage = damage + self.deepWoundsTable[i].damage
			end
		end
		self:SetStackCount(#self.deepWoundsTable)
		ParticleManager:SetParticleControl(self.woundFX, 1, Vector(self:GetStackCount(),0,0))
		if #self.deepWoundsTable == 0 then
			self:Destroy()
		end
	else
		self:Destroy()
	end
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
end

function modifier_shinigami_deep_wounds_stacks:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
				
			}
	return funcs
end

function modifier_shinigami_deep_wounds_stacks:GetModifierTurnRate_Percentage()
	return self:GetStackCount() * self.moveslow
end


function modifier_shinigami_deep_wounds_stacks:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * self.turnslow
end
