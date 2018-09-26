%%%%%%%%%%%%%%%%%%%%%%%%
function task_manager()
[pid0,fd_rd0,fd_wt0] = fork_with_pipe();
disp(['A:' num2str(pid0)])

if pid0 > 0 % parent
disp(['B:' num2str(pid0)])
  %pclose(fd_wt0);
  task_plot(fd_rd0);
disp(['Z:' num2str(pid0)])
  waitpid(pid0);

else % child
disp(['B:' num2str(pid0)])
  %pclose(fd_rd0);

  [pid1,fd_rd1,fd_wt1] = fork_with_pipe();
  if pid1 == 0 % child
    %pclose(fd_wt0);
    %pclose(fd_rd1);
    task_udp(fd_wt1);
disp(['Z:' num2str(pid1)])
    exit; % pid1
  end

  [pid2,fd_rd2,fd_wt2] = fork_with_pipe();
  if pid2 == 0 % child
    %pclose(fd_wt0);
    %pclose(fd_rd2);
    task_timer(fd_wt2);
disp(['Z:' num2str(pid2)])
    exit; % pid2
  end

  %pclose(fd_wt1);
  %pclose(fd_wt2);
  task_router(fd_wt0,fd_rd1,fd_rd2);
disp(['Z:' num2str(pid0)])
  waitpid(pid1);
  waitpid(pid2);
  exit; % pid0
end

%%%%%%%%%%%%%%%%%%%%%%%%
function [pid,fd_rd,fd_wt] = fork_with_pipe()
[p_rd,c_wt]=pipe();
[c_rd,p_wt]=pipe();

pid = fork();
if pid > 0 % parent
  %pclose(c_rd);
  %pclose(c_wt);
  fd_rd = p_rd;
  fd_wt = p_wt;
else % client
  %pclose(p_rd);
  %pclose(p_wt);
  fd_rd = c_rd;
  fd_wt = c_wt;
end

%%%%%%%%%%%%%%%%%%%%%%%%
function [type,len,value] = read_tlv(fd)
  tl = read(fd,2);
  type  = tl(1);
  len   = tl(2);
  value = read(fd,len);

%%%%%%%%%%%%%%%%%%%%%%%%
function task_plot(fd_rd0)
disp(['C:task_plot:(rd0)=' num2str(fd_rd0)])
  while true
disp('D:task_plot')
    [val,len]=fread(fd_rd0);
    disp(['val=' num2str(val)]);
    pause(1)
  end

%%%%%%%%%%%%%%%%%%%%%%%%
function task_router(fd_wt0,fd_rd1,fd_rd2)
disp(['C:task_router:(wt0,rd1,rd2)=' num2str([fd_wt0,fd_rd1,fd_rd2])])
  while true
    [val,len]=fread(fd_rd1);
    len=fwrite(fd_wt0,val);
    fflush(fd_wt0);
disp(['D:task_router:len=' num2str(len)])
    [val,len]=fread(fd_rd2);
    len=fwrite(fd_wt0,val);
    fflush(fd_wt0);
disp(['D:task_router:len=' num2str(len)])
    pause(2)
  end

%%%%%%%%%%%%%%%%%%%%%%%%
function task_udp(fd_wt)
disp(['C:task_udp:(wt)=' num2str(fd_wt)])
  while true
    pause(3)
    len=fwrite(fd_wt, uint8(88));
    fflush(fd_wt);
disp(['D:task_udp:len=' num2str(len)])
  end

%%%%%%%%%%%%%%%%%%%%%%%%
function task_timer(fd_wt)
disp(['C:task_timer:(wt)=' num2str(fd_wt)])
  while true
    pause(5)
    len=fwrite(fd_wt, uint8(255));
    fflush(fd_wt);
disp(['D:task_timer:len=' num2str(len)])
  end
