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

modifier_item_lightningbottle_handle = class(itemBaseClass)
function modifier_item_lightningbottle_handle:OnCreated()
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.regen = self:GetSpecialValueFor("bonus_regen")
	self.status_amp = self:GetSpecialValueFor("status_amp")
	
	self.mRestore = self:GetSpecialValueFor("mana_restore")
	self.hRestore = self:GetSpecialValueFor("heal_restore")
	
	self.mRestoreL = self:GetSpecialValueFor("mana_restore_lightning")
	self.hRestoreL = self:GetSpecialValueFor("heal_restore_lightning")
end

function modifier_item_lightningbottle_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_lightningbottle_handle:DeclareFunctions()
	return {
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
		}
end

function modifier_item_lightningbottle_handle:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_lightningbottle_handle:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_item_lightningbottle_handle:GetModifierStatusAmplify_Percentage(params)
	return self.status_amp
end

function modifier_item_lightningbottle_handle:OnAbilityFullyCast(params)
	local caster = params.unit
	local ability = self:GetAbility()
	if params.unit == self:GetParent() and params.ability:GetCooldown(-1) > 0 then
		self:GetParent():GiveMana(self.mRestore)
		self:GetParent():HealEvent(self.hRestore, self:GetAbility(), self:GetParent())
		local paralyze = ability:GetSpecialValueFor("paralyze_duration")
		local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
		for _,enemy in pairs(enemies) do
			self:GetParent():GiveMana(self.mRestoreL)
			self:GetParent():HealEvent(self.hRestoreL, self:GetAbility(), self:GetParent())

			ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), enemy, {})
			self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("strike_damage"))
			
			enemy:Paralyze(ability, caster, paralyze)
		end
	end
end

function modifier_item_lightningbottle_handle:IsHidden()
	return true
end

modifier_item_lightningbottle_handle_shield = class({})
function modifier_item_lightningbottle_handle_shield:OnCreated()
	self.mRestoreS = self:GetSpecialValueFor("mana_restore_shield")
	self.hRestoreS = self:GetSpecialValueFor("heal_restore_shield")
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
			self:GetAbility():DealDamage(caster, attacker, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
			self:GetParent():GiveMana(self.mRestoreS)
			self:GetParent():HealEvent(self.hRestoreS, self:GetAbility(), self:GetParent())
			attacker:Paralyze(ability, caster, ability:GetSpecialValueFor("paralyze_duration"))
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