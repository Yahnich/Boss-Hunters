batrider_napalm = class({})
LinkLuaModifier("modifier_batrider_napalm_debuff", "heroes/hero_batrider/batrider_napalm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_batrider_napalm_fire", "heroes/hero_batrider/batrider_napalm", LUA_MODIFIER_MOTION_NONE)

function batrider_napalm:IsStealable()
    return true
end

function batrider_napalm:IsHiddenWhenStolen()
    return false
end

function batrider_napalm:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function batrider_napalm:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	local limit = self:GetSpecialValueFor("max_stacks")
	
	EmitSoundOn("Hero_Batrider.StickyNapalm.Cast", caster)
	EmitSoundOnLocationWithCaster(point, "Hero_Batrider.StickyNapalm.Impact", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_stickynapalm_impact.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, point)
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, 0, 0))
				ParticleManager:SetParticleControlEnt(nfx, 2, caster, PATTACH_POINT, "lasso_attack", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)

	local enemies = caster:FindEnemyUnitsInRadius(point, radius)
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb(self) then
			if not enemy:HasModifier("modifier_batrider_napalm_fire") then
				if enemy:HasModifier("modifier_batrider_napalm_debuff") then
					if enemy:FindModifierByName("modifier_batrider_napalm_debuff"):GetStackCount() < limit then
						enemy:AddNewModifier(caster, self, "modifier_batrider_napalm_debuff", {Duration = duration}):IncrementStackCount()
					else
						enemy:AddNewModifier(caster, self, "modifier_batrider_napalm_debuff", {Duration = duration})
					end
				else
					enemy:AddNewModifier(caster, self, "modifier_batrider_napalm_debuff", {Duration = duration}):IncrementStackCount()
				end
			else
				enemy:AddNewModifier(caster, self, "modifier_batrider_napalm_fire", {Duration = duration})
			end
		end
	end
end

modifier_batrider_napalm_debuff = class({})
function modifier_batrider_napalm_debuff:OnCreated(table)
	self.slow = self:GetSpecialValueFor("slow_ms") * self:GetStackCount()
	self.turnRate = self:GetSpecialValueFor("turn_rate_pct")
	self.amp = self:GetSpecialValueFor("damage_amp") * self:GetStackCount()

	if self:GetCaster():HasTalent("special_bonus_unique_batrider_napalm_1") then
		self.slow_as = self.slow
	else
		self.slow_as = 0
	end

	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(self.nfx, 0, parent, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(self.nfx, 1, Vector(0, self:GetStackCount(), 0))
		self:AttachEffect(self.nfx)

		self.damage = self:GetSpecialValueFor("damage") * self:GetStackCount()
	end
end

function modifier_batrider_napalm_debuff:OnRefresh(table)
	self.slow = self:GetSpecialValueFor("slow_ms") * self:GetStackCount()
	self.turnRate = self:GetSpecialValueFor("turn_rate_pct")
	self.amp = self:GetSpecialValueFor("damage_amp") * self:GetStackCount()

	if self:GetCaster():HasTalent("special_bonus_unique_batrider_napalm_1") then
		self.slow_as = self.slow
	else
		self.slow_as = 0
	end

	if IsServer() then
		if self:GetStackCount() < 10 then
			ParticleManager:SetParticleControl(self.nfx, 1, Vector(0, self:GetStackCount(), 0))
		else
			ParticleManager:SetParticleControl(self.nfx, 1, Vector(1, 0, 0))
		end

		self.damage = self:GetSpecialValueFor("damage") * self:GetStackCount()
	end
end

function modifier_batrider_napalm_debuff:OnStackCountChanged(iStackCount)
	self.slow = self:GetSpecialValueFor("slow_ms") * self:GetStackCount()
	self.turnRate = self:GetSpecialValueFor("turn_rate_pct")
	self.amp = self:GetSpecialValueFor("damage_amp") * self:GetStackCount()
	if self:GetCaster():HasTalent("special_bonus_unique_batrider_napalm_1") then
		self.slow_as = self.slow
	else
		self.slow_as = 0
	end

	if IsServer() then
		if self:GetStackCount() < 10 then
			ParticleManager:SetParticleControl(self.nfx, 1, Vector(0, self:GetStackCount(), 0))
		else
			ParticleManager:SetParticleControl(self.nfx, 1, Vector(1, 0, 0))
		end

		self.damage = self:GetSpecialValueFor("damage") * self:GetStackCount()
	end
end

function modifier_batrider_napalm_debuff:DeclareFunctions()
    -- MODIFIER_EVENT_ON_TAKEDAMAGE,
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end

function modifier_batrider_napalm_debuff:GetModifierAttackSpeedBonus_Constant()
	return -self.slow_as
end

function modifier_batrider_napalm_debuff:GetModifierIncomingDamage_Percentage(params)
	if params.attacker == self:GetCaster() then
		return self.amp
	end
end

-- function modifier_batrider_napalm_debuff:OnTakeDamage(params)
    -- if IsServer() then
    	-- local caster = self:GetCaster()
    	-- local parent = self:GetParent()
    	-- local unit = params.unit
    	-- local attacker = params.attacker

        -- if unit == parent and attacker == caster and params.inflictor and caster:HasAbility( params.inflictor:GetName() ) and params.inflictor:GetName() ~= "batrider_concoction" then
        	-- local ability = self:GetAbility()

        	-- local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_napalm_damage_debuff.vpcf", PATTACH_POINT, caster)
        				-- ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT, "attach_hitloc", parent:GetAbsOrigin(), true)
        				-- ParticleManager:ReleaseParticleIndex(nfx)

        	-- if caster:HasTalent("special_bonus_unique_batrider_napalm_2") then
        		-- local radius = caster:FindTalentValue("special_bonus_unique_batrider_napalm_2")
        		-- local damage = self:GetSpecialValueFor("damage") * self:GetSpecialValueFor("max_stacks")

        		-- ParticleManager:FireParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_POINT, unit, {[0]="attach_hitloc", [1]=Vector(radius, radius, radius)})

        		-- local enemies = caster:FindEnemyUnitsInRadius(unit:GetAbsOrigin(), radius)
        		-- for _,enemy in pairs(enemies) do
        			-- if enemy ~= unit then
        				-- ability:DealDamage(caster, enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_HPLOSS}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
        			-- end
        		-- end
        	-- end

        	-- local modifier = parent:AddNewModifier(caster, self:GetAbility(), "modifier_batrider_napalm_fire", {Duration = self:GetSpecialValueFor("duration")})
			-- if modifier then 
				-- modifier:SetStackCount(self:GetStackCount())
			-- end
        	-- self:Destroy()
        -- end
    -- end
-- end

function modifier_batrider_napalm_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_batrider_napalm_debuff:GetModifierTurnRate_Percentage()
	return self.turnRate
end

function modifier_batrider_napalm_debuff:GetEffectName()
	return "particles/units/heroes/hero_batrider/batrider_stickynapalm_debuff.vpcf"
end

function modifier_batrider_napalm_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_stickynapalm.vpcf"
end

function modifier_batrider_napalm_debuff:StatusEffectPriority()
	return 11
end

function modifier_batrider_napalm_debuff:IsDebuff()
	return true
end

modifier_batrider_napalm_fire = class({})
function modifier_batrider_napalm_fire:OnCreated(table)
	if IsServer() then
		self.damage = self:GetSpecialValueFor("damage") * self:GetStackCount()

		self:StartIntervalThink(1)
	end
end

function modifier_batrider_napalm_fire:OnRefresh(table)
	if IsServer() then
		self.damage = self:GetSpecialValueFor("damage") * self:GetStackCount()
	end
end

function modifier_batrider_napalm_fire:OnIntervalThink()
	if IsServer() then
		self.damage = self:GetSpecialValueFor("damage") * self:GetStackCount()
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end

function modifier_batrider_napalm_fire:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_batrider_napalm_fire:GetStatusEffectName()
	return "particles/status_fx/status_effect_burn.vpcf"
end

function modifier_batrider_napalm_fire:StatusEffectPriority()
	return 11
end

function modifier_batrider_napalm_fire:IsDebuff()
	return true
end