##
# Child process shutdown procedure
#
# Array must be an array of number PID
#
# @pids=[]
#
def shut_down
    puts "\nShutting down gracefully..."
    if @pids
        @pids.each{|pid| Process.kill('SIGTERM',pid)}
    else
        puts "To shutdown children, variable @pids must exist and be an array"
    end
    sleep 1
end

#puts "I have PID #{Process.pid}"

##
# Trap ^C
#
Signal.trap("INT") {
    shut_down
    exit
}

##
# Trap `Kill `
#
Signal.trap("TERM") {
    shut_down
    exit
}