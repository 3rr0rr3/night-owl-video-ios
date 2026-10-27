import SwiftUI

enum PlayerPalette {
    static let shirt = Color(red:0.24,green:0.30,blue:0.43)
    static let skin = Color(red:0.84,green:0.69,blue:0.57)
    static let hair = Color(red:0.17,green:0.13,blue:0.12)
}

struct PlayerPortrait: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var phase
    var body: some View {
        TimelineView(.animation(minimumInterval:1.0/20,paused:reduceMotion || phase != .active)) { clock in
            let time = reduceMotion ? 0 : clock.date.timeIntervalSinceReferenceDate
            let blink = !reduceMotion && time.truncatingRemainder(dividingBy:4.9) > 4.73
            Canvas { context,_ in
                func oval(_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat) -> Path { Path(ellipseIn:CGRect(x:x,y:y,width:w,height:h)) }
                func polygon(_ points:[CGPoint]) -> Path { var p = Path(); p.addLines(points); p.closeSubpath(); return p }
                func draw(_ path:Path,_ color:Color,_ width:CGFloat = 1.4) { context.fill(path,with:.color(color)); context.stroke(path,with:.color(ink),style:StrokeStyle(lineWidth:width,lineCap:.round,lineJoin:.round)) }
                func line(_ points:[CGPoint],_ color:Color = ink,_ width:CGFloat = 1) { var p = Path(); p.addLines(points); context.stroke(p,with:.color(color),style:StrokeStyle(lineWidth:width,lineCap:.round,lineJoin:.round)) }
                let skin = PlayerPalette.skin
                let hair = PlayerPalette.hair
                let shirt = PlayerPalette.shirt
                context.fill(oval(9,123,62,6),with:.color(.black.opacity(0.2)))
                draw(polygon([CGPoint(x:20,y:96),CGPoint(x:60,y:96),CGPoint(x:58,y:121),CGPoint(x:44,y:121),CGPoint(x:40,y:103),CGPoint(x:36,y:121),CGPoint(x:22,y:121)]),Color(red:0.18,green:0.22,blue:0.29))
                draw(Path(roundedRect:CGRect(x:18,y:119,width:20,height:7),cornerRadius:2),ink)
                draw(Path(roundedRect:CGRect(x:43,y:119,width:20,height:7),cornerRadius:2),ink)
                draw(Path(roundedRect:CGRect(x:32,y:49,width:17,height:19),cornerRadius:4),skin)
                draw(polygon([CGPoint(x:30,y:60),CGPoint(x:17,y:64),CGPoint(x:7,y:75),CGPoint(x:11,y:89),CGPoint(x:21,y:87),CGPoint(x:20,y:100),CGPoint(x:60,y:100),CGPoint(x:59,y:87),CGPoint(x:69,y:89),CGPoint(x:74,y:75),CGPoint(x:63,y:64),CGPoint(x:50,y:60),CGPoint(x:40,y:67)]),shirt,1.7)
                draw(Path(roundedRect:CGRect(x:11,y:86,width:10,height:20),cornerRadius:4),skin)
                draw(Path(roundedRect:CGRect(x:60,y:86,width:10,height:20),cornerRadius:4),skin)
                let collar = Path { p in p.move(to:CGPoint(x:29,y:61)); p.addQuadCurve(to:CGPoint(x:51,y:61),control:CGPoint(x:40,y:77)) }
                context.stroke(collar,with:.color(ink.opacity(0.65)),lineWidth:2)
                line([CGPoint(x:24,y:76),CGPoint(x:23,y:96)],ink.opacity(0.25),0.7)
                line([CGPoint(x:57,y:77),CGPoint(x:58,y:96)],ink.opacity(0.25),0.7)
                draw(oval(16,29,8,16),skin); draw(oval(57,29,8,16),skin)
                let face = Path { p in
                    p.move(to:CGPoint(x:21,y:20)); p.addQuadCurve(to:CGPoint(x:59,y:20),control:CGPoint(x:40,y:1))
                    p.addLine(to:CGPoint(x:61,y:40)); p.addQuadCurve(to:CGPoint(x:53,y:54),control:CGPoint(x:59,y:50))
                    p.addQuadCurve(to:CGPoint(x:40,y:60),control:CGPoint(x:47,y:60)); p.addQuadCurve(to:CGPoint(x:26,y:54),control:CGPoint(x:31,y:59))
                    p.addQuadCurve(to:CGPoint(x:20,y:40),control:CGPoint(x:21,y:49)); p.closeSubpath()
                }
                draw(face,skin,1.6)
                // Closely cropped sides and an asymmetrical swept fringe.
                context.fill(polygon([CGPoint(x:20,y:20),CGPoint(x:25,y:18),CGPoint(x:24,y:37),CGPoint(x:21,y:40)]),with:.color(hair.opacity(0.5)))
                context.fill(polygon([CGPoint(x:56,y:18),CGPoint(x:61,y:20),CGPoint(x:60,y:40),CGPoint(x:57,y:36)]),with:.color(hair.opacity(0.5)))
                draw(polygon([CGPoint(x:19,y:30),CGPoint(x:17,y:18),CGPoint(x:22,y:9),CGPoint(x:19,y:6),CGPoint(x:30,y:8),CGPoint(x:39,y:3),CGPoint(x:37,y:1),CGPoint(x:50,y:4),CGPoint(x:58,y:2),CGPoint(x:56,y:8),CGPoint(x:63,y:10),CGPoint(x:60,y:13),CGPoint(x:62,y:25),CGPoint(x:58,y:29),CGPoint(x:55,y:17),CGPoint(x:48,y:16),CGPoint(x:35,y:22),CGPoint(x:25,y:23),CGPoint(x:23,y:31)]),hair,1.1)
                line([CGPoint(x:25,y:16),CGPoint(x:36,y:12),CGPoint(x:49,y:9)],Color(red:0.28,green:0.21,blue:0.18),1.1)
                line([CGPoint(x:29,y:19),CGPoint(x:42,y:15),CGPoint(x:54,y:11)],Color(red:0.28,green:0.21,blue:0.18),0.7)
                let beard = Path { p in
                    p.move(to:CGPoint(x:22,y:37)); p.addLine(to:CGPoint(x:27,y:42)); p.addLine(to:CGPoint(x:30,y:45)); p.addQuadCurve(to:CGPoint(x:50,y:44),control:CGPoint(x:40,y:41)); p.addLine(to:CGPoint(x:58,y:37)); p.addLine(to:CGPoint(x:57,y:48)); p.addQuadCurve(to:CGPoint(x:40,y:59),control:CGPoint(x:53,y:58)); p.addQuadCurve(to:CGPoint(x:24,y:49),control:CGPoint(x:28,y:58)); p.closeSubpath()
                }
                context.fill(beard,with:.color(Color(red:0.28,green:0.21,blue:0.17)))
                for n in 0..<15 { let x=CGFloat(26+(n*7)%29); let y=CGFloat(46+(n*3)%9); context.fill(oval(x,y,0.8,1.2),with:.color(hair.opacity(0.45))) }
                if blink { line([CGPoint(x:27,y:33),CGPoint(x:35,y:33)],ink,1.2); line([CGPoint(x:46,y:33),CGPoint(x:54,y:33)],ink,1.2) }
                else {
                    draw(oval(25,29,12,8),.white,0.5); draw(oval(44,29,12,8),.white,0.5)
                    context.fill(oval(30,30,4,6),with:.color(Color(red:0.24,green:0.16,blue:0.12)))
                    context.fill(oval(48,30,4,6),with:.color(Color(red:0.24,green:0.16,blue:0.12)))
                }
                line([CGPoint(x:25,y:26),CGPoint(x:35,y:25)],hair,2)
                line([CGPoint(x:45,y:25),CGPoint(x:55,y:27)],hair,2)
                let glasses = Color(red:0.08,green:0.075,blue:0.08)
                context.stroke(Path(roundedRect:CGRect(x:21,y:27,width:19,height:15),cornerRadius:3),with:.color(glasses),lineWidth:2.2)
                context.stroke(Path(roundedRect:CGRect(x:42,y:27,width:19,height:15),cornerRadius:3),with:.color(glasses),lineWidth:2.2)
                line([CGPoint(x:40,y:31),CGPoint(x:42,y:31)],glasses,2)
                line([CGPoint(x:18,y:29),CGPoint(x:21,y:30)],glasses,2)
                line([CGPoint(x:61,y:30),CGPoint(x:63,y:29)],glasses,2)
                line([CGPoint(x:39,y:33),CGPoint(x:37,y:41),CGPoint(x:42,y:42)],Color(red:0.54,green:0.39,blue:0.31),0.9)
                let moustache = polygon([CGPoint(x:31,y:45),CGPoint(x:36,y:42),CGPoint(x:40,y:43),CGPoint(x:44,y:42),CGPoint(x:51,y:45),CGPoint(x:49,y:48),CGPoint(x:41,y:46),CGPoint(x:33,y:48)])
                context.fill(moustache,with:.color(hair))
                let smile = Path { p in p.move(to:CGPoint(x:32,y:49)); p.addQuadCurve(to:CGPoint(x:50,y:48),control:CGPoint(x:41,y:54)) }
                context.stroke(smile,with:.color(skin),style:StrokeStyle(lineWidth:1.5,lineCap:.round))
            }.frame(width:80,height:130)
                .scaleEffect(x:1,y:1 + (reduceMotion ? 0 : sin(time*1.8)*0.006),anchor:.bottom)
        }.accessibilityLabel("Your illustrated shopkeeper: swept dark hair, black rectangular glasses, short beard and blue T-shirt")
    }
}
