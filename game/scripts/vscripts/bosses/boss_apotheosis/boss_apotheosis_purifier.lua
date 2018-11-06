boss_apotheosis_purifier = class({})

function boss_apotheosis_purifier:GetIntrinsicModifierName()
	return "modifier_boss_apotheosis_purifier"
end

modifier_boss_apotheosis_purifier = class({})
LinkLuaModifier( "modifier_boss_apotheosis_purifier", "bosses/boss_apotheosis/boss_apotheosis_purifier", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_apotheosis_purifier:OnCreated()
	self.interval = self:GetSpecialValueFor("purge_interval")
	if IsServer() then
		self:StartIntervalThink( self.interval )
	end
end

function modifier_boss_apotheosis_purifier:OnRefresh()
	self.interval = self:GetSpecialValueFor("purge_interval")
	if IsServer() then
		self:StartIntervalThink( self.interval )
	end
end

function modifier_boss_apotheosis_purifier:OnIntervalThink()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		self:StartIntervalThink(2)
	else
		for _, hero in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), -1 ) ) do
			hero:Dispel(parent, true)
			hero:EmitSound("DOTA_Item.DiffusalBlade.Activate")
			ParticleManager:FireParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_POINT_FOLLOW, hero)
		end
		self:StartIntervalThink( self.interval )
	end
end

function modifier_boss_apotheosis_purifier:IsHidden()
	return true
end