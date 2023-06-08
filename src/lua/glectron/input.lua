local lastMouseX, lastMouseY
hook.Add("Think", "GlectronMouseDetector", function()
    local x, y = gui.MouseX(), gui.MouseY()
    if x ~= lastMouseX or y ~= lastMouseY then
        lastMouseX = x
        lastMouseY = y
        hook.Run("GlectronMouseMove", x, y)
    end
end)

hook.Add("GlectronMouseMove", "GlectronApplicationMouseMoveHandler", function(x, y)
    for _,v in pairs(Glectron.Applications) do
        v:MouseMove(x, y)
    end
end)