broodmother_spawn_spiderlings_bh = class({})
LinkLuaModifier("modifier_broodmother_spawn_spiderlings_bh", "heroes/hero_broodmother/broodmother_spawn_spiderlings_bh", LUA_MODIFIER_MOTION_NONE)

function broodmother_spawn_spiderlings_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Broodmother.SpawnSpiderlingsCast", caster)
	self:FireTrackingProjectile("particles/units/heroes/hero_broodmother/broodmother_web_cast.vpcf", target, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 50)
end

function broodmother_spawn_spiderlings_bh:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		EmitSoundOn("Hero_Broodmother.SpawnSpiderlingsCast", hTarget)
		hTarget:AddNewModifier(caster, self, "modifier_broodmother_spawn_spiderlings_bh", {Duration = self:GetTalentSpecialValueFor("duration")})
		self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
	end
end

modifier_broodmother_spawn_spiderlings_bh = class({})

function modifier_broodmother_spawn_spiderlings_bh:OnRemoved()
    if IsServer() then
    	local caster = self:GetCaster()
    	local ability = self:GetAbility()
		local parent = self:GetParent()
		
    	local damage = self:GetTalentSpecialValueFor("spider_damage")
		local hp = self:GetTalentSpecialValueFor("spider_health")
		local mr = self:GetTalentSpecialValueFor("spider_mr")
		
    	EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", self:GetParent())
    	ParticleManager:FireParticle("particles/units/heroes/hero_broodmother/broodmother_spiderlings_spawn.vpcf", PATTACH_POINT, self:GetParent(), {})
    	for i=1,self:GetTalentSpecialValueFor("count") do
    		local position = self:GetParent():GetAbsOrigin() + ActualRandomVector(150, 50)
    		local spider = caster:CreateSummon("npc_dota_broodmother_spiderling", position, self:GetTalentSpecialValueFor("spider_duration"))
    		FindClearSpaceForUnit(spider, position, false)
			
    		spider:RemoveAbility("broodmother_poison_sting")
    		spider:RemoveAbility("broodmother_spawn_spiderite")
			
			spider:AddNewModifier( caster, ability, "modifier_broodmother_spawn_spiderlings_evasion", {})
			
			if caster:HasTalent("special_bonus_unique_broodmother_spawn_spiderlings_bh_1") then
				local stealList = {}
				for i = 0, 16 do
					local stealAbility = parent:GetAbilityByIndex(i)
					if stealAbility then print( stealAbility:GetName(), stealAbility:IsPassive() ) end
					if stealAbility and stealAbility:IsPassive() then
						table.insert( stealList, stealAbility:GetName() )
					end
				end
				if #stealList > 0 then spider:AddAbility( stealList[RandomInt(1, #stealList)] ):SetLevel(1) end
				spider:SetAttackCapability( parent:GetAttackCapability() )
				if parent:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
					spider:SetRangedProjectileName( parent:GetRangedProjectileName() )
				end
			end
			
			spider:SetBaseMagicalResistanceValue( mr )
    		spider:SetAverageBaseDamage( damage, 15 )
    		spider:SetBaseAttackTime( 1 )
			spider:SetCoreHealth( hp )
			
    		spider:AddAbility("broodmother_bite"):SetLevel(1)
    		
    	end
    end
end

function modifier_broodmother_spawn_spiderlings_bh:GetEffectName()
	return "particles/units/heroes/hero_broodmother/broodmother_spiderlings_debuff.vpcf"
end

modifier_broodmother_spawn_spiderlings_evasion = class({})
LinkLuaModifier("modifier_broodmother_spawn_spiderlings_evasion", "heroes/hero_broodmother/broodmother_spawn_spiderlings_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_broodmother_spawn_spiderlings_evasion:OnCreated()
	self.evasion = self:GetTalentSpecialValueFor("spider_evasion")
end

function modifier_broodmother_spawn_spiderlings_evasion:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
			MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS}
end

function modifier_broodmother_spawn_spiderlings_evasion:GetModifierAttackRangeOverride()
	if self:GetParent():IsRangedAttacker() then
		return 400
	end
end

function modifier_broodmother_spawn_spiderlings_evasion:GetModifierProjectileSpeedBonus()
	if self:GetParent():IsRangedAttacker() then
		return 900
	end
end


function modifier_broodmother_spawn_spiderlings_evasion:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_broodmother_spawn_spiderlings_evasion:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.inflictor and params.inflictor:GetName() ~= "broodmother_bite" then
		return -75
	end
end

function modifier_broodmother_spawn_spiderlings_evasion:IsHidden()
	return true
end