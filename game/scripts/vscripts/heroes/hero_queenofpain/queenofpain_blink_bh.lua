queenofpain_blink_bh = class({})

function queenofpain_blink_bh:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_queenofpain_blink_2") then return "modifier_queenofpain_blink_bh_charges" end
end

function queenofpain_blink_bh:OnTalentLearned(talentName)
	if talentName == "special_bonus_unique_queenofpain_blink_2" then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_queenofpain_blink_bh_charges", {})
	end
end

function queenofpain_blink_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local startPos = caster:GetAbsOrigin()
	local direction = CalculateDirection(position, caster)
	local distance = math.min( math.max( self:GetTalentSpecialValueFor("min_blink_range"), CalculateDistance(position, caster) ), self:GetTalentSpecialValueFor("blink_range") )
	local endPos = caster:GetAbsOrigin() + direction * distance
	
	EmitSoundOn("Hero_QueenOfPain.Blink_out", caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_queenofpain/queen_blink_start.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	FindClearSpaceForUnit(caster, endPos, true)
	ProjectileManager:ProjectileDodge( caster )
	ParticleManager:FireParticle("particles/units/heroes/hero_queenofpain/queen_blink_end.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	EmitSoundOn("Hero_QueenOfPain.Blink_in", caster)
	if caster:HasTalent("special_bonus_unique_queenofpain_blink_1") then
		caster:AddNewModifier(caster, self, "modifier_queenofpain_blink_bh_talent", {duration = caster:FindTalentValue("special_bonus_unique_queenofpain_blink_1", "duration") } )
	end
end

modifier_queenofpain_blink_bh_talent = class({})
LinkLuaModifier( "modifier_queenofpain_blink_bh_talent", "heroes/hero_queenofpain/queenofpain_blink_bh.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_queenofpain_blink_bh_talent:OnCreated()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_1", "as")
	self.cdr = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_1", "cdr")
end

function modifier_queenofpain_blink_bh_talent:OnRefresh()
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_1", "as")
	self.cdr = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_1", "cdr")
end

function modifier_queenofpain_blink_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_queenofpain_blink_bh_talent:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_queenofpain_blink_bh_talent:GetCooldownReduction()
	return self.cdr
end

modifier_queenofpain_blink_bh_charges = class({})
LinkLuaModifier( "modifier_queenofpain_blink_bh_charges", "heroes/hero_queenofpain/queenofpain_blink_bh.lua", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
    function modifier_queenofpain_blink_bh_charges:Update()
		self.kv.replenish_time = self:GetAbility():GetCooldown(-1) + self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_2", "bonus_cd")
		self.kv.max_count = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_2")
		
		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() < self.kv.max_count then
			if self:GetRemainingTime() < -1 then
				local duration = self.kv.replenish_time * caster:GetCooldownReduction()
				self:SetDuration(duration, true)
			end
			self:StartIntervalThink(self:GetRemainingTime())
			if self:GetStackCount() == 0 then
				self:GetAbility():StartCooldown(self:GetRemainingTime())
			end
		end
    end

    function modifier_queenofpain_blink_bh_charges:OnCreated()
		kv = {
			max_count = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_2"),
			replenish_time = self:GetAbility():GetCooldown(-1) + self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_2", "bonus_cd"),
			start_count = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_2")
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv
	
        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
		else
			self:SetDuration(-1, true)
        end
    end
	
	function modifier_queenofpain_blink_bh_charges:OnRefresh()
		self.kv.max_count =self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_2")
		self.kv.replenish_time = self:GetAbility():GetCooldown(-1) + self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_2", "bonus_cd")
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_queenofpain_blink_bh_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_queenofpain_blink_bh_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetAbility():GetCooldown(-1) + self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_2", "bonus_cd")
			self.kv.max_count =self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_blink_2")
			
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

    function modifier_queenofpain_blink_bh_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		
		self:StartIntervalThink(-1)
		
		local duration = self.kv.replenish_time * get_octarine_multiplier( self:GetCaster() )
		self:SetDuration(duration, true)
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
		elseif stacks == self.kv.max_count then
			self:SetDuration( -1, true )
        end
    end
end

function modifier_queenofpain_blink_bh_charges:DestroyOnExpire()
    return false
end

function modifier_queenofpain_blink_bh_charges:IsPurgable()
    return false
end

function modifier_queenofpain_blink_bh_charges:RemoveOnDeath()
    return false
end