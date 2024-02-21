import Foundation
import RegexBuilder
//

func main() {
    let msg =
      "FLRD0056B>OGFLR,qAS,LSZI2:/215553h4730.50N\00757.08En000/000/A=001975 !W56! id3ED0056B -019fpm +0.0rot 22.5dB -9.0kHz gps1x1"
    let re = /(?<time>\d+)h/
    let N = 1000000
    for _ in 0..<N {
      let match = try? re.firstMatch(in: msg)
      match?.time
    }
}

main()
