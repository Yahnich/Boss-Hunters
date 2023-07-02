shadow_fiend_shadowraze1 = class({})

-- function shadow_fiend_shadowraze1:OnUpgrade()
	-- local caster = self:GetCaster()
	-- local raze2 = caster:FindAbilityByName("shadow_fiend_shadowraze2")
	-- local raze3 = caster:FindAbilityByName("shadow_fiend_shadowraze3")
	
	-- local level = self:GetLevel()
	-- if raze2:GetLevel() < level then
		-- raze2:SetLevel( level )
	-- end
	-- if raze3:GetLevel() < level then
		-- raze3:SetLevel( level )
	-- end
-- end

function shadow_fiend_shadowraze1:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasTalent() then
		return self:GetTalentSpecialValueFor("range") + self:GetTalentSpecialValueFor("radius")
	else
		return self:GetTalentSpecialValueFor("range")
	end
end

function shadow_fiend_shadowraze1:OnSpellStart()
	EmitSoundOn("Hero_Nevermore.Shadowraze", self:GetCaster())
	if self:GetCaster():HasScepter() then
		self:CircleRaze()
	else
		self:SingleRaze()
	end
end

function shadow_fiend_shadowraze1:SingleRaze()
	local caster = self:GetCaster()

	local startPos = caster:GetAbsOrigin()
	local direction = caster:GetForwardVector()
	local distance = self:GetTalentSpecialValueFor("range")
	local radius = self:GetTalentSpecialValueFor("radius")
	local position = startPos + direction * distance
	ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_POINT, caster, {[0]=position})

	local enemies = caster:FindEnemyUnitsInRadius(position, radius)
	self:HandleShadowRaze( enemies )
end

function shadow_fiend_shadowraze1:CircleRaze()
	local caster = self:GetCaster()

	local startPos = caster:GetAbsOrigin()
	local direction = caster:GetForwardVector()
	local distance = self:GetTalentSpecialValueFor("range")
	local radius = self:GetTalentSpecialValueFor("radius")
	

	local maxRaze = math.floor( ((2 * math.pi * distance) / radius) )
	local angle = 360/maxRaze
	local curRaze = 0

	for i=curRaze,maxRaze do
		direction = RotateVector2D(direction, ToRadians( angle ) )
		local position = startPos + direction * distance
		position = GetGroundPosition(position, caster)

		CutTreesInRadius(position, radius)
		AddFOWViewer(caster:GetTeam(), position, radius, 1, false)
		
		ParticleManager:FireParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_POINT, caster, {[0]=position})
	end

	local enemies = caster:FindEnemyUnitsInRing(startPos, distance + radius, distance - radius)
	self:HandleShadowRaze( enemies )
end

function shadow_fiend_shadowraze1:HandleShadowRaze( enemies )
	local caster = self:GetCaster()
	
	local damage = self:GetTalentSpecialValueFor("damage")
	local stack_damage = self:GetTalentSpecialValueFor("stack_damage")
	local duration = self:GetTalentSpecialValueFor("duration")
	
	local hasTalent1 = caster:HasTalent("special_bonus_unique_shadow_fiend_shadowraze_1")
	local talent1Healing = caster:FindTalentValue("special_bonus_unique_shadow_fiend_shadowraze_1") / 100
	local talent1MinionHealing = caster:FindTalentValue("special_bonus_unique_shadow_fiend_shadowraze_1", "value2") / 100
	local talent1HealingTotal = 0
	
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			local totalDamage = damage
			local modifier = enemy:FindModifierByName("modifier_shadow_fiend_shadowraze")
			if modifier then
				totalDamage = totalDamage + stack_damage * modifier:GetStackCount()
			end
			enemy:AddNewModifier(caster, self, "modifier_shadow_fiend_shadowraze", {Duration = duration})
			local damageTotal = self:DealDamage(caster, enemy, totalDamage, {}, 0)
			if hasTalent1 then
				if enemy:IsMinion() then
					talent1HealingTotal = talent1HealingTotal + damageTotal * talent1MinionHealing
				else
					talent1HealingTotal = talent1HealingTotal + damageTotal * talent1Healing
				end
			end
		end
	end
	if talent1HealingTotal > 0 then
		caster:HealEvent( talent1HealingTotal, self, caster )
	end
end

shadow_fiend_shadowraze2 = class(shadow_fiend_shadowraze1)

-- function shadow_fiend_shadowraze2:OnUpgrade()
	-- local caster = self:GetCaster()
	-- local raze1 = caster:FindAbilityByName("shadow_fiend_shadowraze1")
	-- local raze3 = caster:FindAbilityByName("shadow_fiend_shadowraze3")
	
	-- local level = self:GetLevel()
	-- if raze1:GetLevel() < level then
		-- raze1:SetLevel( level )
	-- end
	-- if raze3:GetLevel() < level then
		-- raze3:SetLevel( level )
	-- end
-- end

shadow_fiend_shadowraze3 = class(shadow_fiend_shadowraze1)

-- function shadow_fiend_shadowraze3:OnUpgrade()
	-- local caster = self:GetCaster()
	-- local raze1 = caster:FindAbilityByName("shadow_fiend_shadowraze1")
	-- local raze2 = caster:FindAbilityByName("shadow_fiend_shadowraze2")
	
	-- local level = self:GetLevel()
	-- if raze1:GetLevel() < level then
		-- raze1:SetLevel( level )
	-- end
	-- if raze2:GetLevel() < level then
		-- raze2:SetLevel( level )
	-- end
-- end

modifier_shadow_fiend_shadowraze = class({})
LinkLuaModifier( "modifier_shadow_fiend_shadowraze","heroes/hero_shadow_fiend/shadow_fiend_shadowraze.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_shadow_fiend_shadowraze:OnCreated()
	self:OnRefresh()
end

function modifier_shadow_fiend_shadowraze:OnRefresh()
	self.armor_reduction = self:GetTalentSpecialValueFor("armor_debuff")
	self.armor_cap = self:GetTalentSpecialValueFor("armor_cap")
	self.max = self:GetTalentSpecialValueFor("stack_max")
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_shadow_fiend_shadowraze:DeclareFunctions()
	return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_shadow_fiend_shadowraze:GetModifierPhysicalArmorBonus()
	return self.armor_reduction * math.min( self:GetStackCount(), self.max ) + self.armor_cap * math.max( 0, self:GetStackCount() - self.max )
end

function modifier_shadow_fiend_shadowraze:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end