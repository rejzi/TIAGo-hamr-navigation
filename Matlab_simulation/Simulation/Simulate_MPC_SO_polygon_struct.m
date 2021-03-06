function Simulate_MPC_SO_polygon_struct (x_ol,x_cl,o_cl,SO_polygon,SO_cl_points,x_ref,N,rob_diameter)
%% Figure setup
figure(100)
fig = gcf; %Current figure handle
fig.Color = 'w';
fig.Units = 'pixel';
fig.OuterPosition = [0 0 1000 1000];
fig.PaperPositionMode = 'auto';

%% Draw simulation

% Footprint of the robot
robot_radius = rob_diameter/2;
draw_ang=0:0.005:2*pi;               % angles for to draw the robot
x_robot = robot_radius*cos(draw_ang);
y_robot = robot_radius*sin(draw_ang);

% arrow triangle parameters
arrow_h = 0.1; arrow_w=0.05;

x_driven = [];
y_driven = [];


step_size = 1;

[obs, obs_sizes] = SO_struct2Matrix(SO_polygon);

for k = 1:step_size:size(x_ol,2)-1 % go through the open loop
    % Plot SO (Static Obstacles)
    i_pos = 1;
    for i = 1:size(obs_sizes,2)
        if obs_sizes<=2
            plot(obs(i_pos:i_pos+obs_sizes(i)-1,1), obs(i_pos:i_pos+obs_sizes(i)-1,2), 'm-o');
            hold on;
            i_pos = i_pos+obs_sizes(i);
        else
            poly_x = [obs(i_pos:i_pos+obs_sizes(i)-1,1);obs(i_pos,1)];
            poly_y = [obs(i_pos:i_pos+obs_sizes(i)-1,2);obs(i_pos,2)];
            plot(poly_x, poly_y, 'm-o');
            hold on;
            i_pos = i_pos+obs_sizes(i);
        end
    end
    
    for i = 1:size(obs_sizes,2)
        plot(SO_cl_points(i,1,k), SO_cl_points(i,2,k), 'b*')
        hold on
    end
    
    % Plot MO (Moving Obstacles) predictions
    if k < size(x_ol,2)
        for i = 1:size(o_cl,1)
            x_obs_fp = o_cl(i,1,5,1)*cos(draw_ang);
            y_obs_fp = o_cl(i,1,5,1)*sin(draw_ang);
            plot(o_cl(i,2:(N+1),1,k), o_cl(i,2:(N+1),2,k), 'c--*')
            hold on
            for j = 2:(N+1)
                plot(o_cl(i,j,1,k)+x_obs_fp, o_cl(i,j,2,k)+y_obs_fp,'--c', 'LineWidth', 0.5)     % plot robot footprint in predictions
                hold on
            end
        end
    end
    
    % Plot MO current position
    for i = 1:size(o_cl,1)
        ox1 = o_cl(i,1,1,k);
        ox2 = o_cl(i,1,2,k);
        plotArrow(ox1, ox2, o_cl(i,1,3,k), o_cl(i,1,5,k), arrow_h, arrow_w, 'k');
        hold on
        x_obs_fp = o_cl(i,1,5,1)*cos(draw_ang);
        y_obs_fp = o_cl(i,1,5,1)*sin(draw_ang);
        plot(o_cl(i,1,1,k)+x_obs_fp, o_cl(i,1,2,k)+y_obs_fp,'k')
        hold on
    end
    
    % Plot reference trajectory
    plot(x_ref(:,1), x_ref(:,2), 'k', 'LineWidth', 1.5)
    hold on
    
    % Plot the driven (executed) trajectory
    x1 = x_ol(1,k,1); y1 = x_ol(2,k,1); th1 = x_ol(3,k,1);
    x_driven = [x_driven x1];
    y_driven = [y_driven y1];
    plot(x_driven,y_driven,'b','LineWidth', 1.5) % plot exhibited trajectory
    hold on
    
    % Plot reference trajectory until horizon ends
    % Plot positon on reference trajcetory
    if (k+N <= size(x_ref,1))
        plot(x_ref(k:k+N,1), x_ref(k:k+N, 2), 'g*')
    else
        plot(x_ref(k:end,1), x_ref(k:end, 2), 'g*')
    end
    hold on
    
    % Plot prediction
    if k < size(x_ol,2)
        plot(x_cl(1:N,1,k), x_cl(1:N,2,k), 'r--*')
        hold on
        for i = 2:N+1
            plot(x_cl(i,1,k)+x_robot, x_cl(i,2,k)+y_robot,'--r')     % plot robot footprint in predictions
            hold on
        end
    end

    % Plot goal position
    plotArrow(x_ref(end,1), x_ref(end,2), x_ref(end,3), robot_radius, arrow_h, arrow_w, 'g');
    hold on
    
    % Plot Robot footprint
    plotArrow(x1, y1, th1, robot_radius, arrow_h, arrow_w, 'k');
    hold on
    plot(x1+x_robot,y1+y_robot,'k')      % plot robot circle
    
    hold off
    
    ylabel('$y$-position [m]','interpreter','latex','FontSize', 16)
    xlabel('$x$-position [m]','interpreter','latex','FontSize', 16)
    axis([-.2 9 -.2 9])
    
    %pause(0.1)
    
    box on;
    grid on;
    drawnow
end
%close(gcf)
