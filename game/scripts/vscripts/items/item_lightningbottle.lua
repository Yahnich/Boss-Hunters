item_lightningbottle = class({})
LinkLuaModifier( "modifier_item_lightningbottle_handle", "items/item_lightningbottle.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_lightningbottle_handle_shield", "items/item_lightningbottle.lua", LUA_MODIFIER_MOTION_NONE )

function item_lightningbottle:GetIntrinsicModifierName()
	return "modifier_item_lightningbottle_handle"
end

function item_lightningbottle:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("DOTA_Item.Mjollnir.Activate", target)
	target:AddNewModifier(caster, self, "modifier_item_lightningbottle_handle_shield", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_item_lightningbottle_handle = class({})
function modifier_item_lightningbottle_handle:OnCreated()
	self.attackspeed = self:GetSpecialValueFor("bonus_attack_speed")
	self.reduction = self:GetSpecialValueFor("cd_reduction")
	self.reductionSpell = self:GetSpecialValueFor("cd_reduction_spell")
	self.cdr = self:GetSpecialValueFor("cdr")
end

function modifier_item_lightningbottle_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_lightningbottle_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
		}
end

function modifier_item_lightningbottle_handle:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_item_lightningbottle_handle:GetCooldownReduction(params)
	return self.cdr
end

function modifier_item_lightningbottle_handle:OnAbilityFullyCast(params)
	local caster = params.unit
	if params.ability and params.ability:GetCooldown(-1) > 0.75 and params.unit == self:GetParent() then
		if not caster:HasModifier("modifier_item_orb_of_renewal_passive") then
			for i = 0, params.unit:GetAbilityCount() - 1 do
				local ability = params.unit:GetAbilityByIndex( i )
				if ability then
					ability:ModifyCooldown(self.reduction)
				end
			end

			for i=0, 5, 1 do
				local current_item = params.unit:GetItemInSlot(i)
				if current_item ~= nil and current_item ~= self:GetAbility() then
					current_item:ModifyCooldown(self.reduction)
				end
			end
		end

		local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
		for _,enemy in pairs(enemies) do

			for i = 0, params.unit:GetAbilityCount() - 1 do
				local ability = params.unit:GetAbilityByIndex( i )
				if ability then
					ability:ModifyCooldown(self.reductionSpell)
				end
			end

			for i=0, 5, 1 do
				local current_item = params.unit:GetItemInSlot(i)
				if current_item ~= nil and current_item ~= self:GetAbility() then
					current_item:ModifyCooldown(self.reductionSpell)
				end
			end

			ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), enemy, {})
			self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("strike_damage"))
		end
	end
end

function modifier_item_lightningbottle_handle:IsHidden()
	return true
end

modifier_item_lightningbottle_handle_shield = class({})
function modifier_item_lightningbottle_handle_shield:OnCreated()
	self.reductionShield = self:GetSpecialValueFor("cd_reduction_shield")
end

function modifier_item_lightningbottle_handle_shield:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_lightningbottle_handle_shield:OnTakeDamage(params)
	if IsServer() then
		local caster = params.unit
		local attacker = params.attacker
		if caster == self:GetParent() and attacker:IsAlive() and RollPercentage(self:GetSpecialValueFor("strike_chance")) then
			local ability = self:GetAbility()

			if caster:IsIllusion() then return end

			ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, attacker, caster, {})

			local damage = caster:GetPrimaryStatValue() * self:GetSpecialValueFor("primary_to_damage") / 100

			self:GetAbility():DealDamage(caster, attacker, damage)

			for i = 0, params.unit:GetAbilityCount() - 1 do
				local ability = params.unit:GetAbilityByIndex( i )
				if ability then
					ability:ModifyCooldown(self.reductionShield)
				end
			end
			
			for i=0, 5, 1 do
				local current_item = params.unit:GetItemInSlot(i)
				if current_item ~= nil and current_item ~= self:GetAbility() then
					current_item:ModifyCooldown(self.reductionShield)
				end
			end
		end
	end
end

function modifier_item_lightningbottle_handle_shield:GetEffectName()
	return "particles/items2_fx/mjollnir_shield.vpcf"
end

function modifier_item_lightningbottle_handle_shield:IsDebuff()
	return false
end

function modifier_item_lightningbottle_handle_shield:GetTexture()
	return "bottle_doubledamage"
end