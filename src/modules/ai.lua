---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
local getgenv = (getgenv or function() return _G end)
local env_global = getgenv()
local game = game or env_global.game
local workspace = workspace or env_global.workspace
local task = task or env_global.task
local Vector3 = Vector3 or env_global.Vector3
local CFrame = CFrame or env_global.CFrame
local Ray = Ray or env_global.Ray
local Enum = Enum or env_global.Enum
local math = math or env_global.math
local ipairs = ipairs or env_global.ipairs
local pairs = pairs or env_global.pairs
local pcall = pcall or env_global.pcall

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
    local function ToggleGodMode(state)
        env_global.GodModeAI = state
        if env_global.GodModeAI then
            env_global.KillAuraRange = 25
            env_global.KillAuraMaxTargets = 5
            CatFunctions.ToggleKillAura(true)
            CatFunctions.ToggleNoFall(true)
            CatFunctions.ToggleReach(true)
            CatFunctions.ToggleAutoToolFastBreak(true)
            env_global.AutoBuyPro = true
            env_global.AutoArmor = true
            Blatant.ToggleAutoBuyPro(true)
            Blatant.ToggleAutoArmor(true)
            
            local lastPos = Vector3_new(0,0,0)
            local lastMoveTime = tick()

            task_spawn(function()
                while env_global.GodModeAI and task_wait(0.02) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        if hum.WalkSpeed < 20 then hum.WalkSpeed = 20 end
                        hum.AutoRotate = true
                        
                        if (hrp.Position - lastPos).Magnitude < 0.1 then
                            if tick() - lastMoveTime > 3 then
                                hum.Jump = true
                                lastMoveTime = tick()
                            end
                        else
                            lastPos = hrp.Position
                            lastMoveTime = tick()
                        end

                        local state = CatFunctions.GetBattlefieldState()
                        local target = nil
                        
                        if state.nearestThreat then
                            target = state.nearestThreat
                        elseif #state.beds > 0 then
                            target = state.beds[1]
                        elseif #state.resources > 0 then
                            target = state.resources[1]
                        end

                        if target then
                            local targetPos = target.part.Position
                            local dist = (hrp.Position - targetPos).Magnitude

                            if target.type == "BED" and dist > 15 then
                                if not env_global.Fly then CatFunctions.ToggleFly(true) end
                            elseif env_global.Fly and dist < 5 then
                                CatFunctions.ToggleFly(false)
                            end

                            if dist > 4 then
                                local moveDir = (targetPos - hrp.Position).Unit
                                
                                if env_global.Fly then
                                    hum:Move(moveDir, true)
                                    hum:MoveTo(targetPos)
                                else
                                    moveDir = Vector3_new(moveDir.X, 0, moveDir.Z).Unit
                                    
                                    if dist > 15 then
                                        local path = PathfindingService:CreatePath({AgentHeight = 5, AgentRadius = 2, AgentCanJump = true, WaypointSpacing = 4})
                                        local success = pcall(function() path:ComputeAsync(hrp.Position, targetPos) end)
                                        if success and path.Status == Enum.PathStatus.Success then
                                            local waypoints = path:GetWaypoints()
                                            if #waypoints > 1 then
                                                moveDir = (waypoints[2].Position - hrp.Position).Unit
                                                moveDir = Vector3_new(moveDir.X, 0, moveDir.Z).Unit
                                                if waypoints[2].Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                                            end
                                        end
                                    end

                                    if hum then
                                        hum:Move(moveDir, true)
                                        hum:MoveTo(hrp.Position + moveDir * 5)
                                    end
                                end
                                
                                local ray = Ray.new(hrp.Position, moveDir * 3)
                                local hit = workspace:FindPartOnRay(ray, char)
                                if hit then hum.Jump = true end
                            end
                            
                            if target.type == "PLAYER" then
                                env_global.KillAuraTarget = target.part.Parent
                            end
                        end
                    end
                end
            end)
        else
            CatFunctions.ToggleKillAura(false)
            CatFunctions.ToggleFly(false)
        end
    end

    local function ToggleAutoPlay(state)
        env_global.AI_Enabled = state
        if env_global.AI_Enabled then
            task_spawn(function()
                while env_global.AI_Enabled and task_wait(0.5) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if hrp and hum and hum.Health > 0 then
                        local state = CatFunctions.GetBattlefieldState()
                        local target = nil

                        if state.nearestThreat then
                            target = state.nearestThreat
                        elseif #state.beds > 0 then
                            target = state.beds[1]
                        elseif #state.resources > 0 then
                            target = state.resources[1]
                        end

                        if target then
                            local targetPos = target.part.Position
                            local dist = (hrp.Position - targetPos).Magnitude

                            if target.type == "BED" and dist > 15 then
                                if not env_global.Fly then CatFunctions.ToggleFly(true) end
                            elseif env_global.Fly and dist < 5 then
                                CatFunctions.ToggleFly(false)
                            end

                            if env_global.Fly then
                                local moveDir = (targetPos - hrp.Position).Unit
                                hum:Move(moveDir, true)
                                hum:MoveTo(targetPos)
                            else
                                local path = PathfindingService:CreatePath({AgentHeight = 5, AgentRadius = 2, AgentCanJump = true, WaypointSpacing = 4})
                                local success, errorMessage = pcall(function()
                                    path:ComputeAsync(hrp.Position, targetPos)
                                end)

                                if success and path.Status == Enum.PathStatus.Success then
                                    local waypoints = path:GetWaypoints()
                                    if #waypoints > 1 then
                                        local nextWaypoint = waypoints[2]
                                        local moveDir = (nextWaypoint.Position - hrp.Position).Unit
                                        moveDir = Vector3_new(moveDir.X, 0, moveDir.Z).Unit -- Flatten movement
                                        hum:Move(moveDir, true)
                                        hum:MoveTo(nextWaypoint.Position)
                                        
                                        if nextWaypoint.Action == Enum.PathWaypointAction.Jump then
                                            hum.Jump = true
                                        end

                                        if target.type == "PLAYER" then
                                            hrp.CFrame = CFrame_new(hrp.Position, Vector3_new(target.part.Position.X, hrp.Position.Y, target.part.Position.Z))
                                            env_global.KillAuraTarget = target.part.Parent
                                        
                                        end
                                    end
                                else
                                    local moveDir = (targetPos - hrp.Position).Unit
                                    moveDir = Vector3_new(moveDir.X, 0, moveDir.Z).Unit -- Flatten movement
                                    hum:Move(moveDir, true)
                                    hum:MoveTo(targetPos)
                                end
                            end
                        end
                    end
                end
            end)
        else
            CatFunctions.ToggleFly(false)
            CatFunctions.ToggleKillAura(false)
        end
    end

    return {
        ToggleGodMode = ToggleGodMode,
        ToggleAutoPlay = ToggleAutoPlay,
        Stop = function()
            ToggleGodMode(false)
            ToggleAutoPlay(false)
        end
    }
end

return AIModule
