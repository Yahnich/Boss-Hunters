espirit_rock = class({})

function espirit_rock:GetIntrinsicModifierName()
	return "modifier_espirit_rock_charges"
end

function espirit_rock:HasCharges()
	return true
end

function espirit_rock:GetAOERadius(target, position)
	return self:GetCaster():FindTalentValue("special_bonus_unique_espirit_rock_2", "radius")
end

function espirit_rock:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_spawn.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx, 0, point)
	ParticleManager:SetParticleControl(nfx, 1, point)
	ParticleManager:ReleaseParticleIndex(nfx)
	
	self:CreateStoneRemnant(point)
end

function espirit_rock:CreateStoneRemnant(position)
	local caster = self:GetCaster()	
	local rock = caster:CreateSummon("npc_dota_earth_spirit_stone", position, self:GetTalentSpecialValueFor("rock_duration"))
	rock:SetForwardVector(caster:GetForwardVector())

	rock:AddNewModifier(caster, self, "modifier_espirit_rock_remnant", {})   

	if caster:HasTalent("special_bonus_unique_espirit_rock_2") then
		local enemies = caster:FindEnemyUnitsInRadius(position, caster:FindTalentValue("special_bonus_unique_espirit_rock_2", "radius"))
		local tDur = caster:FindTalentValue("special_bonus_unique_espirit_rock_2")
		for _,enemy in pairs(enemies) do
			if not enemy:HasModifier("modifier_knockback") then
				enemy:ApplyKnockBack(enemy, tDur, tDur, 0, 300, caster, self)
			end
		end
	end	
end


modifier_espirit_rock_remnant = class({})
LinkLuaModifier( "modifier_espirit_rock_remnant", "heroes/hero_espirit/espirit_rock.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_espirit_rock_remnant:OnCreated(table)
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stoneremnant.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx, 1, self:GetParent():GetAbsOrigin())
		EmitSoundOn("Hero_EarthSpirit.StoneRemnant.Impact", self:GetParent())
		self:StartIntervalThink(1.0)
	end
end

function modifier_espirit_rock_remnant:OnIntervalThink()
	local parent = self:GetParent()
	if parent:HasTalent("special_bonus_unique_espirit_rock_1") then
		local allies = parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), parent:FindTalentValue("special_bonus_unique_espirit_rock_1", "radius"))
		for _,ally in pairs(allies) do
			if ally:GetUnitName() ~= "npc_dota_earth_spirit_stone" then
				ally:HealEvent(  parent:FindTalentValue("special_bonus_unique_espirit_rock_1") , self:GetAbility(), parent)
			end
		end
	end
end

function modifier_espirit_rock_remnant:CheckState()
	local state = { [MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NOT_ON_MINIMAP] = true
					}
	return state
end

function modifier_espirit_rock_remnant:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx, false)
		StopSoundOn("Hero_EarthSpirit.StoneRemnant.Impact", self:GetParent())
		EmitSoundOn("Hero_EarthSpirit.StoneRemnant.Destroy", self:GetParent())
	end
end

function modifier_espirit_rock_remnant:IsHidden()
	return true
end

modifier_espirit_rock_charges = class({})
LinkLuaModifier( "modifier_espirit_rock_charges", "heroes/hero_espirit/espirit_rock.lua", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
    function modifier_espirit_rock_charges:Update()
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_time")
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")

		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() < self.kv.max_count then
			local duration = self.kv.replenish_time* get_octarine_multiplier( self:GetCaster() )
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
		end

        if self:GetStackCount() == 0 then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
        end
    end

    function modifier_espirit_rock_charges:OnCreated()
		kv = {
			max_count = self:GetTalentSpecialValueFor("charges"),
			replenish_time = self:GetTalentSpecialValueFor("charge_time")
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
    end
	
	function modifier_espirit_rock_charges:OnRefresh()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_time")
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_espirit_rock_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_espirit_rock_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_time")
			self.kv.max_count = self:GetTalentSpecialValueFor("charges")
			
            local ability = params.ability
            if params.ability == self:GetAbility() then
                self:DecrementStackCount()
				ability:EndCooldown()
                self:Update()
			elseif params.ability:GetName() == "item_refresher" and self:GetStackCount() < self.kv.max_count then
                self:IncrementStackCount()
                self:Update()
            end
        end

        return 0
    end

    function modifier_espirit_rock_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = get_octarine_multiplier(caster)
		
		self.kv.replenish_time = self:GetTalentSpecialValueFor("charge_time")
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
        end
    end
end

function modifier_espirit_rock_charges:DestroyOnExpire()
    return false
end

function modifier_espirit_rock_charges:IsPurgable()
    return false
end

function modifier_espirit_rock_charges:RemoveOnDeath()
    return false
end