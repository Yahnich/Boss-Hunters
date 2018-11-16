mk_mischief = class({})
LinkLuaModifier("modifier_mk_mischief", "heroes/hero_monkey_king/mk_mischief", LUA_MODIFIER_MOTION_NONE)

function mk_mischief:IsStealable()
	return true
end

function mk_mischief:IsHiddenWhenStolen()
	return false
end

function mk_mischief:OnSpellStart()
	local caster = self:GetCaster()
	
	ParticleManager:FireParticle("particles/units/heroes/hero_monkey_king/monkey_king_disguise.vpcf", PATTACH_POINT, caster, {})
	
	if caster:HasModifier("modifier_mk_mischief") then
		EmitSoundOn("Hero_MonkeyKing.Transform.Off", caster)
		caster:RemoveModifierByName("modifier_mk_mischief")
	else
		EmitSoundOn("Hero_MonkeyKing.Transform.On", caster)
		caster:RemoveModifierByName("modifier_mk_tree_perch")
		caster:AddNewModifier(caster, self, "modifier_mk_mischief", {Duration = 30})
		self:EndCooldown()
	end
end

modifier_mk_mischief = class({})
function modifier_mk_mischief:OnCreated(table)
	local possibleModels = {
							"models/props_gameplay/pig.vmdl",
							"models/props_gameplay/chicken.vmdl",
							"models/props_gameplay/frog.vmdl",
							"models/items/hex/sheep_hex/sheep_hex.vmdl",
							"models/items/hex/fish_hex/fish_hex.vmdl",
							"models/creeps/greevil_shopkeeper/greevil_shopkeeper.vmdl",
							"models/pets/armadillo/armadillo.vmdl",
							"models/pets/icewrack_wolf/icewrack_wolf.vmdl"
							}

	self.model = possibleModels[ math.random( #possibleModels ) ]
end

function modifier_mk_mischief:DeclareFunctions()
	return {MODIFIER_PROPERTY_MODEL_CHANGE,
			MODIFIER_EVENT_ON_ATTACK,
        	MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        	MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_mk_mischief:OnTakeDamage(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_mk_mischief:OnAbilityExecuted(params)
	if IsServer() then
		if params.unit == self:GetParent() and params.ability ~= self:GetAbility() then
			self:Destroy()
		end
	end
end

function modifier_mk_mischief:OnAttack(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_mk_mischief:GetModifierModelChange()
	return self.model
end

function modifier_mk_mischief:IsDebuff()
	return false
end
