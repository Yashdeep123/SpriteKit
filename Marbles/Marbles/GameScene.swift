//
//  GameScene.swift
//  Marbles
//
//  Created by Yash Patil on 16/08/22.
//
import CoreMotion
import SpriteKit



class Ball : SKSpriteNode { }



class GameScene: SKScene {
    
   let balls = ["ballPurple","ballRed","ballYellow","ballBlue","ballGrey","ballGreen","ballCyan"]
    
   var motionManager : CMMotionManager?
    
    let scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    var matchedBalls = Set<Ball>()
    
    var score = 0 {
        didSet
        {
          let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "SCORE : \(formattedScore)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
        
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: 20, y: 20)
        scoreLabel.text = "SCORE : 0"
        scoreLabel.zPosition = 100
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        
        let ball = SKSpriteNode(imageNamed: "ballBlue")
        let ballRadius = ball.frame.width / 2.0
        
        
        for i in stride(from: ballRadius, to: view.bounds.width - ballRadius, by: ball.frame.width)
        {
            for j in stride(from: 100, to: view.bounds.height - ballRadius, by: ball.frame.height)
            {
                let ballType = balls.randomElement()!
                let ball = Ball(imageNamed: ballType)
                
                ball.position = CGPoint(x: i, y: j)
                ball.name = ballType
                
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
                ball.physicsBody?.friction = 0
                ball.physicsBody?.restitution = 0
                ball.physicsBody?.allowsRotation = false
                ball.physicsBody?.angularDamping = 45.5
                addChild(ball)
            }
        }
        
        
        background.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 10)))
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top:100,left:0,bottom:0, right:0)))
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        
        
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx:accelerometerData.acceleration.y * -50 , dy: accelerometerData.acceleration.x * 50)
        }
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let position = touches.first?.location(in: self) else {return }
        guard let tappedBall = nodes(at: position).first(where: {$0 is Ball}) as? Ball else {return}
        
        matchedBalls.removeAll(keepingCapacity: true)
        
        getMatches(from: tappedBall)
        
        if matchedBalls.count >= 3 {
            
            score += Int(pow(2,Double(matchedBalls.count)))
            
            for ball in matchedBalls
            {
                if let particles = SKEmitterNode(fileNamed: "Explosion")
                {
                    particles.position = ball.position
                    addChild(particles)
                    let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3),SKAction.removeFromParent()])
                    
                    particles.run(removeAfterDead)
                }
                ball.removeFromParent()
            }
        }
        
        if matchedBalls.count >= 5 {
            
            let omg = SKSpriteNode(imageNamed: "omg")
            omg.position = CGPoint(x:frame.midX , y:frame.midY)
            omg.zPosition = 100
            omg.xScale = 0.05
            omg.yScale = 0.05
            addChild(omg)
            
            let appear = SKAction.group([SKAction.scale(to: 0.5, duration: 0.25),SKAction.fadeIn(withDuration: 0.25)])
            let disappear = SKAction.group([SKAction.scale(to: 1.0, duration: 0.25),SKAction.fadeOut(withDuration: 0.25)])
            
            let sequence = SKAction.sequence([appear,disappear])
            omg.run(sequence)
        }
        
    }
    
    
    func getMatches(from startBall : Ball)
    {
        let matchWidth = startBall.frame.width * startBall.frame.width * 1.1
        
        for node in children {
            guard let ball = node as? Ball else {continue}
            guard ball.name == startBall.name else {continue}
            
            let dist = distance(from: startBall, to: ball)
            
            guard dist < matchWidth else {continue}
            
            if !matchedBalls.contains(ball)
            {
                matchedBalls.insert(ball)
                getMatches(from: ball)
            }
        }
    }
    
    
    func distance(from : Ball, to : Ball) -> CGFloat
    {
        return (from.position.x - to.position.x) * (from.position.x - to.position.x) + (from.position.y - to.position.y) * (from.position.y - to.position.y)
    }
   
}
