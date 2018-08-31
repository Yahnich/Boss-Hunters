treant_little_tree = class({})

function treant_little_tree:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	
	self:CreateLittleTree(position, duration)
	if caster:HasTalent("special_bonus_unique_treant_little_tree_2") then
		local spread = caster:FindTalentValue("special_bonus_unique_treant_little_tree_2", "radius")
		for i = 1, caster:FindTalentValue("special_bonus_unique_treant_little_tree_2") do
			local randPos = position + ActualRandomVector( spread, 125 )
			self:CreateLittleTree(randPos, duration)
		end
	end
	EmitSoundOnLocationWithCaster(position, "Hero_Treant.Eyes.Cast", caster )
end

function treant_little_tree:CreateLittleTree(position, duration)
	local caster = self:GetCaster()
	
	local fDur = duration or self:GetTalentSpecialValueFor("duration")
	CreateModifierThinker(caster, self, "modifier_treant_little_tree_thinker", {Duration = fDur}, position, caster:GetTeam(), false)
	CreateTempTree(position, fDur)
	ResolveNPCPositions(position, 150)
end

modifier_treant_little_tree_thinker = class({})
LinkLuaModifier("modifier_treant_little_tree_thinker", "heroes/hero_treant_protector/treant_little_tree", LUA_MODIFIER_MOTION_NONE)

function modifier_treant_little_tree_thinker:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("aura_radius")
	if IsServer() then
		self:StartIntervalThink(0.1)
		local FX = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( FX, 1, Vector(self.radius,self.radius,self.radius) )
	end
end

function modifier_treant_little_tree_thinker:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if not GridNav:IsNearbyTree( parent:GetAbsOrigin(), 10, false) then
        self:Destroy()
		return
	else
		for _, unit in ipairs( caster:FindAllUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
			if caster:IsSameTeam( unit ) then
				local modifier = unit:FindModifierByName("modifier_treant_little_tree_buff")
				if not modifier then
					modifier = unit:AddNewModifier(caster, ability, "modifier_treant_little_tree_buff", {})
				end
				modifier:SetDuration( -1, true )
				modifier:SetDuration( 0.5, false )
			else
				local modifier = unit:FindModifierByName("modifier_treant_little_tree_debuff")
				if not modifier then
					modifier = unit:AddNewModifier(caster, ability, "modifier_treant_little_tree_debuff", {})
				end
				modifier:SetDuration( -1, true )
				modifier:SetDuration( 0.5, false )
			end
		end
    end
end

function modifier_treant_little_tree_thinker:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

modifier_treant_little_tree_buff = class({})
LinkLuaModifier("modifier_treant_little_tree_buff", "heroes/hero_treant_protector/treant_little_tree", LUA_MODIFIER_MOTION_NONE)

function modifier_treant_little_tree_buff:OnCreated()
	self.heal = self:GetTalentSpecialValueFor("heal")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_treant_little_tree_buff:OnIntervalThink()
	self:GetParent():HealEvent( self.heal, self:GetAbility(), self:GetCaster() )
end

modifier_treant_little_tree_debuff = class({})
LinkLuaModifier("modifier_treant_little_tree_debuff", "heroes/hero_treant_protector/treant_little_tree", LUA_MODIFIER_MOTION_NONE)

function modifier_treant_little_tree_debuff:OnCreated()
	self.dmg = self:GetTalentSpecialValueFor("leech")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_treant_little_tree_debuff:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.dmg )
end