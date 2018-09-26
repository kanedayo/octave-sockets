myfork=@() fork();

pid = myfork();

if pid
  waitpid(pid);
  disp(['pid=' num2str( pid ) ])
else
  disp('child');
  exit
end
