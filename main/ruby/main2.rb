require 'net/http'

SERVER='192.168.110.106'
PATH='/tenkaichi/gamble.php'

#   X-X
#  X   X
#      X
#      X
#     X
#    X
#   X
#  X
#  XXXXX

Net::HTTP.start(SERVER) {|h|
  est=ARGV[0].nil? ? 150 : ARGV[0].to_i
  bigs=0
  smalls=0
  hist=[:nil]*40
  last_ok=nil
  last_ok_time=Time.now.to_f
  last_time=Time.now.to_f
  speed=nil
  while(true)
    puts 'est: '+est.to_s
    res=h.get(PATH+"?n="+est.to_s)
    next unless res.code=='200'
    hist.shift
    case res.body
    when 'BIG'
      puts '>>>>>>>>>>>>>>>>>>>>>BIG'
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
      puts '<<<<<<<<<<<<<<<<<<<<<SMALL'
      hist.push :small
      bigs=0
      smalls+=1
      if smalls==1 && !speed.nil?
        est+=[((last_time-last_ok_time)*speed).to_i,10].min
      else
        est+=[(smalls*4).to_i,10+rand(5)].min
      end
    when 'OK'
      puts '=====================OK'
      hist.push :ok
      bigs=0
      smalls=0
      unless last_ok.nil?
        diff=est-last_ok
        now=Time.now.to_f
        tdiff=now-last_ok_time
        speed=diff/tdiff # [count/sec]
      end
      last_ok=est
      last_ok_time=Time.now.to_f
      est+=rand()<0.5 ? 3 : 4
    end
    puts "tries: #{hist.count}, hit: #{hist.count{|x|x==:ok}}, rate: #{hist.count{|x|x==:ok}/hist.count.to_f}"
    last_time=Time.now.to_f
  end
}
