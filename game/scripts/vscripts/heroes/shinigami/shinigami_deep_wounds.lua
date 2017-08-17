shinigami_deep_wounds = class({})

function shinigami_deep_wounds:GetIntrinsicModifierName()
	return "modifier_shinigami_deep_wounds_passive"
end


modifier_shinigami_deep_wounds_passive = class({})
LinkLuaModifier("modifier_shinigami_deep_wounds_passive", "heroes/shinigami/shinigami_deep_wounds.lua", 0)

function modifier_shinigami_deep_wounds_passive:OnCreated()
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.damage_pct = self:GetAbility():GetSpecialValueFor("damage_pct") / 100
	self.damage_amp = self:GetAbility():GetSpecialValueFor("scepter_damage_amp")
end

function modifier_shinigami_deep_wounds_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE,
				MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			}
	return funcs
end

function modifier_shinigami_deep_wounds_passive:GetModifierTotalDamageOutgoing_Percentage(params)
	if IsServer() and self:GetParent():HasScepter() then	
		if params.attacker == self:GetParent() and self:GetParent():IsAtAngleWithEntity(params.target, 90) then
			return self.damage_amp
		end
	end
end

function modifier_shinigami_deep_wounds_passive:OnTakeDamage(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.inflictor ~= self:GetAbility() and params.damage > 0 and (not params.inflictor or self:GetParent():HasAbility(params.inflictor:GetName())) then
			local duration = self.duration
			if (params.inflictor or self:GetParent().autoAttackFromAbilityState) and self:GetParent():HasTalent("shinigami_deep_wounds_talent_1") then duration = duration + self:GetParent():FindTalentValue("shinigami_deep_wounds_talent_1") end
			params.unit:AddNewModifier(params.attacker, self:GetAbility(), "modifier_shinigami_deep_wounds_stacks", {duration = duration, damage = math.ceil(params.damage * self.damage_pct)})
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
	self.burstHP = self:GetAbility():GetSpecialValueFor("burst_threshold") / 100		
	self.internalTime = 0
	if IsServer() then
		self.owner = self:GetCaster():GetOwner():GetAssignedHero()
		local expireTime = tonumber(kv.duration)
		self.deepWoundsTable = {}
		table.insert(self.deepWoundsTable, {insertTime = GameRules:GetGameTime(), damage = tonumber(kv.damage), expireTime = GameRules:GetGameTime() + expireTime})
		self:SetStackCount(1)
		self.woundFX = ParticleManager:CreateParticle("particles/heroes/shinigami/shinigami_deep_wounds_debuff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.woundFX, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.woundFX, 0, Vector(self:GetStackCount(),0,0))
		self:AddParticle(self.woundFX, false, false, 0, false, false)
		ParticleManager:ReleaseParticleIndex(self.woundFX)
		self:StartIntervalThink(0.1)
	end
end

function modifier_shinigami_deep_wounds_stacks:OnRefresh(kv)
	self.moveslow = self:GetAbility():GetSpecialValueFor("moveslow")
	self.turnslow = self:GetAbility():GetSpecialValueFor("turnslow")
	self.burstHP = self:GetAbility():GetSpecialValueFor("burst_threshold") / 100
	if IsServer() then
		local expireTime = tonumber(kv.duration)
		table.insert(self.deepWoundsTable, {insertTime = GameRules:GetGameTime(), damage = tonumber(kv.damage), expireTime = GameRules:GetGameTime() + expireTime})
	end
end

function modifier_shinigami_deep_wounds_stacks:OnIntervalThink()
	self.internalTime = self.internalTime + 0.1
	local damage = 0
	local potDamage = 0
	if #self.deepWoundsTable > 0 then
		for i = #self.deepWoundsTable, 1, -1 do	
			if self.deepWoundsTable[i].expireTime < GameRules:GetGameTime() then
				table.remove(self.deepWoundsTable, i)		
			else
				damage = damage + self.deepWoundsTable[i].damage
				potDamage = potDamage + (self.deepWoundsTable[i].damage * (self.deepWoundsTable[i].expireTime - GameRules:GetGameTime()))
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
	if self.internalTime >= 1 then
		self.internalTime = 0		
		if potDamage > self:GetParent():GetMaxHealth() * self.burstHP then		
			EmitSoundOn("Ability.SandKing_CausticFinale", self:GetParent())		
			local boomFX = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())		
			ParticleManager:ReleaseParticleIndex(boomFX)		
			ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster() or self.owner, damage = potDamage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})		
			self:Destroy()		
		else		
			ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster() or self.owner, damage = damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})		
		end		
	end
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
