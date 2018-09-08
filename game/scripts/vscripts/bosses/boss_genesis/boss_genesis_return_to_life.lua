boss_genesis_return_to_life = class({})

function boss_genesis_return_to_life:OnAbilityPhaseStart()
	for _, hero in ipairs( HeroList:GetActiveHeroes() ) do
		ParticleManager:FireWarningParticle( hero:GetAbsOrigin(), 150 )
	end
	return true
end

function boss_genesis_return_to_life:OnSpellStart()
	local caster = self:GetCaster()
	local heroes = HeroList:GetActiveHeroes()
	
	for _, hero in ipairs( heroes ) do
		self:ConjureImage( hero )
	end
end

function  boss_genesis_return_to_life:ConjureImage( target )
	local caster = self:GetCaster()
	local unit_name = target:GetUnitName()
	local origin = target:GetAbsOrigin() + RandomVector(150)
	
	local illusion = CreateUnitByName("npc_illusion_template", origin, true, caster, caster, caster:GetTeamNumber())
		
	for abilitySlot=0,15 do
		local abilityillu = target:GetAbilityByIndex(abilitySlot)
		if abilityillu ~= nil then
			local abilityLevel = abilityillu:GetLevel()
			local abilityName = abilityillu:GetAbilityName()
			if illusion:FindAbilityByName(abilityName) ~= nil then
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				illusionAbility:SetLevel(abilityLevel)
			else
				local illusionAbility = illusion:AddAbility(abilityName)
				illusionAbility:SetLevel(abilityLevel)
			end
		end
	end
	
	-- Make illusion look like owner
	illusion:SetBaseMaxHealth( target:GetMaxHealth() )
	illusion:SetMaxHealth( target:GetMaxHealth() )
	illusion:SetHealth( target:GetHealth() )
	
	illusion:SetAverageBaseDamage( target:GetAverageBaseDamage(), 15 )
	illusion:SetPhysicalArmorBaseValue( target:GetPhysicalArmorValue() )
	illusion:SetBaseAttackTime( target:GetBaseAttackTime() )
	illusion:SetBaseMoveSpeed( target:GetBaseMoveSpeed() )
	
	illusion:SetOriginalModel( target:GetModelName() )
	illusion:SetModel( target:GetModelName() )
	
	local moveCap = DOTA_UNIT_CAP_MOVE_NONE
	if target:HasMovementCapability() then
		moveCap = DOTA_UNIT_CAP_MOVE_GROUND
		if target:HasFlyMovementCapability() then
			moveCap = DOTA_UNIT_CAP_MOVE_FLY
		end
	end
	illusion:SetMoveCapability( moveCap )
	illusion:SetAttackCapability( target:GetAttackCapability() )
	illusion:SetUnitName( target:GetUnitName() )
	if target:IsRangedAttacker() then
		illusion:SetRangedProjectileName( target:GetRangedProjectileName() )
	end
	
	for _, modifier in ipairs( target:FindAllModifiers() ) do
		if modifier.AllowIllusionDuplicate and modifier:AllowIllusionDuplicate() then
			illusion:AddNewModifier( modifier:GetCaster(), modifier:GetAbility(), modifier:GetName(), { duration = modifier:GetRemainingTime() })
		end
	end
	
	illusion:AddNewModifier( target, self, "modifier_illusion_bonuses", { duration = duration })
	
	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = target:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, nil, nil)
			newItem:SetStacksWithOtherOwners(true)
			illusion:AddItem(newItem)
			newItem:SetPurchaser(nil)
			
		end
	end

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(target, self, "modifier_illusion", { outgoing_damage = self:GetSpecialValueFor("outgoing") - 100, incoming_damage = self:GetSpecialValueFor("incoming") - 100 })
	
	for _, wearable in ipairs( target:GetChildren() ) do
		if wearable:GetClassname() == "dota_item_wearable" and wearable:GetModelName() ~= "" then
			local newWearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model=wearable:GetModelName()})
			newWearable:SetParent(illusion, nil)
			newWearable:FollowEntity(illusion, true)
			newWearable:SetRenderColor(100,100,255)
			Timers:CreateTimer(1, function()
				if illusion and not illusion:IsNull() and illusion:IsAlive() then
					return 0.25
				else
					UTIL_Remove( newWearable )
				end
			end)
		end
	end
	
	illusion.hasBeenInitialized = true	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()
	illusion.isCustomIllusion = true
	return illusion
end