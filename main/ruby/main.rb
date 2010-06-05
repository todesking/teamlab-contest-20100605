require 'net/http'

SERVER='192.168.110.106'
PATH='/tenkaichi/gamble.php'


Net::HTTP.start(SERVER) {|h|
  est=ARGV[0].nil? ? 150 : ARGV[0].to_i
  bigs=0
  smalls=0
  hist=[:nil]*40
  while(true)
    puts 'est: '+est.to_s
    res=h.get(PATH+"?n="+est.to_s)
    next unless res.code=='200'
    puts ' =>'+res.body
    hist.shift
    case res.body
    when 'BIG'
      hist.push :big
      bigs+=1
      if smalls>0
        est+=1
      elsif bigs>3
        est+=0
      else
        est+=0
      end
      smalls=0
    when 'SMALL'
      hist.push :small
      bigs=0
      smalls+=1
      est+=[(smalls*4).to_i,10+rand(5)].min
    when 'OK'
      hist.push :ok
      bigs=0
      smalls=0
      est+=rand()<0.5 ? 3 : 4
    end
    puts "tries: #{hist.count}, hit: #{hist.count{|x|x==:ok}}, rate: #{hist.count{|x|x==:ok}/hist.count.to_f}"
  end
}
