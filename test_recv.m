% octave
pkg load sockets;
pkg load communications;

port    = 8080;

myfork =@() fork();
pid = myfork();

if pid < 0
  error('ERROR:fork');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif pid==0 % child

  send_sck = socket( AF_INET, SOCK_DGRAM, 0 );
  client_info = struct( "addr", 'localhost', "port", port);
  connect( send_sck, client_info );

  plot_fig_cmd = uint8(255);

  while(true)
    send( send_sck, plot_fig_cmd );
    pause(1);
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else % pid > 0 % parent

  recv_sck = socket( AF_INET, SOCK_DGRAM, 0 );
  bind( recv_sck, port );
  
  BUFLEN=2^10;
  data_buf=[];
  plot_fig=0;
  unwind_protect
    while(true)
    
      [ rx_data, len ] = recv( recv_sck, 16*BUFLEN );
    
      if len==1 && uint8(rx_data(1))==255
        plot_fig=plot_fig+1;
        disp(['set plot_fig=' num2str(plot_fig)]);
        fflush(stdout);
        if plot_fig > 10
          error('timeup!!');
        end
      else
        data = typecast( rx_data , 'double complex' );
        data_buf = [ data_buf data ];
      end
    
      if plot_fig && length(data_buf)
        plot( data_buf, '*' )
        plot_fig=0; % clear
        data_buf=[];% clear
        %pause(.00001)
        shg
      end
    
    end
  
  unwind_protect_cleanup
    disconnect(recv_sck);
  end_unwind_protect

end % pid
