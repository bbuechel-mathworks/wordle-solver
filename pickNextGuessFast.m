function [nextWord,rankedWords] = pickNextGuessFast(goodGuesses,solverTable,method,showProgress)
% PICKNEXTGUESS - Pick the next guess for Wordle

arguments
    goodGuesses (:,1) string
    solverTable table
    method (1,1) string = "MinMax"
    showProgress (1,1) logical = true;
end

% Create output table to hold results
rankedWords = solverTable(:,["Words",'LetterProbability']);
rankedWords.GoodGuess = ismember(rankedWords.Words,goodGuesses);

% Get result matrix. D(i,j) is the wordle outcome for guess i and answer j
D = solverTable.ResultMatrix(:,rankedWords.GoodGuess);

% Pick a variable name based on the method for display purposes
methods = ["MinMax","Constellations","MaxEntropy"];
varNames = ["MinRemoved","NumConstellation","Entropy"];
scoreName = varNames(methods==method);
rankedWords.(scoreName) = zeros(height(rankedWords),1);
rankedWords = renamevars(rankedWords,"LetterProbability","LetterProbScore");
rankedWords = rankedWords(:,["Words",scoreName,"GoodGuess","LetterProbScore"]);


% Loop through guesses, getting distribution of results
if showProgress
    waitbarHandle = waitbar(0,'Narrowing down guesses');
end
for j = 1:height(rankedWords)

    % Count possible outcomes for this guess
    resultCounts =  histcounts(D(j,:),0:243);

    if method=="MinMax"
        % Apply MinMax algorithm from Knuth: minimum number of words that could be
        % removed from the list of next guesses
        rankedWords.(scoreName)(j) = min(size(D,2)-resultCounts);
    elseif method=="Constellations"
        % Count number of unique nonzero "constellations" (the results from
        % a guess)
        rankedWords.(scoreName)(j) = nnz(resultCounts);
    elseif method == "MaxEntropy"
        % Expected information (entropy)
        p = resultCounts/size(D,2);
        rankedWords.(scoreName)(j) = sum(-p.*log2(p),'omitnan');
    end

    if mod(j,100)==0 && showProgress
        waitbar(j/height(rankedWords),waitbarHandle);
    end

end

% Round?
rankedWords.(scoreName) = round(rankedWords.(scoreName),6);

% Pick next guess as the word with the maximum score. If there are multiple
% values with the max, try to pick one of the good guesses. Use the letter
% probability scores as the last tiebreaker
rankedWords = sortrows(rankedWords,[scoreName,"GoodGuess","LetterProbScore"],"descend");
nextWord = rankedWords.Words{1};

if showProgress
    close(waitbarHandle);
end
 
end