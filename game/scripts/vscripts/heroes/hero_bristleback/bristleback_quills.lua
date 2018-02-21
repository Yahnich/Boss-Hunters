bristleback_quills = class({})
LinkLuaModifier( "modifier_quills", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_quills_enemy", "heroes/hero_bristleback/bristleback_quills.lua",LUA_MODIFIER_MOTION_NONE )

function bristleback_quills:GetIntrinsicModifierName()
	return "modifier_quills"
end

function bristleback_quills:IsStealable()
	return true
end

function bristleback_quills:IsHiddenWhenStolen()
	return false
end

function bristleback_quills:OnSpellStart()
	self:Spray(false, true)
end

function bristleback_quills:Spray(bProc, buttonPress)
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Bristleback.QuillSpray.Cast", self:GetCaster())
	ParticleManager:FireParticle("particles/units/heroes/hero_bristleback/bristleback_quill_spray.vpcf", PATTACH_POINT, caster)
	
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		EmitSoundOn("Hero_Bristleback.QuillSpray.Target", enemy)
		local modifier = enemy:FindModifierByName("modifier_quills_enemy")
		local damage = self:GetTalentSpecialValueFor("quill_base_damage")
		if modifier then damage = damage + modifier:GetStackCount() * self:GetTalentSpecialValueFor("quill_stack_damage") end
		enemy:AddNewModifier(caster, self, "modifier_quills_enemy", {duration = self:GetTalentSpecialValueFor("quill_stack_duration")})
		self:DealDamage(caster, enemy, damage)
	end
	if not buttonPress then
		if bProc then 
			caster:SpendMana(1, self)
		else
			self:UseResources(true, false, true)
		end
	end
end

modifier_quills = class({})

if IsServer() then
	function modifier_quills:OnCreated(kv)
		-- self:GetAbility():Spray()
		self:StartIntervalThink(0.1)
	end

	function modifier_quills:OnRemoved()
		StopSoundOn("Hero_Bristleback.QuillSpray.Cast", self:GetCaster())
	end

	function modifier_quills:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if ability:GetAutoCastState() and caster:IsAlive() and ability:IsCooldownReady() and caster:GetMana() >= ability:GetManaCost(-1) then
			ability:Spray(false)
		end
	end
end

function modifier_quills:IsHidden() return true end

modifier_quills_enemy = class({})

function modifier_quills_enemy:OnRefresh(kv)
	self:AddIndependentStack(self:GetDuration(), self:GetTalentSpecialValueFor("quill_max_stacks"))
end

function modifier_quills_enemy:GetEffectName()
	return "particles/units/heroes/hero_bristleback/bristleback_quill_spray_hit.vpcf"
end

function modifier_quills_enemy:IsDebuff()
	return true
end