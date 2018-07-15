
function shrinkRect(rc, xr, yr)

    local w = rc.width * xr;
    local h = rc.height * yr;
    local pt = cc.p(rc.x + rc.width * (1.0 - xr) / 2,
                     rc.y + rc.height * (1.0 - yr) / 2);
    return cc.rect(pt.x, pt.y, w, h);

end


function isSpriteInterset(sprite1, sprite2)

--[[
    -- 获取sprite碰撞区域
    rect1 = sprite1:getCollisionRect()
    rect2 = sprite2:getCollisionRect()
    
    
    return cc.rectIntersectsRect(rect1, rect2)
]]

    local points1 = getFitRectForSprite(sprite1);
    local bottomLeft1 = points1[1];
    local bottomRight1 = points1[2];
    local topLeft1 = points1[4];
    local topRight1 = points1[3];

    local points2 = getFitRectForSprite(sprite2);
    local bottomLeft2 = points2[1];
    local bottomRight2 = points2[2];
    local topLeft2 = points2[4];
    local topRight2 = points2[3];

    return isRectInterset(bottomLeft1, bottomRight1, topLeft1, topRight1, bottomLeft2, bottomRight2, topRight2, topLeft2);

end

function getFitRectForSprite(sprite)

    -- 设圆心C对应的复数为 a+bi ,圆上任一点P对应的复数为 x0+i*y0 ,P绕圆心C转过角度为α弧度后到Q,Q对应的复数为 x+yi ,
    -- 根据复数乘法的意义,CQ=CP*(cosα+i*sinα) ,
    -- 即 (x-a)+(y-b)i=[(x0-a)+(y0-b)i]*(cosα+i*sinα)=[(x0-a)cosα-(y0-b)sinα]+[(x0-a)sinα+(y0-b)cosα]*i
    -- 根据复数相等的定义,得
    -- x-a=(x0-a)cosα-(y0-b)sinα ,y-b=(x0-a)sinα+(y0-b)cosα ,
    -- 解得 x=a+(x0-a)cosα-(y0-b)sinα ,y=b+(x0-a)sinα+(y0-b)cosα .

    --for 0.5/0.5 need update
    local x = sprite:getPositionX();
    local y = sprite:getPositionY();
    local width = sprite:getContentSize().width;
    local height = sprite:getContentSize().height;
    local anchor = cc.p(x, y);
    local points = {
        cc.p(x-width/2, y-height/2),  -- point 1
        cc.p(x+width/2, y-height/2),  -- point 2
        cc.p(x+width/2, y+height/2), -- point 3
        cc.p(x-width/2, y+height/2), -- point 4
    }

    local angle = -sprite:getRotation();
    for i,point in ipairs(points) do
        local newPoint = cc.p(anchor.x+(point.x-anchor.x)*math.cos(angle)-(point.y-anchor.y)*math.sin(angle), anchor.y+(point.x-anchor.x)*math.sin(angle)+(point.y-anchor.y)*math.cos(angle) );
        points[i] = newPoint;
    end

    return points;

end

function isIntersetRect(rect1, rect2)

    local bottomLeft1 = rect1[1];
    local bottomRight1 = rect1[2];
    local topLeft1 = rect1[4];
    local topRight1 = rect1[3];

    local bottomLeft2 = rect2[1];
    local bottomRight2 = rect2[2];
    local topLeft2 = rect2[4];
    local topRight2 = rect2[3];

    return isRectInterset(bottomLeft1, bottomRight1, topLeft1, topRight1, bottomLeft2, bottomRight2, topRight2, topLeft2);

end

function isRectInterset(a1, b1, c1, d1, a2, b2, c2, d2)

    return intersect(a1, b1, a2, b2) or
    intersect(a1, b1, b2, c2) or
    intersect(a1, b1, c2, d2) or
    intersect(a1, b1, d2, a2) or
    
    intersect(b1, c1, a2, b2) or
    intersect(b1, c1, b2, c2) or
    intersect(b1, c1, c2, d2) or
    intersect(b1, c1, d2, a2) or
    
    intersect(c1, d1, a2, b2) or
    intersect(c1, d1, b2, c2) or
    intersect(c1, d1, c2, d2) or
    intersect(c1, d1, d2, a2) or
    
    intersect(d1, a1, a2, b2) or
    intersect(d1, a1, b2, c2) or
    intersect(d1, a1, c2, d2) or
    intersect(d1, a1, d2, a2);

end

function intersect(us, ue, vs, ve)
    --排斥实验 --跨立实验
    return( (MAX(us.x,ue.x)>=MIN(vs.x,ve.x)) and
           (MAX(vs.x,ve.x)>=MIN(us.x,ue.x)) and
           (MAX(us.y,ue.y)>=MIN(vs.y,ve.y)) and
           (MAX(vs.y,ve.y)>=MIN(us.y,ue.y)) and
           (multiply(vs,ue,us)*multiply(ue,ve,us)>=0) and
           (multiply(us,ve,vs)*multiply(ve,ue,vs)>=0));

end

function MAX(x, y)

    if x > y then
        return x;
    end
    return y;

end

function MIN(x, y)

    if x < y then
        return x;
    end
    return y;

end

function multiply(sp, ep, op)

    return((sp.x-op.x)*(ep.y-op.y)-(ep.x-op.x)*(sp.y-op.y));

end
