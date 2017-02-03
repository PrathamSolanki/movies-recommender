function movieList = loadMovieList(nm)
%GETMOVIELIST reads the fixed movie list in movie.txt and returns a
%cell array of the words
%   movieList = GETMOVIELIST() reads the fixed movie list in movie.txt 
%   and returns a cell array of the words in movieList.


%% Read the fixed movieulary list
fid = fopen('../../../Data/movies.csv');

% Store all movies in cell array movie{}

movieList = cell(nm+1, 1);

for i = 1:nm+1
    % Read line
    line = fgets(fid);
    % Word Index (can ignore since it will be = i)
    [idx, movieName] = strtok(line, ',');
    % Actual Word
    movieList{i} = strtrim(movieName);
end
fclose(fid);

end
