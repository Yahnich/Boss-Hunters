modifier_skeleton_king_reincarnation_cooldown = class({})
if IsServer() then
	function modifier_skeleton_king_reincarnation_cooldown:OnCreated(params)
		self:StartIntervalThink(0.03)
	end

	function modifier_skeleton_king_reincarnation_cooldown:IsHidden()
		return true
	end

	function modifier_skeleton_king_reincarnation_cooldown:RemoveOnDeath()
		return false
	end

	function modifier_skeleton_king_reincarnation_cooldown:OnIntervalThink()
		if self:GetAbility():IsCooldownReady() then
			self:Destroy()
		end
	end
end