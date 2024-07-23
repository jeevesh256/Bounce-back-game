function love.load()
    love.window.setTitle("Bounce back")
    window = {}
    window.height = love.graphics.getHeight()
    window.width = love.graphics.getWidth()

    love.graphics.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())
    paddle_hit = love.audio.newSource("sounds/paddle_hit.wav", "static")
    wall_hit = love.audio.newSource("sounds/wall_hit.wav", "static")
    music = love.audio.newSource("sounds/music.mp3", "stream")
    music:setLooping(true)
    music:play()

    background = love.graphics.newImage("Assets/background.jpeg")
    bgWidth = background:getWidth()
    bgHeight = background:getHeight()

    sprite ={}
    sprite.sheet = love.graphics.newImage("Assets/paddles_and_balls.png")
    sprite.playerX = 64
    sprite.playerY = 39
    sprite.playerWidth = 32
    sprite.playerHeight = 9
    sprite.playerQuad = love.graphics.newQuad(sprite.playerX, sprite.playerY, sprite.playerWidth, sprite.playerHeight, sprite.sheet:getDimensions())
    
    sprite.ballX = 144
    sprite.ballY = 8
    sprite.ballWidth = 7
    sprite.ballHeight = 7
    sprite.ballQuad = love.graphics.newQuad(sprite.ballX, sprite.ballY, sprite.ballWidth, sprite.ballHeight, sprite.sheet:getDimensions())

    player = {}
    player.width = 130
    player.height = 36
    player.x = (window.width - player.width) / 2
    player.y = (window.height - player.height) - 5
    player.speed = 1000

    ball = {}
    ball.width = 28
    ball.height = 28
    ball.x = window.width / 2
    ball.y = window.height / 2
    ball.dx = math.random(300, -300)
    ball.dy = math.random(2) == 1 and 150 or -150
    ball.maxSpeed1 = 1100
    ball.maxSpeed2 = 1300
    
    positions = {}
    maxPositions = 500
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

    if gameState == "play" or gameState == "assist" then
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt
    end

    if gameState == "reset" then
        ball.x = window.width / 2
        ball.y = window.height / 2
        ball.dx = math.random(300, -300)
        ball.dy = math.random(2) == 1 and 150 or -150
    end

    if gameState == "assist" then
        if love.keyboard.isDown("b") then
            -- Reverse the ball's position
            if #positions > 0 then
                local pos = table.remove(positions)
                ball.x = pos.x
                ball.y = pos.y
                ball.dx = -ball.dx
                ball.dy = -ball.dy
            end
        else
            -- Store the current position
            table.insert(positions, { x = ball.x, y = ball.y })

            -- Limit the number of stored positions
            if #positions > maxPositions then
                table.remove(positions, 1)
            end
        end
    end

    --ball offset
    if ball.y < 0 then
        wall_hit:play()
        ball.y = 0
        ball.dy = -ball.dy
    elseif ball.x < 0 then
        wall_hit:play()
        ball.x = 0
        ball.dx = -ball.dx
    elseif ball.x + ball.width > window.width then
        wall_hit:play()
        ball.x = window.width -ball.width
        ball.dx = -ball.dx
    end

    if isColliding(ball, player) then
        paddle_hit:stop()
        paddle_hit:play()

        ball.y = player.y - ball.height
        ball.dy = -ball.dy * 1.2

        local angleAdjust = math.rad(math.random(-30, 30))
        local speed = math.sqrt(ball.dx^2 + ball.dy^2)
        local newAngle = math.atan2(ball.dy, ball.dx) + angleAdjust
        ball.dx = math.cos(newAngle) * speed
        ball.dy = math.sin(newAngle) * speed

        if speed > ball.maxSpeed1 then
            local normal = ball.maxSpeed1 / speed
            ball.dx = ball.dx * normal
            ball.dy = ball.dy * normal
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()

    elseif key == "enter" or key =="return" and gameState == "assist" then
        gameState = "assist"

    elseif key == "enter" or key =="return" then
        gameState = "play"

    elseif key == "r" then
        gameState = "reset"

    elseif key == "space" and gameState == "pause" then
        music:play()
        gameState = "play"

    elseif key == "space" then
        music:stop()
        gameState = "pause"

    elseif key == "a" and gameState == "assist" then
        ball.dx = math.random(300, -300)
        ball.dy = math.random(2) == 1 and 150 or -150
        gameState = "play"

    elseif key =="a" then
        gameState = "assist"
    end
end

function isColliding(ball, player)
    return ball.x + ball.width > player.x and ball.x < player.x + player.width and ball.y + ball.height > player.y and ball.y < player.y + player.height
end

function love.draw()
    love.graphics.draw(background, 0, 0, 0, window.width / bgWidth, window.height / bgHeight)
    love.graphics.draw(sprite.sheet, sprite.playerQuad, player.x, player.y, 0, 4, 4)
    love.graphics.draw(sprite.sheet, sprite.ballQuad, ball.x, ball.y, 0, 3, 3)
    if gameState == "assist" then
        love.graphics.print("ASSIST mode ON")
    else 
        love.graphics.print("ASSIST mode OFF")
    end
end