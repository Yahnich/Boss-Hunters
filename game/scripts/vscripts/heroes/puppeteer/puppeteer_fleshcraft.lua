puppeteer_fleshcraft = puppeteer_fleshcraft or class({})

function puppeteer_fleshcraft:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:IsSameTeam(caster) then
		target:AddNewModifier(caster, self, "modifier_puppeteer_fleshcraft_heal", {duration = self:GetSpecialValueFor("duration")})
		local healAmt = self:GetSpecialValueFor("base_heal") + target:GetMaxHealth() * self:GetSpecialValueFor("base_heal_pct") / 100
		target:HealEvent(healAmt, caster, {})
	else
		target:AddNewModifier(caster, self, "modifier_puppeteer_fleshcraft_damage", {duration = self:GetSpecialValueFor("duration")})
		local modifier = target:FindModifierByName("modifier_puppeteer_black_plague_stack")
		if modifier and modifier.plagueTable then
			for id, gameTime in pairs(modifier.plagueTable) do -- refresh all stacks
				modifier.plagueTable[id] = GameRules:GetGameTime()
			end
		end
		ApplyDamage({victim = target, attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
	end
	EmitSoundOn("DOTA_Item.UrnOfShadows.Activate", target)
	local fleshcraft = ParticleManager:CreateParticle("particles/heroes/puppeteer/puppeteer_fleshcraft.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(fleshcraft, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(fleshcraft, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(fleshcraft)
end

LinkLuaModifier("modifier_puppeteer_fleshcraft_heal", "heroes/puppeteer/puppeteer_fleshcraft.lua", 0)
modifier_puppeteer_fleshcraft_heal = class({})

function modifier_puppeteer_fleshcraft_heal:OnCreated()
	self.regen = self:GetAbility():GetSpecialValueFor("base_regen")
	self.pct_regen = self:GetAbility():GetSpecialValueFor("base_regen_pct")
	self.debuff_decrease = self:GetCaster():FindTalentValue("puppeteer_fleshcraft_talent_1")
	self.tickrate = 1 * (self:GetDuration() / self:GetAbility():GetSpecialValueFor("duration"))
	if IsServer() then
		self:StartIntervalThink( self.tickrate )
	end
end

function modifier_puppeteer_fleshcraft_heal:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local healAmt = (self:GetAbility():GetSpecialValueFor("base_regen") + target:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("base_regen_pct") / 100) * self.tickrate
	target:HealEvent(healAmt, caster, {})
end

function modifier_puppeteer_fleshcraft_heal:GetEffectName()
	return "particles/items2_fx/urn_of_shadows_heal.vpcf"
end

function modifier_puppeteer_fleshcraft_heal:BonusStatusEffectDuration_Constant()
	return self.debuff_decrease
end

LinkLuaModifier("modifier_puppeteer_fleshcraft_damage", "heroes/puppeteer/puppeteer_fleshcraft.lua", 0)
modifier_puppeteer_fleshcraft_damage = class({})

function modifier_puppeteer_fleshcraft_damage:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.dot = self:GetAbility():GetSpecialValueFor("damage_over_time")
	self.debuff_increase = self:GetCaster():FindTalentValue("puppeteer_fleshcraft_talent_1")
	self.tickrate = 1 * (self:GetDuration() / self:GetAbility():GetSpecialValueFor("duration"))
	if IsServer() then
		self:StartIntervalThink( self.tickrate )
	end
end

function modifier_puppeteer_fleshcraft_damage:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()
	ApplyDamage({victim = target, attacker = caster, damage = self:GetAbility():GetSpecialValueFor("damage_over_time"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
end

function modifier_puppeteer_fleshcraft_damage:GetEffectName()
	return "particles/items2_fx/urn_of_shadows_damage.vpcf"
end

function modifier_puppeteer_fleshcraft_damage:BonusStatusEffectDuration_Constant()
	return -self.debuff_increase
end
