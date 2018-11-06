boss_apotheosis_blessed_being = class({})

function boss_apotheosis_blessed_being:GetIntrinsicModifierName()
	return "modifier_boss_apotheosis_blessed_being"
end

modifier_boss_apotheosis_blessed_being = class({})
LinkLuaModifier("modifier_boss_apotheosis_blessed_being", "bosses/boss_apotheosis/boss_apotheosis_blessed_being", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_apotheosis_blessed_being:OnCreated()
	self.interval = self:GetSpecialValueFor("debuff_limit")
	self.delay = 0
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function modifier_boss_apotheosis_blessed_being:OnCreated()
	self.interval = self:GetSpecialValueFor("debuff_limit")
	self.delay = 0
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function modifier_boss_apotheosis_blessed_being:OnIntervalThink()
	local debuffFound = false
	local parent = self:GetParent()
	if parent:PassivesDisabled() then return end
	for _, modifier in ipairs( parent:FindAllModifiers() ) do
		if not modifier.IsDebuff then
			if modifier:GetCaster() and not modifier:GetCaster():IsSameTeam( parent ) then
				debuffFound = true
			end
		elseif modifier:IsDebuff() then
			debuffFound = true
		end
		if debuffFound then break end
	end
	if debuffFound then
		self.delay = self.delay + 0.33
	else
		self.delay = 0
	end
	if self.delay > self.interval then
		self.delay = 0
		parent:Dispel(parent, true)
		ParticleManager:FireParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_POINT_FOLLOW, parent)
	end
end

function modifier_boss_apotheosis_blessed_being:IsHidden()
	return true
end

function modifier_boss_apotheosis_blessed_being:IsPurgable()
	return false
end