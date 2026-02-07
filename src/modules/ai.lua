-- Halol (V4.0) AI 模組
---@diagnostic disable: undefined-global, deprecated, undefined-field
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local lp = Players.LocalPlayer
local task_spawn = task.spawn
local task_wait = task.wait
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new

local AIModule = {}

function AIModule.Init(CatFunctions, Blatant)
    -- God Mode AI
    local function ToggleGodMode(state)
        _G.GodModeAI = state
        if _G.GodModeAI then
            _G.KillAuraRange = 25
            _G.KillAuraMaxTargets = 5
            CatFunctions.ToggleKillAura(true)
            CatFunctions.ToggleNoFall(true)
            CatFunctions.ToggleReach(true)
            CatFunctions.ToggleAutoToolFastBreak(true)
            _G.AutoBuyPro = true
            _G.AutoArmor = true
            Blatant.ToggleAutoBuyPro(true)
            Blatant.ToggleAutoArmor(true)
            
            task_spawn(function()
                while _G.GodModeAI and task_wait(0.02) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local battlefield = CatFunctions.GetBattlefieldState()
                        local target = nil
                        local minDist = math.huge
                        
                        if battlefield.isBeingTargeted then
                            hrp.Velocity = hrp.Velocity + Vector3_new(math.random(-2, 2), 0, math.random(-2, 2))
                        end

                        if battlefield.nearestThreat and battlefield.nearestThreat.dist < 15 then
                            target = {part = battlefield.nearestThreat.hrp, type = "PLAYER"}
                        else
                            for _, v in ipairs(workspace:GetDescendants()) do
                                if v.Name == "bed" and v:IsA("BasePart") then
                                    local team = v:GetAttribute("Team")
                                    if team ~= lp.Team then
                                        local dist = (hrp.Position - v.Position).Magnitude
                                        if dist < minDist then
                                            minDist = dist
                                            target = {part = v, type = "BED"}
                                        end
                                    end
                                end
                            end
                            if not target and battlefield.nearestThreat then
                                target = {part = battlefield.nearestThreat.hrp, type = "PLAYER"}
                            end
                        end
                        
                        if target then
                            local targetPos = target.part.Position
                            local dist = (hrp.Position - targetPos).Magnitude
                            
                            -- 基礎移動邏輯：如果距離 > 4，則朝向目標移動
                            if dist > 4 then
                                local moveDir = (targetPos - hrp.Position).Unit
                                if hum then
                                    hum:Move(moveDir, true)
                                end
                                
                                -- 遇到障礙物自動跳躍
                                local ray = Ray.new(hrp.Position, moveDir * 3)
                                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                                if hit and hit.CanCollide then
                                    hum.Jump = true
                                end
                            else
                                if hum then hum:Move(Vector3_new(0,0,0), true) end
                            end

                            -- 強制 KillAura 攻擊當前目標 (如果是玩家)
                            if target.type == "PLAYER" and _G.KillAura then
                                -- 確保看向目標以便攻擊
                                hrp.CFrame = CFrame_new(hrp.Position, Vector3_new(targetPos.X, hrp.Position.Y, targetPos.Z))
                            end
                        else
                            if hum then hum:Move(Vector3_new(0,0,0), true) end
                        end
                    end
                end
            end)
        end
    end

    -- Auto Play AI (基礎 Pathfinding 實作)
    local function ToggleAutoPlay(state)
        _G.AI_Enabled = state
        if _G.AI_Enabled then
            _G.KillAuraRange = 22
            _G.KillAuraMaxTargets = 3
            CatFunctions.ToggleKillAura(true)
            CatFunctions.ToggleNoFall(true)
            CatFunctions.ToggleAutoToolFastBreak(true)
            CatFunctions.ToggleSpeed(true) -- 開啟速度以利追擊
            _G.AutoBuyPro = true
            _G.AutoArmor = true
            Blatant.ToggleAutoBuyPro(true)
            Blatant.ToggleAutoArmor(true)
            
            task_spawn(function()
                while _G.AI_Enabled and task_wait(0.1) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local battlefield = CatFunctions.GetBattlefieldState()
                        local target = nil
                        
                        -- 優先級：
                        -- 1. 附近的資源 (如果距離小於 15，優先撿取)
                        -- 2. 最近的威脅 (玩家)
                        -- 3. 遠處的資源 (鑽石/綠寶石優先)
                        -- 4. 敵方床位
                        
                        local nearResource = nil
                        for _, res in ipairs(battlefield.resources) do
                            if res.dist < 15 then
                                nearResource = res
                                break
                            end
                        end

                        if nearResource then
                             target = {part = nearResource.part, type = "RESOURCE"}
                             -- 如果已經很近了，稍微停一下確保收集到
                             if nearResource.dist < 5 then
                                 hum:Move(Vector3_new(0,0,0), true)
                                 task_wait(0.5)
                             end
                        elseif battlefield.nearestThreat and battlefield.nearestThreat.dist < 60 then
                            target = {part = battlefield.nearestThreat.hrp, type = "PLAYER"}
                        elseif #battlefield.resources > 0 then
                            -- 優先尋找鑽石或綠寶石
                            local bestRes = battlefield.resources[1]
                            for _, res in ipairs(battlefield.resources) do
                                local name = res.name:lower()
                                if name:find("emerald") or name:find("diamond") then
                                    bestRes = res
                                    break
                                end
                            end
                            target = {part = bestRes.part, type = "RESOURCE"}
                        else
                            -- 尋找敵方床位
                            for _, v in ipairs(workspace:GetDescendants()) do
                                if v.Name == "bed" and v:IsA("BasePart") then
                                    local team = v:GetAttribute("Team")
                                    if team ~= lp.Team then
                                        target = {part = v, type = "BED"}
                                        break
                                    end
                                end
                            end
                        end

                        if target then
                            local path = PathfindingService:CreatePath({AgentHeight = 5, AgentRadius = 3, AgentCanJump = true})
                            local success, errorMessage = pcall(function()
                                path:ComputeAsync(hrp.Position, target.part.Position)
                            end)

                            if success and path.Status == Enum.PathStatus.Success then
                                local waypoints = path:GetWaypoints()
                                if #waypoints > 1 then
                                    local nextWaypoint = waypoints[2]
                                    local moveDir = (nextWaypoint.Position - hrp.Position).Unit
                                    hum:Move(moveDir, true)
                                    
                                    if nextWaypoint.Action == Enum.PathWaypointAction.Jump then
                                        hum.Jump = true
                                    end

                                    -- 如果是戰鬥狀態，強制看向目標
                                    if target.type == "PLAYER" then
                                        hrp.CFrame = CFrame_new(hrp.Position, Vector3_new(target.part.Position.X, hrp.Position.Y, target.part.Position.Z))
                                    end
                                end
                            else
                                -- Pathfinding 失敗時使用基礎移動
                                local moveDir = (target.part.Position - hrp.Position).Unit
                                hum:Move(moveDir, true)
                            end

                            -- 防掉落 AI 回歸邏輯 (Anti-Void AI)
                            if hrp.Position.Y < 0 then -- 假設 0 以下是虛空
                                local spawnPos = lp.RespawnLocation and lp.RespawnLocation.Position or Vector3_new(0, 100, 0)
                                if (hrp.Position - spawnPos).Magnitude > 50 then
                                    -- 如果掉下去了，嘗試開啟飛行或直接傳送回出生點 (如果功能允許)
                                    if CatFunctions.ToggleFly then
                                        CatFunctions.ToggleFly(true)
                                        hrp.Velocity = Vector3_new(0, 50, 0)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    return {
        ToggleGodMode = ToggleGodMode,
        ToggleAutoPlay = ToggleAutoPlay
    }
end

return AIModule
