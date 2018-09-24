% octave
pkg load sockets;
pkg load communications;

port    = 8080;

recv_sck = socket( AF_INET, SOCK_DGRAM, 0 );
bind( recv_sck, port );

BUFLEN=2^10;
data_buf=[];
unwind_protect
  for i=1:100
  
    [ rx_data, len ] = recv( recv_sck, 16*BUFLEN );
  
    data = typecast( rx_data , 'double complex' );
    data_buf = [ data_buf data ];
  
    if(mod(i,10)==0)
      plot( data_buf, '*' )
      data_buf=[];
      %pause(.00001)
      shg
    end
  
  end

unwind_protect_cleanup
  disconnect(recv_sck);
end_unwind_protect
