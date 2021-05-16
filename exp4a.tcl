#===================================
# Initialization
#===================================
#Create a ns simulator
set ns [new Simulator]
#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile
#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile

#===================================
# Nodes Definition
#===================================
#Create 3 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
#===================================
# Links Definition
#===================================
#Createlinks between nodes
$ns duplex-link $n0 $n1 10.0Mb 1ms DropTail
$ns queue-limit $n0 $n1 10
$ns duplex-link $n1 $n2 10.0Mb 1ms DropTail
$ns queue-limit $n1 $n2 10
#Give node position (for NAM)
#$ns duplex-link-op $n0 $n1 orient right
#$ns duplex-link-op $n1 $n2 orient right
#######################
#1.to create drop scenario at first node itself ----- >> change the packet size of application
#protocol and packet size of Transport
# layere.g packet size of cbr =10000 , packet size of tcp =100
#2. Drop at n1 = set queue size ratio to be 5:2 ,BWXDelay between no and n1 = 10Mb X
#0.05ms , between n1 and n2 0.05Mb X 100ms
#3 .to count the number of packets dropped grep -c "^d" out.tr

#===================================
# Agents Definition
#===================================
#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink1 [new Agent/TCPSink]
$ns attach-agent $n2 $sink1
$ns connect $tcp0 $sink1
$tcp0 set packetSize_ 1500
#===================================
# Applications Definition
#===================================
#Setup a CBR Application over TCP connection
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $tcp0
$cbr0 set packetSize_ 1000
$cbr0 set rate_ 0.1Mb
$cbr0 set random_ null
$ns at 1.0 "$cbr0 start"
$ns at 10.0 "$cbr0 stop"
#===================================
# Termination
#===================================
#Define a 'finish' procedure
proc finish {} {
global ns tracefile namfile
$ns flush-trace
close $tracefile
close $namfile
exec nam out.nam &
exit 0
}
$ns at 10.0 "finish"
$ns run
