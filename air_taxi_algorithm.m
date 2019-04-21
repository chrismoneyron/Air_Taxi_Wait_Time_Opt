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
n = 5; % Number of travel routes including current one
A = randi(100, n); % Enter condensed graph adjacency matrix here
% n = size(A, 1) % Command to get size of input adjacency matrix
A(:, 1) = 0; % Cannot travel to current node
A = A - diag(diag(A)); % No distance to same node

% Greedy algorithm if n > 11
if n > 11
    min_path = zeros(1, n);
    min_path(1) = 1;
    min_weight = 0;
    
    % Start node is always 1 so unvisited ones are remaining nodes
    curr_node = 1;
    unvisited_nodes = 2:n;
    
    % Choose minimum link weight until all nodes are visited
    while ~isempty(unvisited_nodes)
        
        [min_local_weight, min_idx] = min(A(curr_node, unvisited_nodes));
        min_weight = min_weight + min_local_weight;
        
        % Redefine current node based on index of minimum unvisited nodes
        curr_node = unvisited_nodes(min_idx);
        
        % Remove current node from unvisited nodes array
        unvisited_nodes(unvisited_nodes == curr_node) = [];
        
        % Add current node to the minimum path array
        min_path(n - size(unvisited_nodes, 2)) = curr_node;
        
    end
    
    % Format output for minimum path and weight
    min_path_str = sprintf('%d -> ', min_path(1:(n-1)));
    min_path_str = strcat(min_path_str, sprintf(' %d', min_path(n)));
    
% Brute force if n <= 11 (run once large network gets down to 10 requests)
else
    % Find all possible paths through all nodes
    % Add 1 since first node not in permutation array
    all_paths = perms(1:(n-1)) + 1;
    
    % Calculate total link weight for each possible path
    if size(all_paths', 1) > 0
        min_weight = realmax;
        for path = all_paths'
            % First link is from node 1 to the first node in the path vector
            tot_weight = A(1, path(1));

            for j = 1:(n - 2) % Iterate only until n-2 b/c last node is only destination

                % Add A(j,j+1) to tot_weight variable; j=origin, j+1=destination
                tot_weight = tot_weight + A(path(j), path(j+1));

            end

            if tot_weight < min_weight
                min_weight = tot_weight;
                min_path = [1, path']; % Add current node (1) to beginning of min path
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