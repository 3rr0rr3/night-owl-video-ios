import SwiftUI

struct VHSCover: View {
    let movie: Movie
    var rare = false
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [palette[movie.id].opacity(0.6),ink],startPoint: .topLeading,endPoint: .bottomTrailing)
                Canvas { context,size in
                    var c = context
                    c.scaleBy(x: size.width / 160,y: size.height / 210)
                    func oval(_ x: Double,_ y: Double,_ w: Double,_ h: Double,_ color: Color) { c.fill(Path(ellipseIn: CGRect(x: x,y: y,width: w,height: h)),with: .color(color)) }
                    func rect(_ x: Double,_ y: Double,_ w: Double,_ h: Double,_ color: Color) { c.fill(Path(CGRect(x: x,y: y,width: w,height: h)),with: .color(color)) }
                    func shape(_ points: [CGPoint],_ color: Color) { var p = Path(); p.addLines(points); p.closeSubpath(); c.fill(p,with: .color(color)) }
                    for n in 0..<20 { oval(Double((n * 47 + 13) % 150),Double((n * 23 + 19) % 112),2,2,.white.opacity(0.5)) }
                    switch movie.id {
                    case 0:
                        oval(86,40,58,58,gold); oval(100,45,16,16,.orange.opacity(0.35))
                        shape([CGPoint(x: 0,y: 146),CGPoint(x: 55,y: 94),CGPoint(x: 105,y: 132),CGPoint(x: 160,y: 90),CGPoint(x: 160,y: 190),CGPoint(x: 0,y: 190)],.purple)
                        rect(28,101,101,43,ink); rect(24,97,110,8,mint)
                        for n in 0..<5 { rect(Double(35+n*18),110,11,24,.cyan.opacity(0.8)) }
                        oval(17,65,45,11,.white); oval(30,57,20,13,.cyan)
                    case 1:
                        oval(100,37,33,33,.white.opacity(0.8))
                        for n in 0..<6 { let x=Double(n*32-15); shape([CGPoint(x:x,y:55),CGPoint(x:x-28,y:145),CGPoint(x:x+28,y:145)],n % 2 == 0 ? .black.opacity(0.65) : .green.opacity(0.5)) }
                        shape([CGPoint(x:80,y:110),CGPoint(x:30,y:167),CGPoint(x:136,y:167)],coral)
                        shape([CGPoint(x:80,y:119),CGPoint(x:64,y:167),CGPoint(x:99,y:167)],ink)
                        oval(39,88,5,4,gold); oval(49,88,5,4,gold)
                    case 2:
                        for n in 0..<7 { rect(Double(n*25-25),75,13,86,palette[n%6].opacity(0.3)) }
                        oval(44,59,72,83,Color(red: 0.94,green: 0.72,blue: 0.50))
                        rect(41,77,78,16,ink); rect(76,90,8,17,coral)
                        oval(58,108,24,11,ink); oval(78,108,24,11,ink)
                        shape([CGPoint(x:49,y:140),CGPoint(x:112,y:140),CGPoint(x:140,y:184),CGPoint(x:20,y:184)],mint)
                        rect(39,166,84,8,gold); oval(48,175,12,12,ink); oval(101,175,12,12,ink)
                    case 3:
                        for n in 0..<7 { rect(Double(n*26-10),Double(70+(n%3)*14),20,85,ink.opacity(0.8)) }
                        shape([CGPoint(x:62,y:110),CGPoint(x:98,y:110),CGPoint(x:151,y:199),CGPoint(x:7,y:199)],.gray)
                        rect(76,139,6,28,gold)
                        shape([CGPoint(x:124,y:52),CGPoint(x:132,y:74),CGPoint(x:154,y:77),CGPoint(x:137,y:90),CGPoint(x:143,y:114),CGPoint(x:119,y:99),CGPoint(x:101,y:112),CGPoint(x:106,y:88),CGPoint(x:90,y:73),CGPoint(x:116,y:74)],.orange)
                        rect(44,99,72,57,coral); rect(51,107,58,23,.cyan); rect(51,135,14,8,gold); rect(96,135,14,8,gold)
                        oval(49,151,15,15,ink); oval(96,151,15,15,ink)
                    case 4:
                        var heart=Path(); heart.move(to: CGPoint(x:80,y:126)); heart.addCurve(to: CGPoint(x:30,y:71),control1: CGPoint(x:0,y:80),control2: CGPoint(x:25,y:47)); heart.addCurve(to: CGPoint(x:80,y:70),control1: CGPoint(x:45,y:49),control2: CGPoint(x:70,y:48)); heart.addCurve(to: CGPoint(x:130,y:71),control1: CGPoint(x:95,y:48),control2: CGPoint(x:119,y:47)); heart.addCurve(to: CGPoint(x:80,y:126),control1: CGPoint(x:158,y:91),control2: CGPoint(x:114,y:111)); c.fill(heart,with: .color(.pink))
                        for n in 0..<8 { rect(Double(n*23),Double(138+(n%3)*7),18,52,ink.opacity(0.7)) }
                        oval(58,128,15,17,gold); oval(85,128,15,17,gold); rect(60,144,12,27,mint); rect(87,144,12,27,coral)
                    default:
                        rect(22,64,116,102,Color(red:0.91,green:0.84,blue:0.62))
                        for n in 0..<5 { oval(Double(45+(n%2)*18),Double(82+n*14),7,10,.brown.opacity(0.5)) }
                        c.stroke(Path(ellipseIn: CGRect(x:72,y:76,width:51,height:51)),with: .color(ink),lineWidth:7)
                        shape([CGPoint(x:111,y:117),CGPoint(x:103,y:125),CGPoint(x:128,y:154),CGPoint(x:139,y:145)],ink)
                        oval(49,142,17,17,.orange); rect(46,157,23,24,mint)
                    }
                }
                VStack(spacing: 3) {
                    HStack { Text(rare ? "COLLECTOR’S CUT" : "NIGHT OWL VIDEO"); Spacer(); Text("VHS") }.font(.system(size: max(5,geo.size.width * 0.045),weight: .black,design: .monospaced)).padding(6).background(ink.opacity(0.9))
                    Text(movie.title.uppercased()).font(.system(size: max(9,geo.size.width * 0.13),weight: .black,design: .rounded)).multilineTextAlignment(.center).lineLimit(2).minimumScaleFactor(0.65).shadow(color: .black,radius: 3).padding(.horizontal,8)
                    Spacer()
                    Text(["THE SHOPS ARE CLOSED. THE GALAXY IS OPEN.","SOME CAMPERS NEVER CHECK OUT.","ONE DAD. ZERO CHILL.","HIS LAST STOP IS JUST THE BEGINNING.","LOVE IS WORTH REWINDING.","SMALL SLEUTHS. BIG CLUES."][movie.id]).font(.system(size: max(5,geo.size.width * 0.045),weight: .heavy)).multilineTextAlignment(.center).padding(7).background(ink.opacity(0.8))
                }.foregroundStyle(.white)
            }.overlay(alignment: .leading) { Rectangle().fill(.black.opacity(0.4)).frame(width: 6) }
                .clipShape(RoundedRectangle(cornerRadius: 6)).overlay(RoundedRectangle(cornerRadius: 6).stroke(rare ? gold : .white.opacity(0.2),lineWidth: rare ? 3 : 1))
        }.aspectRatio(160/210,contentMode: .fit).accessibilityLabel("\(movie.title) illustrated VHS cover, \(movie.genre)")
    }
}
