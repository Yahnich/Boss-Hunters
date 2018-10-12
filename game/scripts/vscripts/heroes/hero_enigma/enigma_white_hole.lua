enigma_white_hole = class({})

function enigma_white_hole:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function enigma_white_hole:GetCastRange(target, position)
	if self:GetCaster():HasTalent("special_bonus_unique_enigma_white_hole_1") then
		return 350 * self:GetCaster():FindTalentValue("special_bonus_unique_enigma_white_hole_1", "value2")
	else
		return 350
	end
end


function enigma_white_hole:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local originalHole = CreateModifierThinker(caster, self, "modifier_enigma_white_hole_thinker", {Duration = self:GetTalentSpecialValueFor("duration")}, target, caster:GetTeam(), false)
	
	caster:EmitSound("Hero_Enigma.BlackHole.Cast.Chasm")
	
	if caster:HasTalent("special_bonus_unique_enigma_white_hole_1") then
		local endHole = CreateModifierThinker(caster, self, "modifier_enigma_white_hole_thinker", {Duration = self:GetTalentSpecialValueFor("duration")}, caster:GetAbsOrigin(), caster:GetTeam(), false)
		
		endHole.travelPoint = originalHole:GetAbsOrigin()
		originalHole.travelPoint = endHole:GetAbsOrigin()
	end
end

modifier_enigma_white_hole_talent_cd = class({})
LinkLuaModifier("modifier_enigma_white_hole_talent_cd", "heroes/hero_enigma/enigma_white_hole", LUA_MODIFIER_MOTION_NONE)

modifier_enigma_white_hole_thinker = class({})
LinkLuaModifier("modifier_enigma_white_hole_thinker", "heroes/hero_enigma/enigma_white_hole", LUA_MODIFIER_MOTION_NONE)

function modifier_enigma_white_hole_thinker:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.push = self:GetTalentSpecialValueFor("push_speed")
	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		
		local bhFX = ParticleManager:CreateParticle( "particles/enigma_white_hole.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		self:GetParent():EmitSound("Hero_Enigma.Black_Hole")
		self:AddEffect(bhFX)
		self.talent = self.caster:HasTalent("special_bonus_unique_enigma_white_hole_1")
		self:StartIntervalThink(0)
	end
end

function modifier_enigma_white_hole_thinker:OnIntervalThink()
	
	
	local position = self.parent:GetAbsOrigin()
	if self.talent and CalculateDistance( self.caster, self.parent ) < self.radius * 0.1 and not self.caster:HasModifier("modifier_enigma_white_hole_talent_cd") then
		FindClearSpaceForUnit( self.caster, self.parent.travelPoint, true)
		self.caster:AddNewModifier( self.caster, self, "modifier_enigma_white_hole_talent_cd", {duration = self.caster:FindTalentValue("special_bonus_unique_enigma_white_hole_1")})
	end
	
	for _, enemy in ipairs( self.caster:FindEnemyUnitsInRadius( position, self.radius ) ) do
		self.ability:DealDamage( self.caster, enemy, self.damage * FrameTime() )
		local direction = CalculateDirection( enemy, self.parent )
		local pushStrength = self.push * (1 + ( self.radius - CalculateDistance(self.parent, enemy) ) / self.radius)
		local newPos = GetGroundPosition( enemy:GetAbsOrigin(), enemy ) + direction * pushStrength * FrameTime()
		enemy:SetAbsOrigin( newPos )
	end
	
	ResolveNPCPositions(position, self.radius)
end

function modifier_enigma_white_hole_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Enigma.Black_Hole")
		self:GetParent():EmitSound("Hero_Enigma.Black_Hole.Stop")
		UTIL_Remove( self:GetParent() )
		for _, enemy in ipairs( self:GetCaster():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self.radius ) ) do
			enemy:RemoveModifierByName("modifier_enigma_white_hole_aura")
		end
	end
end