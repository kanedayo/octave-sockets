% octave
pkg load sockets;
pkg load communications; % qammod

%host_ip = '192.168.1.42';
%host_ip = '127.0.0.1';
host_ip = 'localhost';
port    = 8080;

send_sck = socket( AF_INET, SOCK_DGRAM, 0 );
client_info = struct( "addr", host_ip, "port", port);
connect( send_sck, client_info );

Qm=2; % Qm=[ 1 2 4 6 8 ];
LEN=2^8;
unwind_protect
  for i=1:100
  
    data = qammod(mod(0:LEN-1,2^Qm),2^Qm) + 0.5*[1 1j]*randn(2,LEN);
    tx_data = typecast( data , 'uint8' );
    tx_data(1:10) % debug_print
    fflush(stdout);
  
    send( send_sck, tx_data );
  
    pause(.01)
  
  end

unwind_protect_cleanup
  disconnect(send_sck);
end_unwind_protect
