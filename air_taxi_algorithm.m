%% Air Taxi Passenger Wait Time Optimization
% Chris Moneyron, AAE 590 Distributed Network Control
% Purdue University, Instructor: Shaoshuai Mou
% 21 April, 2019
%
% Network must be entered/updated into adjacency matrix, A
%
% Adjacency matrix weights represent time from destination a to destination
% b including stopping at origin b
%
% Based on technical requirements from Uber (vel = 175 mph, range = 61.25
% miles/21 min, recharge time = 5 min)

% Brute force if n <= x and greedy if n > x since runtime is
% too long and the greedy algorithm is a good approximation since
% most requests will be close together if there are that many
% requests in one city

clear;
clc;

% tic % Used to time code section

% n = 10 -> ~1.5 seconds runtime (brute force)
% n = 11 -> ~12 seconds runtime (brute force)
% n = 12 -> ~128 seconds runtime (brute force)
n = 4; % Number of travel routes including current one
A = randi(21, n); % Enter condensed graph adjacency matrix here
% n = size(A, 1) % Command to get size of input adjacency matrix
A(:, 1) = 0; % Cannot travel to current node
A = A - diag(diag(A)); % No distance to same node
curr_weight = randi(21); % Weight of current route (for computing recharges)
recharge_time = 5;
range = 21;
curr_weight = 4;
A = [0 14 10 9; 0 0 13 14; 0 11 0 10; 0 19 8 0];

% Greedy algorithm if n > 11
if n > 11
    min_path = 1;
    min_weight = curr_weight;
    
    % Start node is always 1 so unvisited ones are remaining nodes
    curr_node = 1;
    unvisited_nodes = 2:n;
    visited_nodes = 1;
    
    weight_since_recharge = curr_weight;
    recharges = 0;
    
    % Choose minimum link weight until all nodes are visited
    while ~isempty(unvisited_nodes)
        
        [min_local_weight, min_idx] = min(A(curr_node, unvisited_nodes));
        
        % Impossible route if path weight is greater than range
        if min_local_weight > range
            if curr_node == 1
                min_path = zeros(1, size(A, 1));
                min_weight = realmax;
                break
            end
            unvisited_nodes = sort([unvisited_nodes, min_path(end)]);
            min_path(end) = [];
            A(min_path(end), curr_node) = realmax;
            curr_node = min_path(end);
            continue
        end
        
        % Track total weight since last recharge
        weight_since_recharge = weight_since_recharge + min_local_weight;
        
        % Recharge for recharge time if weight since last recharge
        % is greater than the range of the air taxi
        if weight_since_recharge > range
            recharges = recharges + 1;
            min_local_weight = min_local_weight + (recharge_time * fix(weight_since_recharge/range));
            weight_since_recharge = mod(weight_since_recharge, range);
        end
        
        min_weight = min_weight + min_local_weight;
        
        % Redefine current node based on index of minimum unvisited nodes
        curr_node = unvisited_nodes(min_idx);
        
        % Remove current node from unvisited nodes array and add to visited
        % array
        unvisited_nodes(unvisited_nodes == curr_node) = [];
        
        % Add current node to the minimum path array
        min_path = [min_path, curr_node];
        
    end
    
    % Format output for minimum path and weight
    min_path_str = sprintf('%d -> ', min_path(1:(n-1)));
    min_path_str = strcat(min_path_str, sprintf(' %d', min_path(n)));
    
% Brute force if n <= 11 (run once large network gets down to 11 requests)
else
    % Find all possible paths through all nodes
    % Add 1 since first node not in permutation array
    all_paths = perms(1:(n-1)) + 1;
    
    % Calculate total link weight for each possible path
    if size(all_paths', 1) > 0
        
        min_weight = realmax;
        
        for path = all_paths'
            
            % First link is from node 1 to the first node in the path vector
            path = [1; path];
            tot_weight = curr_weight;
            
            weight_since_recharge = curr_weight;
            recharges = 0;
            
            for j = 1:(n - 1) % Iterate only until n-2 b/c last node is only destination
                path_weight = A(path(j), path(j+1));
                
                % Impossible route if path weight is greater than range
                if path_weight > range
                    tot_weight = realmax;
                    if j == 1
                        min_path = zeros(1, size(A, 1));
                    end
                    break
                end
                
                % Track total weight since last recharge
                weight_since_recharge = weight_since_recharge + path_weight;
                
                % Recharge for recharge time if weight since last recharge
                % is greater than the range of the air taxi
                if weight_since_recharge > range
                    recharges = recharges + 1;
                    path_weight = path_weight + (recharge_time * fix(weight_since_recharge/range));
                    weight_since_recharge = mod(weight_since_recharge, range);
                end
                
                % Add A(j,j+1) to tot_weight variable; j=origin, j+1=destination
                tot_weight = tot_weight + path_weight;
                
            end

            if tot_weight < min_weight
                min_weight = tot_weight;
                min_path = path;
            end

        end
        
        % Format output for minimum path and weight
        min_path_str = sprintf('%d -> ', min_path(1:(n-1)));
        min_path_str = strcat(min_path_str, sprintf(' %d', min_path(n)));
    
    else 
        min_weight = 0;
        min_path = 1;
        min_path_str = '1';
    end
end

fprintf('Min path: %s\n', min_path_str)
fprintf('Min path weight: %g\n', min_weight)

% toc % Used to time code section