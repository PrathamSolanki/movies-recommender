function [J, grad] = cofiCostFunc(params, Y, R, num_users, num_movies, ...
                                  num_features, lambda)
%COFICOSTFUNC Collaborative filtering cost function
%   [J, grad] = COFICOSTFUNC(params, Y, R, num_users, num_movies, ...
%   num_features, lambda) returns the cost and gradient for the
%   collaborative filtering problem.
%

% Unfold the U and W matrices from params
X = reshape(params(1:num_movies*num_features), num_movies, num_features);
Theta = reshape(params(num_movies*num_features+1:end), ...
                num_users, num_features);

            
% Need to return the following values correctly
J = 0;
X_grad = zeros(size(X));
Theta_grad = zeros(size(Theta));

% ===================================================================
%
% Notes: X - num_movies  x num_features matrix of movie features
%        Theta - num_users  x num_features matrix of user features
%        Y - num_movies x num_users matrix of user ratings of movies
%        R - num_movies x num_users matrix, where R(i, j) = 1 if the 
%            i-th movie was rated by the j-th user

J_orig = sum(sum((((X*Theta') .* R)-(Y .* R)) .^ 2)) * 1/2;
regular = (lambda/2) * (sum(sum((Theta .^ 2))) + sum(sum((X .^ 2))));
J = J_orig + regular;

for i=1:size(X,1),
  idx = find(R(i,:) == 1);
  Theta_t = Theta(idx,:);
  Y_t = Y(i, idx);
  X_t = (X(i,:)*Theta_t'-Y_t)*Theta_t;
  X_grad(i,:) = X_t' + (lambda*X(i,:))';
end
 
 
for j=1:size(Theta, 1),
 idx = find(R(:,j) == 1);
 X_t = X(idx,:);
 Y_t = Y(idx,j);
 Theta_t = X_t' * (X_t*Theta(j,:)'-Y_t);
 Theta_grad(j,:) = Theta_t' + (lambda*Theta(j,:));
end

% =====================================================================

grad = [X_grad(:); Theta_grad(:)];

end
