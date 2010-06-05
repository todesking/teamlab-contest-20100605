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
  last_est=0
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
      if smalls>2
        est+=0
      elsif bigs>4
        est+=0
      elsif bigs>2
        est-=1
      else
        est-=1
      end
      smalls=0
      est=last_ok+((Time.now.to_f-last_ok_time)*speed).to_i unless speed.nil? || bigs>3
    when 'SMALL'
      puts '<<<<<<<<<<<<<<<<<<<<<SMALL'
      hist.push :small
      bigs=0
      smalls+=1
      case
      when smalls<2
        est+=5
      when smalls<3
        est+=8
      when smalls<5
        est+=12
      else
        est+=10
      end
      est+=smalls
      est=last_ok+((Time.now.to_f-last_ok_time)*speed).to_i unless speed.nil? || smalls>3
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
      est+= speed.nil? ? 3 : speed.to_i
    end
    puts "tries: #{hist.count}, hit: #{hist.count{|x|x==:ok}}, rate: #{hist.count{|x|x==:ok}/hist.count.to_f}"
    puts "--> #{est-last_est}"
    last_time=Time.now.to_f
    last_est=est
  end
}
