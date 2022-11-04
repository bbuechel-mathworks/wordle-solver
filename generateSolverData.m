function T = generateSolverData(guesses)

arguments
    guesses (:,1) string
end

D = zeros(length(guesses),length(guesses),'uint8');
for i = 1:length(guesses)
    for j = 1:length(guesses)
        result = wordleGuess(guesses{i},guesses{j});
        D(i,j) = uint8([81 27 9 3 1]*result(:));
    end
end

% Caluclate letter probabilities
p = letterdistribution(guesses);
probs = p(sub2ind([26,5],char(guesses)-64,repmat(1:5,numel(guesses),1)));

T = table(guesses,prod(probs,2),D, ...
    'VariableNames',["Words","LetterProbability","ResultMatrix"]);
end
%%
function lprob = letterdistribution(words)
% split our words into their individual letters
letters = split(words,"");
% this also creates leading and trailing blank strings, drop them
letters = letters(:,2:end-1);

% Calculate the distribution of letters in each word position
AZ = string(char((65:90)'));
lcount = zeros(26,5);
for k = 1:5
    lcount(:,k) = histcounts(categorical(letters(:,k),AZ));
end
lprob = lcount./sum(lcount);  % Normalize
end