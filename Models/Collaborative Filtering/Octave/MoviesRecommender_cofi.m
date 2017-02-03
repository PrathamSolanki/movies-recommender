clear all, clc, history -c

ratings = csvread('../../../Data/ratings.csv');
ratings(:,4)=[];
ratings(1,:)=[];

nu = rows(unique(ratings(:,1)));

movies = csvread('../../../Data/movies.csv'); 
for i=size(movies,2):-1:2
	movies(:,i) = [];
endfor
movies(1,:) = [];

nm = rows(unique(movies(:,1)));

Y = zeros(nm,nu);
R = zeros(nm,nu);

for i=1:size(ratings,1)
	u = ratings(i,1);
	
	m = ratings(i,2);
	m_idx = find(movies == m);	
	m = m_idx;

	r = ratings(i,3);

	Y(m,u) = r;
endfor

R = logical(Y);

clear i m m_idx r u

%% ============== Entering ratings for a new user ===============
movieList = loadMovieList(nm);
movieList(1,:) = [];

%  Initialize my ratings
my_ratings = zeros(nm, 1);

m_id = zeros(1,1);
rating= zeros(1,1);

choice = 1;
i = 1;

fprintf('Please refer the file movies.csv and provide your ratings:\n');

while(choice)
	fprintf('\n');
	m_id(i,1) = input('Enter Movie Id: ');
	rating(i,1) = input('Enter Your Rating: ');
	i = i + 1;
	choice = input('Enter 1 to continue rating more movies, 0 to exit and get recommendations: ');
endwhile

for i=1:length(m_id)
	my_ratings(find(movies == m_id(i,1))) = rating(i,1);
endfor

fprintf('\n\nYour ratings:\n');
for i = 1:length(my_ratings)
    if my_ratings(i) > 0 
        fprintf('Rated %d for %s\n', my_ratings(i), ...
                 movieList{i});
    end
end

clear m_id rating choice i

fprintf('\nProgram paused. Press enter to continue.\n');
pause;

%% ============================== Learning Movie Ratings ====================
fprintf('\nTraining collaborative filtering...\n');

%  Y is a nm*nu matrix, containing ratings (1-5) of nm movies by 
%  nu users
%
%  R is a nm*nu matrix, where R(i,j) = 1 if and only if user j gave a
%  rating to movie i

%  Add our own ratings to the data matrix
Y = [my_ratings Y];
R = [logical(my_ratings) R];

%  Normalize Ratings
[Ynorm, Ymean] = normalizeRatings(Y, R);

%  Useful Values
num_users = size(Y, 2);
num_movies = size(Y, 1);
num_features = 10;

% Set Initial Parameters (Theta, X)
X = randn(num_movies, num_features);
Theta = randn(num_users, num_features);

initial_parameters = [X(:); Theta(:)];

% Set options for fmincg
options = optimset('GradObj', 'on', 'MaxIter', 1000);

% Set Regularization
lambda = 10;
theta = fmincg (@(t)(cofiCostFunc(t, Y, R, num_users, num_movies, ...
                                num_features, lambda)), ...
                initial_parameters, options);

% Unfold the returned theta back into U and W
X = reshape(theta(1:num_movies*num_features), num_movies, num_features);
Theta = reshape(theta(num_movies*num_features+1:end), ...
                num_users, num_features);

fprintf('Recommender system learning completed.\n');

fprintf('\nProgram paused. Press enter to continue.\n');
pause;

%% ================== Recommendation for you ====================
%  After training the model, you can now make recommendations by computing
%  the predictions matrix.
%

p = X * Theta';
my_predictions = p(:,1) + Ymean;

movieList = loadMovieList(nm);
movieList(1,:) = [];

[r, ix] = sort(my_predictions, 'descend');
fprintf('\nTop recommendations for you:\n');
for i=1:10
    j = ix(i);
    fprintf('Predicting rating %.1f for movie %s\n', my_predictions(j), ...
            movieList{j});
end

fprintf('\n\nRatings you provided:\n');
for i = 1:length(my_ratings)
    if my_ratings(i) > 0 
        fprintf('Rated %d for %s\n', my_ratings(i), ...
                 movieList{i});
    end
end

