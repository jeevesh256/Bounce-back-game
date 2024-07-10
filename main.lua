function love.load()
    love.window.setTitle("Bounce back")
    window = {}
    window.height = love.graphics.getHeight()
    window.width = love.graphics.getWidth()

    math.randomseed(os.time())
    sound = love.audio.newSource("coin", "static")

    player = {}
    player.width = 150
    player.height = 30
    player.x = (window.width - player.width) / 2
    player.y = (window.height - player.height) - 5
    player.speed = 1000

    ball = {}
    ball.radius = 15
    ball.x = window.width / 2
    ball.y = window.height / 2
    ball.dx = math.random(300, -300)
    ball.dy = math.random(2) == 1 and 150 or -150
    ball.maxSpeed = 1100

    gameState = "start"
end

function love.update(dt)
    --player movement
    if love.keyboard.isDown("left") then
            player.x = player.x - player.speed * dt
    end

    if love.keyboard.isDown("right") then
            player.x = player.x + player.speed * dt
    end

    --player offset
    if player.x < 0 then
        player.x = 0
    elseif player.x + player.width > window.width then
        player.x = window.width - player.width
    end

    if gameState == "play" then
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt
    end

    if gameState == "reset" then
        ball.x = window.width / 2
        ball.y = window.height / 2
        ball.dx = math.random(300, -300)
        ball.dy = math.random(2) == 1 and 150 or -150
    end

    --ball offset
    if ball.y < ball.radius then
        ball.y = ball.radius
        ball.dy = -ball.dy
    elseif ball.x < ball.radius then
        ball.x = ball.radius
        ball.dx = -ball.dx
    elseif ball.x + ball.radius > window.width then
        ball.x = window.width -ball.radius
        ball.dx = -ball.dx
    end

    if isColliding(ball, player) then
        sound:stop()
        sound:play()

        ball.y = player.y -ball.radius
        ball.dy = -ball.dy * 1.2

        local angleAdjust = math.rad(math.random(-30, 30))
        local speed = math.sqrt(ball.dx^2 + ball.dy^2)
        local newAngle = math.atan2(ball.dy, ball.dx) + angleAdjust
        ball.dx = math.cos(newAngle) * speed
        ball.dy = math.sin(newAngle) * speed

        if speed > ball.maxSpeed then
            local normal = ball.maxSpeed / speed
            ball.dx = ball.dx * normal
            ball.dy = ball.dy * normal
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "enter" or key =="return" then
        gameState = "play"
    elseif key == "r" then
        gameState = "reset"
    elseif key == "space" and gameState == "pause" then
        gameState = "play"
    elseif key == "space" then
        gameState = "pause"
    end
end

function isColliding(ball, player)
    return ball.x + ball.radius > player.x and ball.x - ball.radius < player.x + player.width and ball.y + ball.radius > player.y and ball.y - ball.radius < player.y + player.height
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
end