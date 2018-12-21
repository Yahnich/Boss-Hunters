--Thanks Dota Imba
tiny_grow_bh = class({})
LinkLuaModifier("modifier_tiny_grow_bh", "heroes/hero_tiny/tiny_grow_bh", LUA_MODIFIER_MOTION_NONE)

function tiny_grow_bh:IsStealable()
    return false
end

function tiny_grow_bh:GetIntrinsicModifierName()
	return "modifier_tiny_grow_bh"
end

function tiny_grow_bh:OnUpgrade()
	if IsServer() then
		local level = self:GetLevel()
		if level == 1 then -- model bullshit
			self:Grow(2)
		elseif level == 2 then
			self:GetCaster():SetModelScale(1.1)
		elseif level == 3 then
			self:GetCaster():SetModelScale(1.0)
			self:Grow(3)
		elseif level == 4 then
			self:GetCaster():SetModelScale(1.2)
		elseif level == 5 then
			self:GetCaster():SetModelScale(1.1)
			self:Grow(4)
		elseif level == 6 then
			self:GetCaster():SetModelScale(1.3)
		end
		-- Effects
		self:GetCaster():StartGesture(ACT_TINY_GROWL)
		EmitSoundOn("Tiny.Grow", self:GetCaster())
		
		local grow = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_transform.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster()) 
		ParticleManager:SetParticleControl(grow, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(grow)
	end
end

function tiny_grow_bh:Grow(level)
	self:GetCaster():SetOriginalModel("models/heroes/tiny_0"..level.."/tiny_0"..level..".vmdl")
	self:GetCaster():SetModel("models/heroes/tiny_0"..level.."/tiny_0"..level..".vmdl")
	-- Remove old wearables
	UTIL_Remove(self.head)
	UTIL_Remove(self.rarm)
	UTIL_Remove(self.larm)
	UTIL_Remove(self.body)
	-- Set new wearables
	self.head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_0"..level.."/tiny_0"..level.."_head.vmdl"})
	self.rarm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_0"..level.."/tiny_0"..level.."_right_arm.vmdl"})
	self.larm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_0"..level.."/tiny_0"..level.."_left_arm.vmdl"})
	self.body = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_0"..level.."/tiny_0"..level.."_body.vmdl"})
	-- lock to bone
	self.head:FollowEntity(self:GetCaster(), true)
	self.rarm:FollowEntity(self:GetCaster(), true)
	self.larm:FollowEntity(self:GetCaster(), true)
	self.body:FollowEntity(self:GetCaster(), true)
end

modifier_tiny_grow_bh = class({})
function modifier_tiny_grow_bh:OnCreated(table)
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.status_resistance = self:GetSpecialValueFor("status_resistance")
	self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
	self.attack_speed_reduction = self:GetSpecialValueFor("attack_speed_reduction")
	if self:GetCaster():HasTalent("special_bonus_unique_tiny_grow_bh_1") then
		self.attack_speed_reduction = 0
	end
	self.bonus_attack_range = self:GetSpecialValueFor("bonus_attack_range")

	self.magic_resist = 0
	if self:GetCaster():HasTalent("special_bonus_unique_tiny_grow_bh_2") then
		self.magic_resist = self:GetCaster():FindTalentValue("special_bonus_unique_tiny_grow_bh_2")
	end

	self:StartIntervalThink(0.5)
end

function modifier_tiny_grow_bh:OnIntervalThink()
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.status_resistance = self:GetSpecialValueFor("status_resistance")
	self.bonus_armor = self:GetSpecialValueFor("bonus_armor")
	self.attack_speed_reduction = self:GetSpecialValueFor("attack_speed_reduction")
	if self:GetCaster():HasTalent("special_bonus_unique_tiny_grow_bh_1") then
		self.attack_speed_reduction = 0
	end
	self.bonus_attack_range = self:GetSpecialValueFor("bonus_attack_range")

	self.magic_resist = 0
	if self:GetCaster():HasTalent("special_bonus_unique_tiny_grow_bh_2") then
		self.magic_resist = self:GetCaster():FindTalentValue("special_bonus_unique_tiny_grow_bh_2")
	end

	if IsServer() then self:GetParent():CalculateStatBonus() end
end

function modifier_tiny_grow_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_tiny_grow_bh:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_tiny_grow_bh:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_tiny_grow_bh:GetModifierAttackSpeedBonus()
	return self.attack_speed_reduction
end

function modifier_tiny_grow_bh:GetModifierAttackRangeBonus()
	return self.bonus_attack_range
end

function modifier_tiny_grow_bh:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_tiny_grow_bh:IsHidden()
	return true
end

function modifier_tiny_grow_bh:CheckState()
	if self:GetCaster():HasScepter() then
		return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	end
end