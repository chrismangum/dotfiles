-- Useless gap.
useless_gap = 25
if useless_gap > 0 then
    -- Top and left clients are shrinked by two steps and
    -- get moved away from the border. Other clients just
    -- get shrinked in one direction.

    top = false
    left = false

    if g.x == wa.x then
        top = true
    end

    if g.y == wa.y then
        left = true
    end

    if top then
        g.width = g.width - 2 * useless_gap
        g.x = g.x + useless_gap
    else
        g.width = g.width - useless_gap
    end

    if left then
        g.height = g.height - 2 * useless_gap
        g.y = g.y + useless_gap
    else
        g.height = g.height - useless_gap
    end
end
-- End of useless gap.
