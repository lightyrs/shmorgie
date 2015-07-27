namespace :deploy do
  task :start do
    on roles(:app) do
      as "root" do
        execute "/etc/init.d/unicorn2 start"
      end
    end
  end

  task :stop do
    on roles(:app) do
      as "root" do
        execute "/etc/init.d/unicorn2 stop"
      end
    end
  end

  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      as "root" do
        execute "/etc/init.d/unicorn2 restart"
      end
    end
  end
end
